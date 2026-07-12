from django.conf import settings

DEFAULT_CREDIT_SCORE_WEIGHTS = {
    "contribution_consistency": 0.35,
    "repayment_history": 0.35,
    "attendance": 0.15,
    "membership_duration": 0.15,
}

DEFAULT_RISK_THRESHOLDS = {
    "excellent": 80,
    "good": 60,
    "fair": 40,
}

RISK_EXCELLENT = "excellent"
RISK_GOOD = "good"
RISK_FAIR = "fair"
RISK_HIGH = "high_risk"

RISK_LEVEL_CHOICES = (
    (RISK_EXCELLENT, "Excellent"),
    (RISK_GOOD, "Good"),
    (RISK_FAIR, "Fair"),
    (RISK_HIGH, "High Risk"),
)


def get_credit_score_weights():
    return getattr(settings, "CREDIT_SCORE_WEIGHTS", DEFAULT_CREDIT_SCORE_WEIGHTS)


def get_risk_thresholds():
    return getattr(settings, "CREDIT_SCORE_RISK_THRESHOLDS", DEFAULT_RISK_THRESHOLDS)
