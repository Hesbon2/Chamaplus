from decimal import Decimal

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models

from apps.chamas.constants import DEFAULT_CURRENCY
from apps.contributions.constants import PAYMENT_METHOD_CHOICES
from apps.core.models import TimeStampedModel


class LoanRepayment(TimeStampedModel):
    """Immutable loan repayment record."""

    loan_application = models.ForeignKey(
        "loans.LoanApplication",
        on_delete=models.PROTECT,
        related_name="repayments",
    )
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    currency = models.CharField(max_length=3, default=DEFAULT_CURRENCY)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    reference = models.CharField(max_length=100)
    payment_date = models.DateTimeField()
    recorded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="recorded_loan_repayments",
    )

    class Meta:
        db_table = "repayments"
        ordering = ["-payment_date", "-created_at"]
        indexes = [
            models.Index(fields=["loan_application", "payment_date"]),
        ]

    def __str__(self):
        return f"{self.loan_application_id} - {self.amount}"
