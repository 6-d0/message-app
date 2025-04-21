from channels.generic.websocket import AsyncWebsocketConsumer
import json
from channels.db import database_sync_to_async
from messages.api.models import Conversation, Message

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_group_name = None  
        user = self.scope["user"]
        if user.is_anonymous:
            await self.close()
            return

        conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        
        conversation = await self.get_conversation(conversation_id)
        if not conversation:
            await self.close()
            return

        if not await self.is_participant(conversation, user.id):
            await self.close()
            return

        self.room_group_name = f"chat_{conversation_id}"

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if self.room_group_name:
            await self.channel_layer.group_discard(self.room_group_name, self.channel_name)


    @database_sync_to_async
    def save_message(self, conversation, user, content):
        return Message.objects.create(
            conversation=conversation,
            sender=user,
            content=content
        )


    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data["message"]
        
        user = self.scope["user"]
        sender = user.id
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
