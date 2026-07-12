from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.chamas.services.chama_service import ChamaService
from apps.core.pagination import StandardPagination
from apps.core.responses import EnvelopeAPIView, success_response
from apps.memberships.models import Membership
from apps.memberships.permissions import (
    IsChamaMember,
    IsChamaOfficial,
    IsMembershipChairperson,
)
from apps.memberships.serializers import (
    InviteMemberSerializer,
    JoinChamaSerializer,
    MembershipRoleUpdateSerializer,
    MembershipSerializer,
    MembershipStatusUpdateSerializer,
)
from apps.memberships.services.membership_service import MembershipService


class InviteMemberView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaOfficial]

    @extend_schema(
        tags=["Memberships"],
        summary="Invite a member to a Chama by phone number",
        request=InviteMemberSerializer,
        responses={201: MembershipSerializer},
    )
    def post(self, request, pk):
        chama = ChamaService.get_chama(pk)
        serializer = InviteMemberSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        membership = MembershipService.invite_member(
            chama=chama,
            phone_number=serializer.validated_data["phone_number"],
            role_slug=serializer.validated_data.get("role", "member"),
        )
        membership = Membership.objects.select_related("user", "role").get(
            pk=membership.pk
        )
        return success_response(
            data=MembershipSerializer(membership).data,
            message="Member invited successfully.",
            status_code=status.HTTP_201_CREATED,
        )


class JoinChamaView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Memberships"],
        summary="Join a Chama using an invite code",
        request=JoinChamaSerializer,
        responses={200: MembershipSerializer},
    )
    def post(self, request):
        serializer = JoinChamaSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        membership = MembershipService.join_chama(
            user=request.user,
            invite_code=serializer.validated_data["invite_code"],
        )
        membership = Membership.objects.select_related("user", "role").get(
            pk=membership.pk
        )
        return success_response(
            data=MembershipSerializer(membership).data,
            message="Joined Chama successfully.",
        )


class MemberListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Memberships"],
        summary="List members of a Chama",
        responses={200: MembershipSerializer(many=True)},
    )
    def get(self, request, pk):
        chama = ChamaService.get_chama(pk)
        search = request.query_params.get("search")
        status_filter = request.query_params.get("status")
        ordering = request.query_params.get("ordering", "-created_at")

        members = MembershipService.list_members(
            chama=chama,
            search=search,
            status=status_filter,
            ordering=ordering,
        )

        paginator = StandardPagination()
        page = paginator.paginate_queryset(members, request)
        serializer = MembershipSerializer(page, many=True)
        return success_response(
            data={
                "count": paginator.page.paginator.count,
                "next": paginator.get_next_link(),
                "previous": paginator.get_previous_link(),
                "results": serializer.data,
            },
            message="Members retrieved successfully.",
        )


class MembershipRoleUpdateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsMembershipChairperson]

    @extend_schema(
        tags=["Memberships"],
        summary="Update a member's role",
        request=MembershipRoleUpdateSerializer,
        responses={200: MembershipSerializer},
    )
    def patch(self, request, pk):
        membership = MembershipService.get_membership(pk)
        serializer = MembershipRoleUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        membership = MembershipService.update_role(
            membership, serializer.validated_data["role"]
        )
        return success_response(
            data=MembershipSerializer(membership).data,
            message="Member role updated successfully.",
        )


class MembershipStatusUpdateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsMembershipChairperson]

    @extend_schema(
        tags=["Memberships"],
        summary="Update a member's status",
        request=MembershipStatusUpdateSerializer,
        responses={200: MembershipSerializer},
    )
    def patch(self, request, pk):
        membership = MembershipService.get_membership(pk)
        serializer = MembershipStatusUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        membership = MembershipService.update_status(
            membership, serializer.validated_data["status"]
        )
        return success_response(
            data=MembershipSerializer(membership).data,
            message="Member status updated successfully.",
        )