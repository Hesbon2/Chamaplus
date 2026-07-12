from django.contrib import admin

from apps.credit_scoring.models import CreditScore


@admin.register(CreditScore)
class CreditScoreAdmin(admin.ModelAdmin):
    list_display = ("member", "chama", "score", "risk_level", "calculated_at")
    list_filter = ("risk_level", "chama", "calculated_at")
    search_fields = ("member__phone_number", "member__first_name", "member__last_name")
    readonly_fields = (
        "member",
        "chama",
        "score",
        "risk_level",
        "breakdown",
        "weights",
        "calculated_at",
        "triggered_by",
        "created_at",
        "updated_at",
    )
