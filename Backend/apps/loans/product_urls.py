from django.urls import path

from apps.loans.views import LoanProductDetailView, LoanProductListCreateView

app_name = "loan_products"

urlpatterns = [
    path("", LoanProductListCreateView.as_view(), name="loan-product-list-create"),
    path("<uuid:pk>/", LoanProductDetailView.as_view(), name="loan-product-detail"),
]
