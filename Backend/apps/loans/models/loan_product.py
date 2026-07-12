from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models

from apps.chamas.models import Chama
from apps.core.models import TimeStampedModel


class LoanProduct(TimeStampedModel):
    """Loan template offered by a Chama."""

    chama = models.ForeignKey(
        Chama,
        on_delete=models.CASCADE,
        related_name="loan_products",
    )
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    interest_rate = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.00"))],
    )
    minimum_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    maximum_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    maximum_duration = models.PositiveSmallIntegerField(
        help_text="Maximum loan duration in months."
    )
    grace_period_days = models.PositiveSmallIntegerField(default=0)
    processing_fee = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal("0.00"),
        validators=[MinValueValidator(Decimal("0.00"))],
    )
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "loan_products"
        ordering = ["name"]
        indexes = [
            models.Index(fields=["chama", "is_active"]),
        ]

    def __str__(self):
        return f"{self.name} ({self.chama.name})"
