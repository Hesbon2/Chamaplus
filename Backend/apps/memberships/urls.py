from django.urls import path

from apps.memberships.views import (
    MembershipAcceptInvitationView,
    MembershipDeclineInvitationView,
    MembershipRoleUpdateView,
    MembershipStatusUpdateView,
    PendingInvitationsListView,
)

app_name = "memberships"

urlpatterns = [
    path(
        "pending/",
        PendingInvitationsListView.as_view(),
        name="membership-pending-list",
    ),
    path(
        "<uuid:pk>/accept/",
        MembershipAcceptInvitationView.as_view(),
        name="membership-accept-invitation",
    ),
    path(
        "<uuid:pk>/decline/",
        MembershipDeclineInvitationView.as_view(),
        name="membership-decline-invitation",
    ),
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
