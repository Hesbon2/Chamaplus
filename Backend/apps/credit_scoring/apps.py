from django.apps import AppConfig


class CreditScoringConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.credit_scoring"
    label = "credit_scoring"
    verbose_name = "Credit Scoring"
