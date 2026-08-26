from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated

from apps.chamas.services.chama_service import ChamaService
from apps.core.exceptions import DomainError
from apps.core.responses import EnvelopeAPIView, success_response
from apps.memberships.permissions import IsChamaMember
from apps.reports.permissions import IsChamaTreasurerOrChairperson
from apps.reports.services.report_service import ReportService


def _parse_query_dates(request):
    date_from = request.query_params.get("date_from")
    date_to = request.query_params.get("date_to")
    return date_from, date_to


class ContributionsReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Contribution summary report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        date_from, date_to = _parse_query_dates(request)
        cycle_id = request.query_params.get("cycle_id")
        data = ReportService.get_contributions_report(
            chama, date_from=date_from, date_to=date_to, cycle_id=cycle_id
        )
        return success_response(
            data=data,
            message="Contribution report retrieved successfully.",
        )


class LoansReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Loan portfolio summary report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        date_from, date_to = _parse_query_dates(request)
        data = ReportService.get_loans_report(chama, date_from, date_to)
        return success_response(
            data=data,
            message="Loan report retrieved successfully.",
        )


class RepaymentsReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Repayment summary report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        date_from, date_to = _parse_query_dates(request)
        data = ReportService.get_repayments_report(chama, date_from, date_to)
        return success_response(
            data=data,
            message="Repayment report retrieved successfully.",
        )


class FinancialReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Chama financial summary report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        date_from, date_to = _parse_query_dates(request)
        data = ReportService.get_financial_report(chama, date_from, date_to)
        return success_response(
            data=data,
            message="Financial report retrieved successfully.",
        )


class MemberFinancialReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Reports"],
        summary="Member financial summary report",
    )
    def get(self, request, chama_id, member_id):
        chama = ChamaService.get_chama(chama_id)
        from django.contrib.auth import get_user_model

        User = get_user_model()
        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        if str(request.user.id) != str(member_id):
            from apps.memberships.services.membership_service import MembershipService
            from apps.roles.constants import CHAIRPERSON, TREASURER

            if not MembershipService.user_has_role(
                request.user, chama, [CHAIRPERSON, TREASURER]
            ):
                raise DomainError(
                    "You do not have permission to view this report.",
                    status_code=403,
                )

        data = ReportService.get_member_financial_report(chama, member)
        return success_response(
            data=data,
            message="Member financial report retrieved successfully.",
        )


class MonthlyReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Monthly summary report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        year = request.query_params.get("year")
        month = request.query_params.get("month")
        data = ReportService.get_monthly_report(chama, year=year, month=month)
        return success_response(
            data=data,
            message="Monthly report retrieved successfully.",
        )


class DefaultersReportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Contribution and loan defaulters report",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        cycle_id = request.query_params.get("cycle_id")
        defaulter_type = request.query_params.get("type", "all")
        data = ReportService.get_defaulters_report(
            chama, cycle_id=cycle_id, defaulter_type=defaulter_type
        )
        return success_response(
            data=data,
            message="Defaulters report retrieved successfully.",
        )


class ReportExportView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Reports"],
        summary="Export report as CSV or PDF",
    )
    def get(self, request, chama_id, report_type):
        chama = ChamaService.get_chama(chama_id)
        export_format = request.query_params.get("export_format", "csv").lower()
        date_from, date_to = _parse_query_dates(request)
        cycle_id = request.query_params.get("cycle_id")
        year = request.query_params.get("year")
        month = request.query_params.get("month")
        defaulter_type = request.query_params.get("type")

        kwargs = {
            "date_from": date_from,
            "date_to": date_to,
            "cycle_id": cycle_id,
            "year": year,
            "month": month,
            "defaulter_type": defaulter_type,
        }
        kwargs = {k: v for k, v in kwargs.items() if v is not None}

        return ReportService.export_report(
            report_type, chama, export_format, **kwargs
        )


class DashboardView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Dashboard"],
        summary="Chama dashboard summary",
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        data = ReportService.get_dashboard(chama, request.user)
        return success_response(
            data=data,
            message="Dashboard retrieved successfully.",
        )
