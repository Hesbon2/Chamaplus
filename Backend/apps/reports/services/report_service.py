import csv
import io

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
        "defaulters": "_defaulters_report",
    }

    VALID_DEFAULTER_TYPES = {"all", "contribution", "loan"}

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
    def get_defaulters_report(chama, cycle_id=None, defaulter_type="all", **_kwargs):
        defaulter_type = (defaulter_type or "all").lower()
        if defaulter_type not in ReportService.VALID_DEFAULTER_TYPES:
            raise DomainError(
                "Invalid defaulter type. Use all, contribution, or loan."
            )
        return ReportRepository.defaulters_report(
            chama, cycle_id=cycle_id, defaulter_type=defaulter_type
        )

    @staticmethod
    def get_dashboard(chama, user):
        from apps.contributions.models import ContributionCycle
        from apps.loans.constants import DISBURSED, PENDING
        from apps.loans.models import LoanApplication
        from apps.memberships.models import Membership

        from apps.governance.services.meeting_service import MeetingService

        active_cycle = (
            ContributionCycle.objects.filter(chama=chama, status="open")
            .order_by("-start_date")
            .first()
        )
        next_meeting = MeetingService.get_next_meeting(chama)
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
            "completed_meetings": MeetingService.list_meetings(
                chama, status="completed"
            ).count(),
            "next_meeting": (
                {
                    "id": str(next_meeting.id),
                    "title": next_meeting.title,
                    "meeting_date": str(next_meeting.meeting_date),
                    "start_time": str(next_meeting.start_time),
                }
                if next_meeting
                else None
            ),
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
            "defaulters": ReportService.get_defaulters_report,
        }
        if report_type not in builders:
            raise DomainError("Invalid report type.")

        # Strip kwargs that do not apply to the selected builder.
        if report_type == "defaulters":
            kwargs = {
                k: v
                for k, v in kwargs.items()
                if k in ("cycle_id", "defaulter_type")
            }
        elif report_type == "monthly":
            kwargs = {
                k: v for k, v in kwargs.items() if k in ("year", "month")
            }
        elif report_type == "contributions":
            kwargs = {
                k: v
                for k, v in kwargs.items()
                if k in ("date_from", "date_to", "cycle_id")
            }
        else:
            kwargs = {
                k: v
                for k, v in kwargs.items()
                if k in ("date_from", "date_to")
            }

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

        rows = data.get("defaulters") if isinstance(data, dict) else None
        summary = (
            {k: v for k, v in data.items() if k != "defaulters"}
            if isinstance(data, dict)
            else data
        )

        for key, value in summary.items():
            if isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    writer.writerow([f"{key}.{sub_key}", sub_value])
            else:
                writer.writerow([key, value])

        if isinstance(rows, list) and rows:
            writer.writerow([])
            headers = list(rows[0].keys())
            writer.writerow(headers)
            for row in rows:
                writer.writerow([row.get(h, "") for h in headers])

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

        rows = data.get("defaulters") if isinstance(data, dict) else None
        summary = (
            {k: v for k, v in data.items() if k != "defaulters"}
            if isinstance(data, dict)
            else data
        )

        for key, value in summary.items():
            pdf.drawString(50, y, f"{key}: {value}")
            y -= 20
            if y < 50:
                pdf.showPage()
                y = 750

        if isinstance(rows, list) and rows:
            y -= 10
            pdf.drawString(50, y, "Defaulters")
            y -= 20
            for row in rows:
                line = (
                    f"{row.get('full_name')} | {row.get('type')} | "
                    f"{row.get('phone_number')}"
                )
                if row.get("type") == "contribution":
                    line += (
                        f" | {row.get('cycle_name')} | "
                        f"expected {row.get('expected_amount')}"
                    )
                else:
                    line += (
                        f" | outstanding {row.get('outstanding_balance')} | "
                        f"due {row.get('due_date')}"
                    )
                pdf.drawString(50, y, line[:110])
                y -= 18
                if y < 50:
                    pdf.showPage()
                    y = 750

        pdf.save()
        buffer.seek(0)

        response = HttpResponse(buffer.read(), content_type="application/pdf")
        response["Content-Disposition"] = f'attachment; filename="{report_type}.pdf"'
        return response
