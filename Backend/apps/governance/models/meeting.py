from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel
from apps.governance.constants import MEETING_STATUS_CHOICES, MEETING_TYPE_CHOICES, SCHEDULED


class Meeting(TimeStampedModel):
    """Scheduled Chama meeting."""

    chama = models.ForeignKey(
        "chamas.Chama",
        on_delete=models.CASCADE,
        related_name="meetings",
    )
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    meeting_type = models.CharField(max_length=20, choices=MEETING_TYPE_CHOICES)
    venue = models.CharField(max_length=255)
    meeting_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField(null=True, blank=True)
    status = models.CharField(
        max_length=20, choices=MEETING_STATUS_CHOICES, default=SCHEDULED
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="created_meetings",
        null=True,
        blank=True,
    )
    attendance_finalized = models.BooleanField(default=False)

    class Meta:
        db_table = "meetings"
        ordering = ["-meeting_date", "-start_time"]
        indexes = [
            models.Index(fields=["chama", "meeting_date"]),
            models.Index(fields=["chama", "status"]),
        ]

    def __str__(self):
        return f"{self.title} ({self.meeting_date})"
