from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.contributions.permissions import (
    IsChamaTreasurer,
    IsChamaTreasurerOrChairperson,
)
from apps.contributions.serializers import (
    ContributionCreateSerializer,
    ContributionCycleCreateSerializer,
    ContributionCycleSerializer,
    ContributionCycleUpdateSerializer,
    ContributionSerializer,
)
from apps.contributions.services.contribution_cycle_service import (
    ContributionCycleService,
)
from apps.contributions.services.contribution_service import ContributionService
from apps.core.pagination import StandardPagination
from apps.core.responses import EnvelopeAPIView, success_response
from apps.memberships.permissions import IsChamaMember


@extend_schema_view(
    get=extend_schema(
        tags=["Contribution Cycles"],
        summary="List contribution cycles for a Chama",
        responses={200: ContributionCycleSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Contribution Cycles"],
        summary="Create a contribution cycle",
        request=ContributionCycleCreateSerializer,
        responses={201: ContributionCycleSerializer},
    ),
)
class ContributionCycleListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method == "POST":
            return [IsAuthenticated(), IsChamaTreasurerOrChairperson()]
        return super().get_permissions()

    def get(self, request, chama_id):
        chama = ContributionCycleService.get_chama(chama_id)
        search = request.query_params.get("search")
        status_filter = request.query_params.get("status")
        ordering = request.query_params.get("ordering", "-start_date")
        cycles = ContributionCycleService.list_cycles(
            chama=chama,
            search=search,
            status=status_filter,
            ordering=ordering,
        )
        serializer = ContributionCycleSerializer(cycles, many=True)
        return success_response(
            data=serializer.data,
            message="Contribution cycles retrieved successfully.",
        )

    def post(self, request, chama_id):
        chama = ContributionCycleService.get_chama(chama_id)
        serializer = ContributionCycleCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        cycle = ContributionCycleService.create_cycle(
            chama, serializer.validated_data
        )
        return success_response(
            data=ContributionCycleSerializer(cycle).data,
            message="Contribution cycle created successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Contribution Cycles"],
        summary="Retrieve contribution cycle details",
        responses={200: ContributionCycleSerializer},
    ),
    patch=extend_schema(
        tags=["Contribution Cycles"],
        summary="Update a contribution cycle",
        request=ContributionCycleUpdateSerializer,
        responses={200: ContributionCycleSerializer},
    ),
    delete=extend_schema(
        tags=["Contribution Cycles"],
        summary="Delete an open contribution cycle",
        responses={200: None},
    ),
)
class ContributionCycleDetailView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method in ("PATCH", "DELETE"):
            return [IsAuthenticated(), IsChamaTreasurer()]
        return super().get_permissions()

    def get(self, request, chama_id, pk):
        chama = ContributionCycleService.get_chama(chama_id)
        cycle = ContributionCycleService.get_cycle(chama, pk)
        return success_response(
            data=ContributionCycleSerializer(cycle).data,
            message="Contribution cycle retrieved successfully.",
        )

    def patch(self, request, chama_id, pk):
        chama = ContributionCycleService.get_chama(chama_id)
        cycle = ContributionCycleService.get_cycle(chama, pk)
        serializer = ContributionCycleUpdateSerializer(
            cycle, data=request.data, partial=True
        )
        serializer.is_valid(raise_exception=True)
        cycle = ContributionCycleService.update_cycle(cycle, serializer.validated_data)
        return success_response(
            data=ContributionCycleSerializer(cycle).data,
            message="Contribution cycle updated successfully.",
        )

    def delete(self, request, chama_id, pk):
        chama = ContributionCycleService.get_chama(chama_id)
        cycle = ContributionCycleService.get_cycle(chama, pk)
        ContributionCycleService.delete_cycle(cycle)
        return success_response(
            data=None,
            message="Contribution cycle deleted successfully.",
        )


@extend_schema(
    tags=["Contribution Cycles"],
    summary="Close a contribution cycle",
    responses={200: ContributionCycleSerializer},
)
class ContributionCycleCloseView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurer]

    def post(self, request, chama_id, pk):
        chama = ContributionCycleService.get_chama(chama_id)
        cycle = ContributionCycleService.get_cycle(chama, pk)
        cycle = ContributionCycleService.close_cycle(cycle)
        return success_response(
            data=ContributionCycleSerializer(cycle).data,
            message="Contribution cycle closed successfully.",
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Contributions"],
        summary="List contributions for a Chama",
        responses={200: ContributionSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Contributions"],
        summary="Record a member contribution",
        request=ContributionCreateSerializer,
        responses={201: ContributionSerializer},
    ),
)
class ContributionListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method == "POST":
            return [IsAuthenticated(), IsChamaTreasurer()]
        return super().get_permissions()

    def get(self, request, chama_id):
        chama = ContributionCycleService.get_chama(chama_id)
        member_id = request.query_params.get("member_id")
        cycle_id = request.query_params.get("cycle_id")
        search = request.query_params.get("search")
        ordering = request.query_params.get("ordering", "-recorded_at")

        contributions = ContributionService.list_contributions(
            chama=chama,
            member_id=member_id,
            cycle_id=cycle_id,
            search=search,
            ordering=ordering,
        )

        paginator = StandardPagination()
        page = paginator.paginate_queryset(contributions, request)
        serializer = ContributionSerializer(page, many=True)
        return success_response(
            data={
                "count": paginator.page.paginator.count,
                "next": paginator.get_next_link(),
                "previous": paginator.get_previous_link(),
                "results": serializer.data,
            },
            message="Contributions retrieved successfully.",
        )

    def post(self, request, chama_id):
        chama = ContributionCycleService.get_chama(chama_id)
        serializer = ContributionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        contribution = ContributionService.record_contribution(
            chama=chama,
            recorded_by=request.user,
            validated_data=serializer.validated_data,
        )
        return success_response(
            data=ContributionSerializer(contribution).data,
            message="Contribution recorded successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema(
    tags=["Contributions"],
    summary="Retrieve contribution details",
    responses={200: ContributionSerializer},
)
class ContributionDetailView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    def get(self, request, chama_id, pk):
        chama = ContributionCycleService.get_chama(chama_id)
        contribution = ContributionService.get_contribution(chama, pk)
        return success_response(
            data=ContributionSerializer(contribution).data,
            message="Contribution retrieved successfully.",
        )
