from django.contrib import admin

from apps.audit.models import AuditLog


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ("action", "entity_type", "actor", "chama", "created_at")
    list_filter = ("action", "entity_type", "created_at")
    search_fields = ("action", "entity_type", "actor__phone_number")
    readonly_fields = (
        "actor",
        "chama",
        "action",
        "entity_type",
        "entity_id",
        "changes",
        "ip_address",
        "created_at",
        "updated_at",
    )
