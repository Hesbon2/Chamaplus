from django.urls import path

from apps.loans.views import (
    CommitteeVoteListCreateView,
    LoanApplicationApproveView,
    LoanApplicationCancelView,
    LoanApplicationDetailView,
    LoanApplicationDisburseView,
    LoanApplicationListCreateView,
    LoanApplicationRejectView,
    LoanApplicationSubmitView,
    LoanRepaymentDetailView,
    LoanRepaymentListCreateView,
)

app_name = "loan_applications"

urlpatterns = [
    path("", LoanApplicationListCreateView.as_view(), name="loan-application-list-create"),
    path("<uuid:pk>/submit/", LoanApplicationSubmitView.as_view(), name="loan-application-submit"),
    path("<uuid:pk>/cancel/", LoanApplicationCancelView.as_view(), name="loan-application-cancel"),
    path("<uuid:pk>/approve/", LoanApplicationApproveView.as_view(), name="loan-application-approve"),
    path("<uuid:pk>/reject/", LoanApplicationRejectView.as_view(), name="loan-application-reject"),
    path("<uuid:pk>/disburse/", LoanApplicationDisburseView.as_view(), name="loan-application-disburse"),
    path("<uuid:loan_id>/votes/", CommitteeVoteListCreateView.as_view(), name="committee-vote-list-create"),
    path(
        "<uuid:loan_id>/repayments/",
        LoanRepaymentListCreateView.as_view(),
        name="loan-repayment-list-create",
    ),
    path(
        "<uuid:loan_id>/repayments/<uuid:pk>/",
        LoanRepaymentDetailView.as_view(),
        name="loan-repayment-detail",
    ),
    path("<uuid:pk>/", LoanApplicationDetailView.as_view(), name="loan-application-detail"),
]
