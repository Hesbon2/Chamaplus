from datetime import timedelta
from decimal import Decimal

from django.db.models import Count, Sum
from django.utils import timezone

from apps.contributions.models import Contribution, ContributionCycle
from apps.loans.constants import DISBURSED, REPAID
from apps.loans.models import LoanApplication, LoanRepayment
from apps.memberships.models import Membership


class CreditScoreRepository:
    @staticmethod
    def get_contribution_consistency_score(member, chama):
        cycles = ContributionCycle.objects.filter(chama=chama)
        if not cycles.exists():
            return Decimal("50")

        expected = cycles.count()
        actual = Contribution.objects.filter(
            member=member,
            cycle__chama=chama,
        ).count()

        if expected == 0:
            return Decimal("50")

        ratio = min(Decimal("1"), Decimal(actual) / Decimal(expected))
        return ratio * Decimal("100")

    @staticmethod
    def get_repayment_history_score(member, chama):
        loans = LoanApplication.objects.filter(
            applicant=member,
            chama=chama,
            status__in=[DISBURSED, REPAID],
        )
        if not loans.exists():
            return Decimal("50")

        total_disbursed = loans.aggregate(
            total=Sum("approved_amount")
        )["total"] or Decimal("0")
        if total_disbursed <= 0:
            return Decimal("50")

        total_repaid = LoanRepayment.objects.filter(
            loan_application__applicant=member,
            loan_application__chama=chama,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        ratio = min(Decimal("1"), total_repaid / total_disbursed)
        return ratio * Decimal("100")

    @staticmethod
    def get_attendance_score(member, chama):
        # Meetings module not yet implemented; neutral baseline until attendance data exists.
        return Decimal("50")

    @staticmethod
    def get_membership_duration_score(member, chama):
        membership = Membership.objects.filter(
            user=member,
            chama=chama,
        ).first()
        if not membership or not membership.joined_at:
            return Decimal("0")

        days = (timezone.now() - membership.joined_at).days
        ratio = min(Decimal("1"), Decimal(days) / Decimal("365"))
        return ratio * Decimal("100")
