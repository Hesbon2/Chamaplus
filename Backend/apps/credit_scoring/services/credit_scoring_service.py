from decimal import Decimal, ROUND_HALF_UP

from django.utils import timezone

from apps.core.exceptions import DomainError
from apps.credit_scoring.constants import (
    RISK_EXCELLENT,
    RISK_FAIR,
    RISK_GOOD,
    RISK_HIGH,
    get_credit_score_weights,
    get_risk_thresholds,
)
from apps.credit_scoring.models import CreditScore
from apps.credit_scoring.repositories.credit_score_repository import (
    CreditScoreRepository,
)
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import (
    CHAIRPERSON,
    COMMITTEE_MEMBER,
    SECRETARY,
    TREASURER,
)


class CreditScoringService:
    @staticmethod
    def _determine_risk_level(score, thresholds):
        if score >= thresholds["excellent"]:
            return RISK_EXCELLENT
        if score >= thresholds["good"]:
            return RISK_GOOD
        if score >= thresholds["fair"]:
            return RISK_FAIR
        return RISK_HIGH

    @staticmethod
    def calculate_components(member, chama):
        return {
            "contribution_consistency": CreditScoreRepository.get_contribution_consistency_score(
                member, chama
            ),
            "repayment_history": CreditScoreRepository.get_repayment_history_score(
                member, chama
            ),
            "attendance": CreditScoreRepository.get_attendance_score(member, chama),
            "membership_duration": CreditScoreRepository.get_membership_duration_score(
                member, chama
            ),
        }

    @staticmethod
    def recalculate(member, chama, triggered_by=None):
        if not MembershipService.user_is_active_member(member, chama):
            raise DomainError("Member must be an active member of this Chama.")

        weights = get_credit_score_weights()
        thresholds = get_risk_thresholds()
        components = CreditScoringService.calculate_components(member, chama)

        weighted_total = Decimal("0")
        breakdown = {}
        for key, component_score in components.items():
            weight = Decimal(str(weights.get(key, 0)))
            points = (component_score * weight).quantize(
                Decimal("0.01"), rounding=ROUND_HALF_UP
            )
            breakdown[key] = float(points)
            weighted_total += component_score * weight

        score = int(
            weighted_total.quantize(Decimal("1"), rounding=ROUND_HALF_UP)
        )
        score = max(0, min(100, score))
        risk_level = CreditScoringService._determine_risk_level(score, thresholds)

        return CreditScore.objects.create(
            member=member,
            chama=chama,
            score=score,
            risk_level=risk_level,
            breakdown=breakdown,
            weights=weights,
            calculated_at=timezone.now(),
            triggered_by=triggered_by,
        )

    @staticmethod
    def get_current_score(member, chama):
        return (
            CreditScore.objects.filter(member=member, chama=chama)
            .order_by("-calculated_at")
            .first()
        )

    @staticmethod
    def list_history(member, chama, limit=50):
        return CreditScore.objects.filter(
            member=member, chama=chama
        ).order_by("-calculated_at")[:limit]

    @staticmethod
    def can_view_member_score(viewer, member, chama):
        if viewer.id == member.id:
            return True
        return MembershipService.user_has_role(
            viewer,
            chama,
            [CHAIRPERSON, TREASURER, SECRETARY, COMMITTEE_MEMBER],
        )
