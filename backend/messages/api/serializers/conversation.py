from messages.api.models import CustomUser
from messages.api.serializers.user import UserSerializer
from rest_framework import serializers
from messages.api.models import Conversation
from django.db import models

class ConversationSerializer(serializers.ModelSerializer):
    participants = serializers.PrimaryKeyRelatedField(
        many=True, queryset=CustomUser.objects.all(), write_only=True
    )
    participants_details = serializers.SerializerMethodField(read_only=True)
    last_message = serializers.SerializerMethodField(read_only=True)
    last_message_sender = serializers.SerializerMethodField(read_only=True)
    last_message_time = serializers.SerializerMethodField(read_only=True)  # Converti en SerializerMethodField

    def get_participants_details(self, obj):
        return UserSerializer(obj.participants, many=True).data

    def get_last_message_time(self, obj):
        # Récupérer le dernier message de la conversation
        last_message = obj.messages.order_by('-created_at').first()
        return last_message.created_at if last_message else None

    def get_last_message(self, obj):
        # Récupérer le dernier message de la conversation
        last_message = obj.messages.order_by('-created_at').first()
        return last_message.content if last_message else None

    def get_last_message_sender(self, obj):
        # Récupérer l'expéditeur du dernier message
        last_message = obj.messages.order_by('-created_at').first()
        return last_message.sender.username if last_message else None

    class Meta:
        model = Conversation
        fields = '__all__'

    def validate(self, data):
        participants = data.get('participants', [])
        if len(participants) == 2:
            existing_conversation = Conversation.objects.filter(
                participants__in=participants
            ).distinct().annotate(count=models.Count('participants')).filter(count=2)
            if existing_conversation.exists():
                raise serializers.ValidationError("Une conversation entre ces participants existe déjà.")
        
        return data

    def create(self, validated_data):
        participants = validated_data.pop('participants', [])
        conversation = Conversation.objects.create(**validated_data)
        conversation.participants.set(participants)
        return conversation