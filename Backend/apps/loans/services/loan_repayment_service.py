from decimal import Decimal

from django.db import transaction
from django.utils import timezone

from apps.chamas.constants import DEFAULT_CURRENCY
from apps.core.exceptions import DomainError
from apps.loans.constants import DISBURSED, REPAID
from apps.loans.models import LoanApplication, LoanRepayment
from apps.loans.services.loan_application_service import LoanApplicationService
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import TREASURER


class LoanRepaymentService:
    @staticmethod
    def record_repayment(application, recorded_by, validated_data):
        if application.status not in (DISBURSED, REPAID):
            raise DomainError("Repayments can only be recorded for disbursed loans.")

        if application.status == REPAID:
            raise DomainError("This loan has already been fully repaid.")

        if not MembershipService.user_has_role(
            recorded_by, application.chama, [TREASURER]
        ):
            raise DomainError(
                "Only the Treasurer can record loan repayments.",
                status_code=403,
            )

        amount = validated_data["amount"]
        outstanding = application.outstanding_balance or Decimal("0.00")

        if amount > outstanding:
            raise DomainError(
                f"Repayment amount cannot exceed outstanding balance of {outstanding}."
            )

        payment_date = validated_data.get("payment_date") or timezone.now()
        currency = validated_data.get("currency") or application.chama.currency or DEFAULT_CURRENCY

        with transaction.atomic():
            application = LoanApplication.objects.select_for_update().get(
                pk=application.pk
            )
            outstanding = application.outstanding_balance or Decimal("0.00")
            if amount > outstanding:
                raise DomainError(
                    f"Repayment amount cannot exceed outstanding balance of {outstanding}."
                )

            repayment = LoanRepayment.objects.create(
                loan_application=application,
                amount=amount,
                currency=currency,
                payment_method=validated_data["payment_method"],
                reference=validated_data["reference"],
                payment_date=payment_date,
                recorded_by=recorded_by,
            )

            new_balance = outstanding - amount
            application.outstanding_balance = new_balance
            if new_balance <= Decimal("0.00"):
                application.outstanding_balance = Decimal("0.00")
                application.status = REPAID
            application.save(update_fields=["outstanding_balance", "status", "updated_at"])

        return repayment

    @staticmethod
    def list_repayments(application):
        return LoanRepayment.objects.filter(
            loan_application=application
        ).select_related("recorded_by")

    @staticmethod
    def get_repayment(application, repayment_id):
        try:
            return LoanRepayment.objects.select_related("recorded_by").get(
                pk=repayment_id,
                loan_application=application,
            )
        except LoanRepayment.DoesNotExist as exc:
            raise DomainError("Loan repayment not found.", status_code=404) from exc
