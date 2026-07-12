from django.contrib import admin

from apps.chamas.models import Chama


@admin.register(Chama)
class ChamaAdmin(admin.ModelAdmin):
    list_display = ("name", "location", "currency", "is_active", "created_by", "created_at")
    search_fields = ("name", "location", "invite_code")
    list_filter = ("is_active", "currency")
