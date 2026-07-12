from rest_framework import serializers

from apps.notifications.models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = (
            "id",
            "title",
            "message",
            "notification_type",
            "channel",
            "is_read",
            "read_at",
            "metadata",
            "created_at",
        )
        read_only_fields = (
            "id",
            "title",
            "message",
            "notification_type",
            "channel",
            "metadata",
            "created_at",
        )


class NotificationUpdateSerializer(serializers.Serializer):
    is_read = serializers.BooleanField()
