from rest_framework.generics import CreateAPIView, ListAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from messages.api.models import Conversation
from messages.api.serializers import ConversationSerializer

class ConversationViews(CreateAPIView, ListAPIView):
    queryset = Conversation.objects.all()
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = ConversationSerializer(data=request.data)
        if serializer.is_valid():
            participants = request.data.get('participants', [])
            if len(participants) != len(set(participants)):
                return Response({"error": "Les participants doivent être uniques."}, status=400)
            
            conversation = serializer.save()
            if participants:
                conversation.participants.set(participants)
            return Response(serializer.data, status=201)
        else:
            return Response(serializer.errors, status=400)

    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
class ConversationList(ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ConversationSerializer
    def get_queryset(self):
        return Conversation.objects.filter(participants=self.request.user)
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)