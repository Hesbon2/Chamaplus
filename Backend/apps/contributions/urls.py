from django.urls import path

from apps.contributions.views import (
    ContributionCycleCloseView,
    ContributionCycleDetailView,
    ContributionCycleListCreateView,
)

app_name = "contribution_cycles"

urlpatterns = [
    path(
        "",
        ContributionCycleListCreateView.as_view(),
        name="contribution-cycle-list-create",
    ),
    path(
        "<uuid:pk>/",
        ContributionCycleDetailView.as_view(),
        name="contribution-cycle-detail",
    ),
    path(
        "<uuid:pk>/close/",
        ContributionCycleCloseView.as_view(),
        name="contribution-cycle-close",
    ),
]
