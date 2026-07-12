from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.chamas.serializers import (
    ChamaCreateSerializer,
    ChamaSerializer,
    ChamaUpdateSerializer,
)
from apps.chamas.services.chama_service import ChamaService
from apps.core.responses import EnvelopeAPIView, success_response
from apps.memberships.permissions import IsChamaChairperson, IsChamaMember


@extend_schema_view(
    get=extend_schema(
        tags=["Chamas"],
        summary="List Chamas for the authenticated user",
        responses={200: ChamaSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Chamas"],
        summary="Create a new Chama",
        request=ChamaCreateSerializer,
        responses={201: ChamaSerializer},
    ),
)
class ChamaListCreateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        search = request.query_params.get("search")
        ordering = request.query_params.get("ordering", "-created_at")
        chamas = ChamaService.list_chamas_for_user(
            user=request.user,
            search=search,
            ordering=ordering,
        )
        serializer = ChamaSerializer(chamas, many=True)
        return success_response(
            data=serializer.data,
            message="Chamas retrieved successfully.",
        )

    def post(self, request):
        serializer = ChamaCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        chama = ChamaService.create_chama(request.user, serializer.validated_data)
        return success_response(
            data=ChamaSerializer(chama).data,
            message="Chama created successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Chamas"],
        summary="Retrieve Chama details",
        responses={200: ChamaSerializer},
    ),
    patch=extend_schema(
        tags=["Chamas"],
        summary="Update Chama details",
        request=ChamaUpdateSerializer,
        responses={200: ChamaSerializer},
    ),
    delete=extend_schema(
        tags=["Chamas"],
        summary="Archive Chama (soft delete)",
        responses={200: ChamaSerializer},
    ),
)
class ChamaDetailView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method in ("PATCH", "DELETE"):
            return [IsAuthenticated(), IsChamaChairperson()]
        return super().get_permissions()

    def get(self, request, pk):
        chama = ChamaService.get_chama(pk)
        return success_response(
            data=ChamaSerializer(chama).data,
            message="Chama retrieved successfully.",
        )

    def patch(self, request, pk):
        chama = ChamaService.get_chama(pk)
        serializer = ChamaUpdateSerializer(chama, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        chama = ChamaService.update_chama(chama, serializer.validated_data)
        return success_response(
            data=ChamaSerializer(chama).data,
            message="Chama updated successfully.",
        )

    def delete(self, request, pk):
        chama = ChamaService.get_chama(pk)
        chama = ChamaService.archive_chama(chama)
        return success_response(
            data=ChamaSerializer(chama).data,
            message="Chama archived successfully.",
        )
