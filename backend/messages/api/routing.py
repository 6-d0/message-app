from django.urls import path
from .consumers import ChatConsumer, GlobalChatConsumer

websocket_urlpatterns = [
    path("ws/chat/<int:conversation_id>/", ChatConsumer.as_asgi()),
    path("ws/global/", GlobalChatConsumer.as_asgi()),  # Utilisez le consommateur global ici
]
