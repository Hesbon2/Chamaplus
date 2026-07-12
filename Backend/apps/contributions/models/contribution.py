from decimal import Decimal

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models

from apps.chamas.constants import DEFAULT_CURRENCY
from apps.contributions.constants import PAYMENT_METHOD_CHOICES
from apps.contributions.models.contribution_cycle import ContributionCycle
from apps.core.models import TimeStampedModel


class Contribution(TimeStampedModel):
    """Immutable record of a member contribution within a cycle."""

    cycle = models.ForeignKey(
        ContributionCycle,
        on_delete=models.PROTECT,
        related_name="contributions",
    )
    member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="contributions",
    )
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    currency = models.CharField(max_length=3, default=DEFAULT_CURRENCY)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    reference = models.CharField(max_length=100)
    recorded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="recorded_contributions",
    )
    recorded_at = models.DateTimeField()
    idempotency_key = models.CharField(max_length=64, blank=True, null=True, unique=True)

    class Meta:
        db_table = "contributions"
        ordering = ["-recorded_at", "-created_at"]
        indexes = [
            models.Index(fields=["cycle", "member"]),
            models.Index(fields=["member", "recorded_at"]),
            models.Index(fields=["recorded_at"]),
        ]

    def __str__(self):
        return f"{self.member} - {self.amount} {self.currency}"
