from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel


class MeetingMinute(TimeStampedModel):
    """Official minutes for a completed meeting."""

    meeting = models.OneToOneField(
        "governance.Meeting",
        on_delete=models.CASCADE,
        related_name="minutes",
    )
    minutes = models.TextField()
    resolutions = models.JSONField(default=list)
    action_items = models.JSONField(default=list)
    prepared_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="prepared_minutes",
        null=True,
        blank=True,
    )
    approved = models.BooleanField(default=False)
    approved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="approved_minutes",
        null=True,
        blank=True,
    )
    approved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "meeting_minutes"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Minutes for {self.meeting_id}"
