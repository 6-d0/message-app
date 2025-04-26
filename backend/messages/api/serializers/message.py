from rest_framework import serializers
from messages.api.models import Message

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'sender']

class MessageListSerializer(serializers.ModelSerializer):
    sender = serializers.StringRelatedField()
    conversation = serializers.PrimaryKeyRelatedField(read_only=True)  # Défini comme read_only

    class Meta:
        model = Message
        fields = ['id', 'sender', 'conversation', 'content', 'created_at']
        read_only_fields = ['id', 'created_at', 'conversation']

    def create(self, validated_data):
        message = Message(**validated_data)
        message.save()
        return message