from decimal import Decimal

from django.db.models import Count, Sum
from django.utils import timezone

from apps.contributions.models import Contribution, ContributionCycle
from apps.loans.constants import DISBURSED, REPAID
from apps.loans.models import LoanApplication, LoanRepayment
from apps.governance.constants import ATTENDANCE_SCORE_WEIGHTS, COMPLETED
from apps.governance.models import Attendance, Meeting


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
        completed_meetings = Meeting.objects.filter(
            chama=chama, status=COMPLETED, attendance_finalized=True
        )
        total = completed_meetings.count()
        if total == 0:
            return Decimal("50")

        records = Attendance.objects.filter(
            member=member,
            meeting__chama=chama,
            meeting__status=COMPLETED,
            meeting__attendance_finalized=True,
        ).select_related("meeting")

        if not records.exists():
            return Decimal("0")

        weighted_total = Decimal("0")
        for record in records:
            weight = Decimal(str(ATTENDANCE_SCORE_WEIGHTS.get(record.status, 0)))
            weighted_total += weight

        return (weighted_total / Decimal(total) * Decimal("100")).quantize(
            Decimal("0.01")
        )

    @staticmethod
    def get_membership_duration_score(member, chama):
        from apps.memberships.models import Membership

        membership = Membership.objects.filter(
            user=member,
            chama=chama,
        ).first()
        if not membership or not membership.joined_at:
            return Decimal("0")

        days = (timezone.now() - membership.joined_at).days
        ratio = min(Decimal("1"), Decimal(days) / Decimal("365"))
        return ratio * Decimal("100")
