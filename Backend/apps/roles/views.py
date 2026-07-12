from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated

from apps.core.responses import EnvelopeAPIView, success_response
from apps.roles.models import Role
from apps.roles.serializers import RoleSerializer


class RoleListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Roles"],
        summary="List all roles",
        responses={200: RoleSerializer(many=True)},
    )
    def get(self, request):
        roles = Role.objects.all()
        serializer = RoleSerializer(roles, many=True)
        return success_response(
            data=serializer.data,
            message="Roles retrieved successfully.",
        )
