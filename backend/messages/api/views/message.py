from rest_framework.generics import ListCreateAPIView, RetrieveUpdateDestroyAPIView, get_object_or_404
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import Response
from messages.api.models import Message, Conversation
from messages.api.serializers import MessageSerializer, MessageListSerializer
from rest_framework.exceptions import PermissionDenied
from django.http import Http404
from rest_framework import status


class MessageSendView(ListCreateAPIView):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        conversation_id = self.request.data.get('conversation')
        if not Conversation.objects.filter(id=conversation_id, participants=self.request.user).exists():
            raise PermissionDenied()
        serializer.save(sender=self.request.user)
    def get_queryset(self):
        return Message.objects.filter(sender=self.request.user)
    
class MessageListView(ListCreateAPIView):
    queryset = Message.objects.all()
    serializer_class = MessageListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        conversation_id = self.kwargs.get('conversation_id')
        get_object_or_404(Conversation.objects.filter(id=conversation_id))
        participant_in = Conversation.objects.filter(id=conversation_id, participants=self.request.user)
        if not participant_in.exists():
            raise PermissionDenied()
        return Message.objects.filter(conversation__id=conversation_id)