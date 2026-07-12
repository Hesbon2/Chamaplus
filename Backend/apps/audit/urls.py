from django.urls import path

from apps.audit.views import PlatformAuditLogListView

app_name = "audit"

urlpatterns = [
    path("", PlatformAuditLogListView.as_view(), name="platform-audit-log-list"),
]
