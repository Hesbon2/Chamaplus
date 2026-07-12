from django.contrib import admin

from apps.memberships.models import Membership


@admin.register(Membership)
class MembershipAdmin(admin.ModelAdmin):
    list_display = ("user", "chama", "role", "status", "joined_at", "created_at")
    search_fields = ("user__phone_number", "user__first_name", "chama__name")
    list_filter = ("status", "role")
