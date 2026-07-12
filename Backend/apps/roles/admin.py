from django.contrib import admin

from apps.roles.models import Role


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ("name", "slug", "is_platform_role", "created_at")
    search_fields = ("name", "slug")
    list_filter = ("is_platform_role",)
