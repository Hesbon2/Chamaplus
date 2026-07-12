from django.urls import include, path

from apps.accounts.urls import auth_urlpatterns, user_urlpatterns

urlpatterns = [
    path("auth/", include((auth_urlpatterns, "accounts"), namespace="auth")),
    path("users/", include((user_urlpatterns, "accounts"), namespace="users")),
    path("roles/", include("apps.roles.urls")),
    path("chamas/", include("apps.chamas.urls")),
    path("memberships/", include("apps.memberships.urls")),
    path("notifications/", include("apps.notifications.urls")),
    path("audit-logs/", include("apps.audit.urls")),
]
