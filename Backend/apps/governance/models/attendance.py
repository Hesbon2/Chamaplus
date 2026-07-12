from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel
from apps.governance.constants import ATTENDANCE_STATUS_CHOICES, PRESENT


class Attendance(TimeStampedModel):
    """Member attendance record for a meeting."""

    meeting = models.ForeignKey(
        "governance.Meeting",
        on_delete=models.CASCADE,
        related_name="attendance_records",
    )
    member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="meeting_attendance",
    )
    status = models.CharField(
        max_length=20, choices=ATTENDANCE_STATUS_CHOICES, default=PRESENT
    )
    arrival_time = models.TimeField(null=True, blank=True)
    remarks = models.TextField(blank=True)
    recorded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="recorded_attendance",
        null=True,
        blank=True,
    )

    class Meta:
        db_table = "attendance"
        ordering = ["member__first_name", "member__last_name"]
        constraints = [
            models.UniqueConstraint(
                fields=["meeting", "member"],
                name="unique_attendance_per_member_meeting",
            ),
        ]
        indexes = [
            models.Index(fields=["meeting", "status"]),
        ]

    def __str__(self):
        return f"{self.member_id} @ {self.meeting_id}: {self.status}"
