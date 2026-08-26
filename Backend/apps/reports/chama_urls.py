from django.urls import include, path

from apps.audit.views import ChamaAuditLogListView
from apps.reports.views import (
    ContributionsReportView,
    DashboardView,
    DefaultersReportView,
    FinancialReportView,
    LoansReportView,
    MemberFinancialReportView,
    MonthlyReportView,
    RepaymentsReportView,
    ReportExportView,
)

app_name = "chama_decision_support"

report_patterns = [
    path("contributions/", ContributionsReportView.as_view(), name="report-contributions"),
    path("loans/", LoansReportView.as_view(), name="report-loans"),
    path("repayments/", RepaymentsReportView.as_view(), name="report-repayments"),
    path("financial/", FinancialReportView.as_view(), name="report-financial"),
    path("monthly/", MonthlyReportView.as_view(), name="report-monthly"),
    path("defaulters/", DefaultersReportView.as_view(), name="report-defaulters"),
    path(
        "members/<uuid:member_id>/financial/",
        MemberFinancialReportView.as_view(),
        name="report-member-financial",
    ),
    path(
        "<str:report_type>/export/",
        ReportExportView.as_view(),
        name="report-export",
    ),
]

urlpatterns = [
    path("dashboard/", DashboardView.as_view(), name="dashboard"),
    path("audit-logs/", ChamaAuditLogListView.as_view(), name="chama-audit-logs"),
    path("reports/", include(report_patterns)),
]
