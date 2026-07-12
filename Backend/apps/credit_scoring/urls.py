from django.urls import path

from apps.credit_scoring.views import (
    CreditScoreCurrentView,
    CreditScoreListView,
    CreditScoreRecalculateView,
)

app_name = "credit_scoring"

urlpatterns = [
    path("", CreditScoreListView.as_view(), name="credit-score-list"),
    path("current/", CreditScoreCurrentView.as_view(), name="credit-score-current"),
    path(
        "recalculate/",
        CreditScoreRecalculateView.as_view(),
        name="credit-score-recalculate",
    ),
]
