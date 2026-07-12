from django.contrib import admin

from apps.contributions.models import Contribution, ContributionCycle


@admin.register(ContributionCycle)
class ContributionCycleAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "chama",
        "frequency",
        "contribution_amount",
        "status",
        "start_date",
        "end_date",
    )
    list_filter = ("status", "frequency", "chama")
    search_fields = ("name", "chama__name")
    readonly_fields = ("id", "created_at", "updated_at")


@admin.register(Contribution)
class ContributionAdmin(admin.ModelAdmin):
    list_display = (
        "member",
        "cycle",
        "amount",
        "currency",
        "payment_method",
        "reference",
        "recorded_by",
        "recorded_at",
    )
    list_filter = ("payment_method", "currency", "cycle__chama")
    search_fields = (
        "reference",
        "member__phone_number",
        "member__first_name",
        "member__last_name",
    )
    readonly_fields = (
        "id",
        "cycle",
        "member",
        "amount",
        "currency",
        "payment_method",
        "reference",
        "recorded_by",
        "recorded_at",
        "idempotency_key",
        "created_at",
        "updated_at",
    )

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False