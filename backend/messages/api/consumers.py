from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import async_to_sync
import json
from channels.db import database_sync_to_async
from messages.api.models import Conversation, Message
import logging
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)
channel_layer = get_channel_layer()

def notify_new_message(conversation, message):
    participants = conversation.participants.all()
    for participant in participants:
        async_to_sync(channel_layer.group_send)(
            f"user_{participant.id}",
            {
                "type": "new_message",
                "conversation_id": conversation.id,
                "message": message.content,
                "sender": message.sender.username,
            }
        )
        logger.info(f"Notification sent to user {participant.id} for new message in conversation {conversation.id}.")

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        logger.info("Attempting to connect WebSocket for a specific conversation...")
        user = self.scope["user"]
        if user.is_anonymous:
            logger.warning("Anonymous user attempted to connect.")
            await self.close()
            return

        conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        logger.info(f"Conversation ID: {conversation_id}")

        conversation = await self.get_conversation(conversation_id)
        if not conversation:
            logger.warning(f"Conversation {conversation_id} not found.")
            await self.close()
            return

        if not await self.is_participant(conversation, user.id):
            logger.warning(f"User {user.id} is not a participant of conversation {conversation_id}.")
            await self.close()
            return

        self.room_group_name = f"chat_{conversation_id}"
        logger.info(f"Room group name: {self.room_group_name}")

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()
        logger.info(f"WebSocket connection established for user {user.id} in conversation {conversation_id}.")

    async def disconnect(self, close_code):
        logger.info(f"Disconnecting WebSocket with close_code: {close_code}")
        try:
            if hasattr(self, "room_group_name"):
                await self.channel_layer.group_discard(self.room_group_name, self.channel_name)
                logger.info(f"User {self.scope['user']} removed from group {self.room_group_name}.")
        except Exception as e:
            logger.error(f"Error during WebSocket disconnection: {e}")

    @database_sync_to_async
    def save_message(self, conversation, user, content):
        message = Message.objects.create(
            conversation=conversation,
            sender=user,
            content=content
        )
        notify_new_message(conversation, message)
        return message

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message = data.get("message")
            if not message:
                await self.send(text_data=json.dumps({"error": "Message content is missing."}))
                return

            user = self.scope["user"]
            sender = user.username
            conversation_id = self.scope['url_route']['kwargs']['conversation_id']
            conversation = await self.get_conversation(conversation_id)
            if not conversation:
                await self.send(text_data=json.dumps({"error": "Conversation not found."}))
                return

            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "chat_message",
                    "message": message,
                    "sender": sender,
                    "conversation_id": conversation_id,
                }
            )
            await self.save_message(conversation, user, message)
        except Exception as e:
            logger.error(f"Error in receive: {e}")
            await self.send(text_data=json.dumps({"error": "An error occurred."}))

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            "message": event["message"],
            "sender": event["sender"],
            "conversation_id": event["conversation_id"],
        }))

    @database_sync_to_async
    def get_conversation(self, conversation_id):
        try:
            return Conversation.objects.get(id=conversation_id)
        except Conversation.DoesNotExist:
            return None

    @database_sync_to_async
    def is_participant(self, conversation, user_id):
        return conversation.participants.filter(id=user_id).exists()

# Consommateur global pour notifier les utilisateurs des nouveaux messages
class GlobalChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        logger.info("Attempting to connect to global WebSocket...")
        user = self.scope["user"]

        if user.is_anonymous:
            logger.warning("Anonymous user attempted to connect.")
            await self.close()
            return

        # Ajoutez l'utilisateur à un groupe basé sur son ID
        self.user_group_name = f"user_{user.id}"
        await self.channel_layer.group_add(self.user_group_name, self.channel_name)
        await self.accept()
        logger.info(f"Global WebSocket connection established for user {user.id}.")

    async def disconnect(self, close_code):
        logger.info(f"Disconnecting global WebSocket with close_code: {close_code}")
        try:
            if hasattr(self, "user_group_name"):
                await self.channel_layer.group_discard(self.user_group_name, self.channel_name)
                logger.info(f"User {self.scope['user']} removed from group {self.user_group_name}.")
        except Exception as e:
            logger.error(f"Error during global WebSocket disconnection: {e}")

    async def receive(self, text_data):
        """
        Bloque les messages entrants sur le WebSocket global.
        """
        logger.warning("Messages cannot be sent via the global WebSocket.")
        await self.send(text_data=json.dumps({"error": "Sending messages via global WebSocket is not allowed."}))

    async def new_message(self, event):
        """
        Notifie l'utilisateur qu'un nouveau message est arrivé dans une conversation.
        """
        await self.send(text_data=json.dumps({
            "type": "new_message",
            "conversation_id": event["conversation_id"],
            "message": event["message"],
            "sender": event["sender"],
        }))