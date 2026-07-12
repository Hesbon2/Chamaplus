from decimal import Decimal

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models

from apps.chamas.models import Chama
from apps.core.models import TimeStampedModel
from apps.loans.constants import APPLICATION_STATUS_CHOICES, DRAFT


class LoanApplication(TimeStampedModel):
    """Member loan application within a Chama."""

    applicant = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="loan_applications",
    )
    chama = models.ForeignKey(
        Chama,
        on_delete=models.CASCADE,
        related_name="loan_applications",
    )
    loan_product = models.ForeignKey(
        "loans.LoanProduct",
        on_delete=models.PROTECT,
        related_name="applications",
    )
    requested_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    requested_duration = models.PositiveSmallIntegerField(
        help_text="Requested duration in months."
    )
    purpose = models.CharField(max_length=500)
    status = models.CharField(
        max_length=20,
        choices=APPLICATION_STATUS_CHOICES,
        default=DRAFT,
    )
    applied_at = models.DateTimeField(null=True, blank=True)
    approved_at = models.DateTimeField(null=True, blank=True)
    rejected_at = models.DateTimeField(null=True, blank=True)
    approved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="approved_loan_applications",
        null=True,
        blank=True,
    )
    approved_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    outstanding_balance = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(Decimal("0.00"))],
    )
    remarks = models.TextField(blank=True)

    class Meta:
        db_table = "loan_applications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["chama", "status"]),
            models.Index(fields=["applicant", "status"]),
        ]

    def __str__(self):
        return f"{self.applicant} - {self.requested_amount} ({self.status})"
