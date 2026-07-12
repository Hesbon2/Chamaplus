from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel
from apps.notifications.constants import CHANNEL_CHOICES, CHANNEL_IN_APP, NOTIFICATION_TYPE_CHOICES


class Notification(TimeStampedModel):
    """In-app notification for a user."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notifications",
    )
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(
        max_length=50, choices=NOTIFICATION_TYPE_CHOICES
    )
    channel = models.CharField(
        max_length=20, choices=CHANNEL_CHOICES, default=CHANNEL_IN_APP
    )
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    metadata = models.JSONField(default=dict)

    class Meta:
        db_table = "notifications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user", "is_read", "created_at"]),
        ]

    def __str__(self):
        return f"{self.title} -> {self.user_id}"
