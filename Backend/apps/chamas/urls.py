from django.urls import include, path

from apps.chamas.views import ChamaDetailView, ChamaListCreateView
from apps.memberships.views import InviteMemberView, JoinChamaView, MemberListView

app_name = "chamas"

urlpatterns = [
    path("", ChamaListCreateView.as_view(), name="chama-list-create"),
    path("join/", JoinChamaView.as_view(), name="chama-join"),
    path("<uuid:pk>/", ChamaDetailView.as_view(), name="chama-detail"),
    path("<uuid:pk>/invite/", InviteMemberView.as_view(), name="chama-invite"),
    path("<uuid:pk>/members/", MemberListView.as_view(), name="chama-members"),
    path(
        "<uuid:chama_id>/contribution-cycles/",
        include("apps.contributions.urls"),
    ),
    path(
        "<uuid:chama_id>/contributions/",
        include("apps.contributions.contribution_urls"),
    ),
    path(
        "<uuid:chama_id>/loan-products/",
        include("apps.loans.product_urls"),
    ),
    path(
        "<uuid:chama_id>/loan-applications/",
        include("apps.loans.application_urls"),
    ),
]
