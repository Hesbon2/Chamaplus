from datetime import datetime
from decimal import Decimal

from django.db.models import Count, Sum
from django.utils import timezone

from apps.contributions.models import Contribution, ContributionCycle
from apps.credit_scoring.services.credit_scoring_service import CreditScoringService
from apps.loans.constants import APPROVED, DISBURSED, PENDING, REPAID
from apps.loans.models import LoanApplication, LoanRepayment
from apps.memberships.models import Membership


class ReportRepository:
    @staticmethod
    def contribution_summary(chama, date_from=None, date_to=None, cycle_id=None):
        queryset = Contribution.objects.filter(cycle__chama=chama)
        if date_from:
            queryset = queryset.filter(recorded_at__gte=date_from)
        if date_to:
            queryset = queryset.filter(recorded_at__lte=date_to)
        if cycle_id:
            queryset = queryset.filter(cycle_id=cycle_id)

        aggregates = queryset.aggregate(
            total_amount=Sum("amount"),
            total_count=Count("id"),
        )
        return {
            "total_amount": str(aggregates["total_amount"] or Decimal("0.00")),
            "total_count": aggregates["total_count"] or 0,
            "currency": chama.currency,
        }

    @staticmethod
    def loan_summary(chama, date_from=None, date_to=None):
        queryset = LoanApplication.objects.filter(chama=chama)
        if date_from:
            queryset = queryset.filter(created_at__gte=date_from)
        if date_to:
            queryset = queryset.filter(created_at__lte=date_to)

        return {
            "total_applications": queryset.count(),
            "pending": queryset.filter(status=PENDING).count(),
            "approved": queryset.filter(status=APPROVED).count(),
            "disbursed": queryset.filter(status=DISBURSED).count(),
            "repaid": queryset.filter(status=REPAID).count(),
            "outstanding_balance": str(
                queryset.filter(status=DISBURSED).aggregate(
                    total=Sum("outstanding_balance")
                )["total"]
                or Decimal("0.00")
            ),
        }

    @staticmethod
    def repayment_summary(chama, date_from=None, date_to=None):
        queryset = LoanRepayment.objects.filter(loan_application__chama=chama)
        if date_from:
            queryset = queryset.filter(payment_date__gte=date_from)
        if date_to:
            queryset = queryset.filter(payment_date__lte=date_to)

        aggregates = queryset.aggregate(
            total_amount=Sum("amount"),
            total_count=Count("id"),
        )
        return {
            "total_amount": str(aggregates["total_amount"] or Decimal("0.00")),
            "total_count": aggregates["total_count"] or 0,
            "currency": chama.currency,
        }

    @staticmethod
    def member_financial_summary(chama, member):
        contributions = Contribution.objects.filter(
            member=member, cycle__chama=chama
        ).aggregate(total=Sum("amount"), count=Count("id"))
        loans = LoanApplication.objects.filter(applicant=member, chama=chama)
        repayments = LoanRepayment.objects.filter(
            loan_application__applicant=member,
            loan_application__chama=chama,
        ).aggregate(total=Sum("amount"), count=Count("id"))
        current_score = CreditScoringService.get_current_score(member, chama)

        return {
            "member_id": str(member.id),
            "contributions_total": str(contributions["total"] or Decimal("0.00")),
            "contributions_count": contributions["count"] or 0,
            "active_loans": loans.filter(status=DISBURSED).count(),
            "repayments_total": str(repayments["total"] or Decimal("0.00")),
            "credit_score": current_score.score if current_score else None,
            "credit_risk_level": current_score.risk_level if current_score else None,
        }

    @staticmethod
    def chama_financial_summary(chama, date_from=None, date_to=None):
        return {
            "contributions": ReportRepository.contribution_summary(
                chama, date_from, date_to
            ),
            "loans": ReportRepository.loan_summary(chama, date_from, date_to),
            "repayments": ReportRepository.repayment_summary(
                chama, date_from, date_to
            ),
            "member_count": Membership.objects.filter(chama=chama).count(),
            "active_cycles": ContributionCycle.objects.filter(
                chama=chama, status="open"
            ).count(),
        }

    @staticmethod
    def monthly_summary(chama, year, month):
        tz = timezone.get_current_timezone()
        start = timezone.make_aware(datetime(year, month, 1), tz)
        if month == 12:
            end = timezone.make_aware(datetime(year + 1, 1, 1), tz)
        else:
            end = timezone.make_aware(datetime(year, month + 1, 1), tz)
        return {
            "year": year,
            "month": month,
            "contributions": ReportRepository.contribution_summary(
                chama, date_from=start, date_to=end
            ),
            "loans": ReportRepository.loan_summary(
                chama, date_from=start, date_to=end
            ),
            "repayments": ReportRepository.repayment_summary(
                chama, date_from=start, date_to=end
            ),
        }
