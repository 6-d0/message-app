from messages.api.models import CustomUser
from rest_framework import serializers
from messages.api.models import Test

class TestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Test
        fields = ['name']

    def create(self, validated_data):
        return Test.objects.create(**validated_data)
    
    def validate(self, attrs):
        name = attrs.get('name')
        if Test.objects.filter(name=name).exists():
            raise serializers.ValidationError("Name already exists")
        return super().validate(attrs)

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    password_confirm = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})

    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password', 'password_confirm', 'last_name', 'first_name', 'phone_number']

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Les mots de passe ne correspondent pas."})

        required_fields = ['last_name', 'first_name', 'phone_number']
        for field in required_fields:
            if not data.get(field):
                raise serializers.ValidationError({field: f"Le champ '{field}' est requis et ne peut pas être vide."})

        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = CustomUser.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            last_name=validated_data['last_name'],
            first_name=validated_data['first_name'],
            phone_number=validated_data['phone_number']
        )
        return user