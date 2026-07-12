import csv
import io
from decimal import Decimal

from django.http import HttpResponse
from django.utils import timezone

from apps.core.exceptions import DomainError
from apps.credit_scoring.services.credit_scoring_service import CreditScoringService
from apps.reports.repositories.report_repository import ReportRepository


class ReportService:
    REPORT_BUILDERS = {
        "contributions": "_contributions_report",
        "loans": "_loans_report",
        "repayments": "_repayments_report",
        "financial": "_financial_report",
        "monthly": "_monthly_report",
    }

    @staticmethod
    def _parse_dates(date_from, date_to):
        return date_from, date_to

    @staticmethod
    def get_contributions_report(chama, date_from=None, date_to=None, cycle_id=None):
        return ReportRepository.contribution_summary(
            chama, date_from=date_from, date_to=date_to, cycle_id=cycle_id
        )

    @staticmethod
    def get_loans_report(chama, date_from=None, date_to=None):
        return ReportRepository.loan_summary(chama, date_from, date_to)

    @staticmethod
    def get_repayments_report(chama, date_from=None, date_to=None):
        return ReportRepository.repayment_summary(chama, date_from, date_to)

    @staticmethod
    def get_financial_report(chama, date_from=None, date_to=None):
        return ReportRepository.chama_financial_summary(chama, date_from, date_to)

    @staticmethod
    def get_member_financial_report(chama, member):
        return ReportRepository.member_financial_summary(chama, member)

    @staticmethod
    def get_monthly_report(chama, year=None, month=None):
        now = timezone.localtime()
        year = int(year or now.year)
        month = int(month or now.month)
        return ReportRepository.monthly_summary(chama, year, month)

    @staticmethod
    def get_dashboard(chama, user):
        from apps.contributions.models import ContributionCycle
        from apps.loans.constants import DISBURSED, PENDING
        from apps.loans.models import LoanApplication
        from apps.memberships.models import Membership

        active_cycle = (
            ContributionCycle.objects.filter(chama=chama, status="open")
            .order_by("-start_date")
            .first()
        )
        contributions_cycle = ReportRepository.contribution_summary(chama)
        user_summary = ReportRepository.member_financial_summary(chama, user)
        current_score = CreditScoringService.get_current_score(user, chama)

        return {
            "member_count": Membership.objects.filter(chama=chama).count(),
            "active_cycle": active_cycle.name if active_cycle else None,
            "contributions_this_cycle": contributions_cycle["total_amount"],
            "outstanding_loans": ReportRepository.loan_summary(chama)[
                "outstanding_balance"
            ],
            "pending_loan_applications": LoanApplication.objects.filter(
                chama=chama, status=PENDING
            ).count(),
            "user_summary": {
                "contributions_paid": user_summary["contributions_total"],
                "active_loans": user_summary["active_loans"],
                "credit_score": current_score.score if current_score else None,
            },
        }

    @staticmethod
    def export_report(report_type, chama, export_format, **kwargs):
        builders = {
            "contributions": ReportService.get_contributions_report,
            "loans": ReportService.get_loans_report,
            "repayments": ReportService.get_repayments_report,
            "financial": ReportService.get_financial_report,
            "monthly": ReportService.get_monthly_report,
        }
        if report_type not in builders:
            raise DomainError("Invalid report type.")

        data = builders[report_type](chama, **kwargs)

        if export_format == "csv":
            return ReportService._export_csv(report_type, data)
        if export_format == "pdf":
            return ReportService._export_pdf(report_type, data)
        raise DomainError("Unsupported export format. Use csv or pdf.")

    @staticmethod
    def _export_csv(report_type, data):
        buffer = io.StringIO()
        writer = csv.writer(buffer)
        writer.writerow(["report_type", report_type])
        for key, value in data.items():
            if isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    writer.writerow([f"{key}.{sub_key}", sub_value])
            else:
                writer.writerow([key, value])

        response = HttpResponse(buffer.getvalue(), content_type="text/csv")
        response["Content-Disposition"] = f'attachment; filename="{report_type}.csv"'
        return response

    @staticmethod
    def _export_pdf(report_type, data):
        try:
            from reportlab.lib.pagesizes import letter
            from reportlab.pdfgen import canvas
        except ImportError as exc:
            raise DomainError(
                "PDF export requires reportlab. Install reportlab package."
            ) from exc

        buffer = io.BytesIO()
        pdf = canvas.Canvas(buffer, pagesize=letter)
        pdf.setTitle(f"{report_type} report")
        y = 750
        pdf.drawString(50, y, f"ChamaPlus {report_type.title()} Report")
        y -= 30
        for key, value in data.items():
            pdf.drawString(50, y, f"{key}: {value}")
            y -= 20
            if y < 50:
                pdf.showPage()
                y = 750
        pdf.save()
        buffer.seek(0)

        response = HttpResponse(buffer.read(), content_type="application/pdf")
        response["Content-Disposition"] = f'attachment; filename="{report_type}.pdf"'
        return response
