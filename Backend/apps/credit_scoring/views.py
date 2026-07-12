from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated

from apps.chamas.services.chama_service import ChamaService
from apps.core.exceptions import DomainError
from apps.core.responses import EnvelopeAPIView, success_response
from apps.credit_scoring.serializers import CreditScoreSerializer
from apps.credit_scoring.services.credit_scoring_service import CreditScoringService
from apps.memberships.permissions import IsChamaMember
from apps.reports.permissions import IsChamaTreasurerOrChairperson


class CreditScoreListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Credit Scoring"],
        summary="List credit score history for a member",
        responses={200: CreditScoreSerializer(many=True)},
    )
    def get(self, request, chama_id, member_id):
        chama = ChamaService.get_chama(chama_id)
        from django.contrib.auth import get_user_model

        User = get_user_model()
        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        if not CreditScoringService.can_view_member_score(
            request.user, member, chama
        ):
            raise DomainError(
                "You do not have permission to view this score.",
                status_code=403,
            )

        scores = CreditScoringService.list_history(member, chama)
        return success_response(
            data=CreditScoreSerializer(scores, many=True).data,
            message="Credit score history retrieved successfully.",
        )


class CreditScoreCurrentView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Credit Scoring"],
        summary="Get current credit score for a member",
        responses={200: CreditScoreSerializer},
    )
    def get(self, request, chama_id, member_id):
        chama = ChamaService.get_chama(chama_id)
        from django.contrib.auth import get_user_model

        User = get_user_model()
        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        if not CreditScoringService.can_view_member_score(
            request.user, member, chama
        ):
            raise DomainError(
                "You do not have permission to view this score.",
                status_code=403,
            )

        score = CreditScoringService.get_current_score(member, chama)
        if not score:
            raise DomainError("No credit score calculated yet.", status_code=404)
        return success_response(
            data=CreditScoreSerializer(score).data,
            message="Current credit score retrieved successfully.",
        )


class CreditScoreRecalculateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurerOrChairperson]

    @extend_schema(
        tags=["Credit Scoring"],
        summary="Recalculate credit score for a member",
        responses={200: CreditScoreSerializer},
    )
    def post(self, request, chama_id, member_id):
        chama = ChamaService.get_chama(chama_id)
        from django.contrib.auth import get_user_model

        User = get_user_model()
        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        score = CreditScoringService.recalculate(
            member=member, chama=chama, triggered_by=request.user
        )
        return success_response(
            data=CreditScoreSerializer(score).data,
            message="Credit score recalculated successfully.",
        )
