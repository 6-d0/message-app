from .user import CustomUser
from .base import BaseModel
from django.db import models
class Test(BaseModel):
    name = models.CharField(max_length=10)

class Conversation(BaseModel):
    participants = models.ManyToManyField(CustomUser, related_name='conversations')
    last_updated = models.DateTimeField(auto_now=True)  # Dernière mise à jour de la conversation

    def __str__(self):
        return f"Conversation between {', '.join([user.username for user in self.participants.all()])}"

class Message(BaseModel):
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)