from messages.api.models import CustomUser
from rest_framework import serializers
from messages.api.models import Conversation
from django.db import models

class ConversationSerializer(serializers.ModelSerializer):
    participants = serializers.PrimaryKeyRelatedField(
        many=True, queryset=CustomUser.objects.all()
    )

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