from rest_framework.views import APIView, Response
from rest_framework.permissions import IsAuthenticated
from messages.api.models import CustomUser

from messages.api.serializers.user import UserSerializer

class UserListView(APIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        users = self.queryset.all()
        serializer = self.serializer_class(users, many=True)
        return Response(serializer.data)

class UserDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user  # Récupère l'utilisateur authentifié
        serializer = UserSerializer(user)
        return Response(serializer.data)