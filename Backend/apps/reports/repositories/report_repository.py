import calendar
from datetime import datetime, timedelta
from decimal import Decimal

from django.db.models import Count, Sum
from django.utils import timezone

from apps.contributions.constants import OPEN
from apps.contributions.models import Contribution, ContributionCycle
from apps.credit_scoring.services.credit_scoring_service import CreditScoringService
from apps.loans.constants import APPROVED, DISBURSED, PENDING, REPAID
from apps.loans.models import LoanApplication, LoanRepayment
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership


def _add_months(source, months):
    """Add calendar months to a date/datetime, clamping day to month length."""
    month_index = source.month - 1 + months
    year = source.year + month_index // 12
    month = month_index % 12 + 1
    day = min(source.day, calendar.monthrange(year, month)[1])
    return source.replace(year=year, month=month, day=day)


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

    @staticmethod
    def _member_display(membership):
        user = membership.user
        full_name = f"{user.first_name} {user.last_name}".strip() or user.phone_number
        return {
            "member_id": str(user.id),
            "membership_id": str(membership.id),
            "full_name": full_name,
            "phone_number": user.phone_number,
            "role": membership.role.name,
        }

    @staticmethod
    def _contribution_defaulters(chama, cycle_id=None):
        cycles = ContributionCycle.objects.filter(chama=chama, status=OPEN)
        if cycle_id:
            cycles = cycles.filter(pk=cycle_id)
        cycles = list(cycles)
        if not cycles:
            return []

        memberships = list(
            Membership.objects.filter(chama=chama, status=ACTIVE).select_related(
                "user", "role"
            )
        )
        paid_pairs = set(
            Contribution.objects.filter(
                cycle__in=cycles, member_id__in=[m.user_id for m in memberships]
            ).values_list("cycle_id", "member_id")
        )

        rows = []
        for cycle in cycles:
            for membership in memberships:
                if (cycle.id, membership.user_id) in paid_pairs:
                    continue
                row = ReportRepository._member_display(membership)
                row.update(
                    {
                        "type": "contribution",
                        "cycle_id": str(cycle.id),
                        "cycle_name": cycle.name,
                        "expected_amount": str(cycle.contribution_amount),
                        "penalty_amount": str(cycle.penalty_amount),
                        "loan_id": None,
                        "outstanding_balance": None,
                        "due_date": None,
                    }
                )
                rows.append(row)
        return rows

    @staticmethod
    def _loan_defaulters(chama):
        now = timezone.now()
        loans = LoanApplication.objects.filter(
            chama=chama,
            status=DISBURSED,
            outstanding_balance__gt=Decimal("0.00"),
        ).select_related("applicant", "loan_product")
        membership_by_user = {
            m.user_id: m
            for m in Membership.objects.filter(chama=chama).select_related(
                "user", "role"
            )
        }

        rows = []
        for loan in loans:
            start = loan.approved_at or loan.applied_at or loan.updated_at
            if start is None:
                continue
            due = _add_months(start, loan.requested_duration) + timedelta(
                days=loan.loan_product.grace_period_days
            )
            if due >= now:
                continue

            membership = membership_by_user.get(loan.applicant_id)
            if membership is None:
                full_name = (
                    f"{loan.applicant.first_name} {loan.applicant.last_name}".strip()
                    or loan.applicant.phone_number
                )
                base = {
                    "member_id": str(loan.applicant_id),
                    "membership_id": None,
                    "full_name": full_name,
                    "phone_number": loan.applicant.phone_number,
                    "role": None,
                }
            else:
                base = ReportRepository._member_display(membership)

            base.update(
                {
                    "type": "loan",
                    "cycle_id": None,
                    "cycle_name": None,
                    "expected_amount": None,
                    "penalty_amount": None,
                    "loan_id": str(loan.id),
                    "outstanding_balance": str(loan.outstanding_balance),
                    "due_date": due.date().isoformat(),
                }
            )
            rows.append(base)
        return rows

    @staticmethod
    def defaulters_report(chama, cycle_id=None, defaulter_type="all"):
        contribution_rows = []
        loan_rows = []
        if defaulter_type in ("all", "contribution"):
            contribution_rows = ReportRepository._contribution_defaulters(
                chama, cycle_id=cycle_id
            )
        if defaulter_type in ("all", "loan"):
            loan_rows = ReportRepository._loan_defaulters(chama)

        return {
            "currency": chama.currency,
            "contribution_defaulters_count": len(contribution_rows),
            "loan_defaulters_count": len(loan_rows),
            "defaulters": contribution_rows + loan_rows,
        }
