from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models

from apps.chamas.models import Chama
from apps.contributions.constants import (
    ANNUALLY,
    CLOSED,
    FREQUENCY_CHOICES,
    MONTHLY,
    OPEN,
    QUARTERLY,
    STATUS_CHOICES,
    WEEKLY,
)
from apps.core.models import TimeStampedModel


class ContributionCycle(TimeStampedModel):
    """Defines a savings period and contribution schedule within a Chama."""

    chama = models.ForeignKey(
        Chama,
        on_delete=models.CASCADE,
        related_name="contribution_cycles",
    )
    name = models.CharField(max_length=200)
    frequency = models.CharField(max_length=20, choices=FREQUENCY_CHOICES)
    contribution_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    start_date = models.DateField()
    end_date = models.DateField()
    due_day = models.PositiveSmallIntegerField()
    penalty_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal("0.00"),
        validators=[MinValueValidator(Decimal("0.00"))],
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=OPEN)

    class Meta:
        db_table = "contribution_cycles"
        ordering = ["-start_date", "-created_at"]
        indexes = [
            models.Index(fields=["chama", "status"]),
            models.Index(fields=["chama", "start_date"]),
        ]

    def __str__(self):
        return f"{self.name} ({self.chama.name})"

    @property
    def is_open(self):
        return self.status == OPEN

    @property
    def is_closed(self):
        return self.status == CLOSED

    def close(self):
        self.status = CLOSED
        self.save(update_fields=["status", "updated_at"])
