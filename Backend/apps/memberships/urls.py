from django.urls import path

from apps.memberships.views import (
    MembershipRoleUpdateView,
    MembershipStatusUpdateView,
)

app_name = "memberships"

urlpatterns = [
    path(
        "<uuid:pk>/role/",
        MembershipRoleUpdateView.as_view(),
        name="membership-role-update",
    ),
    path(
        "<uuid:pk>/status/",
        MembershipStatusUpdateView.as_view(),
        name="membership-status-update",
    ),
]
