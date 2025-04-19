from rest_framework.generics import ListCreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.permissions import IsAuthenticated

from messages.api.models import Message
from messages.api.serializers import MessageSerializer

class MessageListCreateView(ListCreateAPIView):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)
    def get_queryset(self):
        return Message.objects.filter(sender=self.request.user)