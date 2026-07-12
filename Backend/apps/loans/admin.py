from django.contrib import admin

from apps.loans.models import (
    CommitteeVote,
    LoanApplication,
    LoanProduct,
    LoanRepayment,
)


@admin.register(LoanProduct)
class LoanProductAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "chama",
        "interest_rate",
        "minimum_amount",
        "maximum_amount",
        "maximum_duration",
        "is_active",
    )
    list_filter = ("is_active", "chama")
    search_fields = ("name", "chama__name")
    readonly_fields = ("id", "created_at", "updated_at")


@admin.register(LoanApplication)
class LoanApplicationAdmin(admin.ModelAdmin):
    list_display = (
        "applicant",
        "chama",
        "loan_product",
        "requested_amount",
        "status",
        "outstanding_balance",
        "applied_at",
    )
    list_filter = ("status", "chama")
    search_fields = (
        "applicant__phone_number",
        "applicant__first_name",
        "purpose",
    )
    readonly_fields = (
        "id",
        "applicant",
        "chama",
        "loan_product",
        "created_at",
        "updated_at",
    )


@admin.register(CommitteeVote)
class CommitteeVoteAdmin(admin.ModelAdmin):
    list_display = ("loan_application", "committee_member", "decision", "created_at")
    list_filter = ("decision",)
    readonly_fields = ("id", "created_at", "updated_at")

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(LoanRepayment)
class LoanRepaymentAdmin(admin.ModelAdmin):
    list_display = (
        "loan_application",
        "amount",
        "payment_method",
        "reference",
        "payment_date",
        "recorded_by",
    )
    list_filter = ("payment_method",)
    readonly_fields = (
        "id",
        "loan_application",
        "amount",
        "currency",
        "payment_method",
        "reference",
        "payment_date",
        "recorded_by",
        "created_at",
        "updated_at",
    )

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
