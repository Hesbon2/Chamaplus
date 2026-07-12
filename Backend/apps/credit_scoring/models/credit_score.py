from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel
from apps.credit_scoring.constants import (
    RISK_EXCELLENT,
    RISK_FAIR,
    RISK_GOOD,
    RISK_HIGH,
    RISK_LEVEL_CHOICES,
)


class CreditScore(TimeStampedModel):
    """Historical credit score snapshot for a member within a Chama."""

    member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="credit_scores",
    )
    chama = models.ForeignKey(
        "chamas.Chama",
        on_delete=models.CASCADE,
        related_name="credit_scores",
    )
    score = models.PositiveSmallIntegerField()
    risk_level = models.CharField(max_length=20, choices=RISK_LEVEL_CHOICES)
    breakdown = models.JSONField(default=dict)
    weights = models.JSONField(default=dict)
    calculated_at = models.DateTimeField()
    triggered_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="triggered_credit_scores",
        null=True,
        blank=True,
    )

    class Meta:
        db_table = "credit_scores"
        ordering = ["-calculated_at", "-created_at"]
        indexes = [
            models.Index(fields=["chama", "member", "calculated_at"]),
        ]

    def __str__(self):
        return f"{self.member_id} @ {self.chama_id}: {self.score} ({self.risk_level})"
