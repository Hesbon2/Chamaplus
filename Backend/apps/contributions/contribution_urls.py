from django.urls import path

from apps.contributions.views import (
    ContributionDetailView,
    ContributionListCreateView,
)

app_name = "contributions"

urlpatterns = [
    path(
        "",
        ContributionListCreateView.as_view(),
        name="contribution-list-create",
    ),
    path(
        "<uuid:pk>/",
        ContributionDetailView.as_view(),
        name="contribution-detail",
    ),
]
