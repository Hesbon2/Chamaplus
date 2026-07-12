from decimal import Decimal

from django.conf import settings
from django.db.models import Sum

from apps.contributions.models import Contribution
from apps.core.exceptions import DomainError
from apps.loans.constants import DISBURSED
from apps.loans.models import LoanApplication
from apps.memberships.services.membership_service import MembershipService


class LoanEligibilityService:
    @staticmethod
    def validate_eligibility(applicant, chama, loan_product, requested_amount, requested_duration):
        if not MembershipService.user_is_active_member(applicant, chama):
            raise DomainError("Applicant must be an active member of this Chama.")

        if loan_product.chama_id != chama.id:
            raise DomainError("Loan product does not belong to this Chama.")

        if not loan_product.is_active:
            raise DomainError("Selected loan product is not active.")

        if requested_amount < loan_product.minimum_amount:
            raise DomainError(
                f"Requested amount must be at least {loan_product.minimum_amount}."
            )

        if requested_amount > loan_product.maximum_amount:
            raise DomainError(
                f"Requested amount cannot exceed {loan_product.maximum_amount}."
            )

        if requested_duration > loan_product.maximum_duration:
            raise DomainError(
                f"Requested duration cannot exceed {loan_product.maximum_duration} months."
            )

        min_contributions = settings.MIN_CONTRIBUTIONS_FOR_LOAN_ELIGIBILITY
        contribution_count = Contribution.objects.filter(
            member=applicant,
            cycle__chama=chama,
        ).count()
        if contribution_count < min_contributions:
            raise DomainError(
                "Insufficient contribution history. "
                f"At least {min_contributions} contribution(s) required."
            )

        active_loan = LoanApplication.objects.filter(
            applicant=applicant,
            chama=chama,
            status=DISBURSED,
            outstanding_balance__gt=Decimal("0.00"),
        ).exists()
        if active_loan:
            raise DomainError("Applicant has an outstanding loan that must be repaid first.")
