from rest_framework.serializers import ModelSerializer
from messages.api.models import CustomUser
class UserSerializer(ModelSerializer):
    class Meta:

        model = CustomUser
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
        extra_kwargs = {
            'password': {'write_only': True}
        }
    def create(self, validated_data):
        user = CustomUser(**validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user
