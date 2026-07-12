from django.urls import include, path

from apps.accounts.urls import auth_urlpatterns, user_urlpatterns

urlpatterns = [
    path("auth/", include((auth_urlpatterns, "accounts"), namespace="auth")),
    path("users/", include((user_urlpatterns, "accounts"), namespace="users")),
    path("roles/", include("apps.roles.urls")),
]
