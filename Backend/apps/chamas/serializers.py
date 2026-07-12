from django.contrib.auth import get_user_model
from rest_framework import serializers

from apps.chamas.models import Chama

User = get_user_model()


class ChamaSerializer(serializers.ModelSerializer):
    created_by = serializers.UUIDField(source="created_by_id", read_only=True)

    class Meta:
        model = Chama
        fields = (
            "id",
            "name",
            "description",
            "location",
            "currency",
            "invite_code",
            "is_active",
            "created_by",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "invite_code",
            "is_active",
            "created_by",
            "created_at",
            "updated_at",
        )


class ChamaCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chama
        fields = ("name", "description", "location", "currency")

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Chama name cannot be empty.")
        return value.strip()


class ChamaUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chama
        fields = ("name", "description", "location", "currency")

    def validate_name(self, value):
        if value is not None and not value.strip():
            raise serializers.ValidationError("Chama name cannot be empty.")
        return value.strip() if value else value
