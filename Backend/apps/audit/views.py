from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated

from apps.audit.permissions import IsPlatformAdministrator
from apps.audit.serializers import AuditLogSerializer
from apps.audit.services.audit_service import AuditService
from apps.chamas.services.chama_service import ChamaService
from apps.core.responses import EnvelopeAPIView, success_response
from apps.reports.permissions import IsChamaChairpersonForAudit


class PlatformAuditLogListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsPlatformAdministrator]

    @extend_schema(
        tags=["Audit Logs"],
        summary="List platform-wide audit logs",
        responses={200: AuditLogSerializer(many=True)},
    )
    def get(self, request):
        action = request.query_params.get("action")
        logs = AuditService.list_platform_logs(action=action)
        return success_response(
            data=AuditLogSerializer(logs, many=True).data,
            message="Audit logs retrieved successfully.",
        )


class ChamaAuditLogListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaChairpersonForAudit]

    @extend_schema(
        tags=["Audit Logs"],
        summary="List Chama-scoped audit logs",
        responses={200: AuditLogSerializer(many=True)},
    )
    def get(self, request, chama_id):
        chama = ChamaService.get_chama(chama_id)
        action = request.query_params.get("action")
        logs = AuditService.list_chama_logs(chama, action=action)
        return success_response(
            data=AuditLogSerializer(logs, many=True).data,
            message="Chama audit logs retrieved successfully.",
        )
