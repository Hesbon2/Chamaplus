from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.core.responses import EnvelopeAPIView, success_response
from apps.governance.permissions import IsChamaSecretaryOrChairperson
from apps.governance.serializers import (
    AttendanceBulkCreateSerializer,
    AttendanceCreateSerializer,
    AttendanceListItemSerializer,
    AttendanceSerializer,
    AttendanceUpdateSerializer,
    MeetingCreateSerializer,
    MeetingMinuteCreateSerializer,
    MeetingMinuteSerializer,
    MeetingMinuteUpdateSerializer,
    MeetingSerializer,
    MeetingUpdateSerializer,
)
from apps.governance.services.attendance_service import AttendanceService
from apps.governance.services.meeting_minute_service import MeetingMinuteService
from apps.governance.services.meeting_service import MeetingService
from apps.memberships.permissions import IsChamaMember


@extend_schema_view(
    get=extend_schema(
        tags=["Meetings"],
        summary="List meetings for a Chama",
        responses={200: MeetingSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Meetings"],
        summary="Schedule a meeting",
        request=MeetingCreateSerializer,
        responses={201: MeetingSerializer},
    ),
)
class MeetingListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        return [IsAuthenticated(), IsChamaSecretaryOrChairperson()]

    def get(self, request, chama_id):
        chama = MeetingService.get_chama(chama_id)
        meetings = MeetingService.list_meetings(
            chama,
            status=request.query_params.get("status"),
            search=request.query_params.get("search"),
            ordering=request.query_params.get("ordering", "-meeting_date"),
        )
        return success_response(
            data=MeetingSerializer(meetings, many=True).data,
            message="Meetings retrieved successfully.",
        )

    def post(self, request, chama_id):
        chama = MeetingService.get_chama(chama_id)
        serializer = MeetingCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        meeting = MeetingService.create_meeting(
            chama, request.user, serializer.validated_data
        )
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting scheduled successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Meetings"],
        summary="Retrieve meeting details",
        responses={200: MeetingSerializer},
    ),
    patch=extend_schema(
        tags=["Meetings"],
        summary="Update a meeting",
        request=MeetingUpdateSerializer,
        responses={200: MeetingSerializer},
    ),
    delete=extend_schema(
        tags=["Meetings"],
        summary="Cancel a meeting",
        responses={200: MeetingSerializer},
    ),
)
class MeetingDetailView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        return [IsAuthenticated(), IsChamaSecretaryOrChairperson()]

    def get(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting retrieved successfully.",
        )

    def patch(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        serializer = MeetingUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        meeting = MeetingService.update_meeting(
            meeting, request.user, serializer.validated_data
        )
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting updated successfully.",
        )

    def delete(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        meeting = MeetingService.cancel_meeting(meeting, request.user)
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting cancelled successfully.",
        )


class MeetingStartView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaSecretaryOrChairperson]

    @extend_schema(
        tags=["Meetings"],
        summary="Mark meeting as ongoing",
        responses={200: MeetingSerializer},
    )
    def post(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        meeting = MeetingService.start_meeting(meeting, request.user)
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting started successfully.",
        )


class MeetingCloseView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaSecretaryOrChairperson]

    @extend_schema(
        tags=["Meetings"],
        summary="Close meeting and finalize attendance",
        responses={200: MeetingSerializer},
    )
    def post(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        meeting = MeetingService.close_meeting(meeting, request.user)
        return success_response(
            data=MeetingSerializer(meeting).data,
            message="Meeting closed and attendance finalized successfully.",
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Attendance"],
        summary="List attendance for active members",
        responses={200: AttendanceListItemSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Attendance"],
        summary="Record attendance (single or bulk)",
        request=AttendanceBulkCreateSerializer,
        responses={201: AttendanceSerializer(many=True)},
    ),
)
class AttendanceListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        return [IsAuthenticated(), IsChamaSecretaryOrChairperson()]

    def get(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        data = AttendanceService.list_attendance(meeting)
        return success_response(
            data=AttendanceListItemSerializer(data, many=True).data,
            message="Attendance list retrieved successfully.",
        )

    def post(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)

        if "records" in request.data:
            serializer = AttendanceBulkCreateSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            records = AttendanceService.bulk_record_attendance(
                meeting, request.user, serializer.validated_data["records"]
            )
            return success_response(
                data=AttendanceSerializer(records, many=True).data,
                message="Attendance recorded successfully.",
                status_code=status.HTTP_201_CREATED,
            )

        serializer = AttendanceCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        record = AttendanceService.record_attendance(
            meeting, request.user, serializer.validated_data
        )
        return success_response(
            data=AttendanceSerializer(record).data,
            message="Attendance recorded successfully.",
            status_code=status.HTTP_201_CREATED,
        )


class AttendanceDetailView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaSecretaryOrChairperson]

    @extend_schema(
        tags=["Attendance"],
        summary="Update attendance record",
        request=AttendanceUpdateSerializer,
        responses={200: AttendanceSerializer},
    )
    def patch(self, request, chama_id, pk, attendance_id):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        attendance = AttendanceService.get_attendance(meeting, attendance_id)
        serializer = AttendanceUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        attendance = AttendanceService.update_attendance(
            attendance, request.user, serializer.validated_data
        )
        return success_response(
            data=AttendanceSerializer(attendance).data,
            message="Attendance updated successfully.",
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Meeting Minutes"],
        summary="Retrieve meeting minutes",
        responses={200: MeetingMinuteSerializer},
    ),
    post=extend_schema(
        tags=["Meeting Minutes"],
        summary="Create meeting minutes",
        request=MeetingMinuteCreateSerializer,
        responses={201: MeetingMinuteSerializer},
    ),
    patch=extend_schema(
        tags=["Meeting Minutes"],
        summary="Update meeting minutes",
        request=MeetingMinuteUpdateSerializer,
        responses={200: MeetingMinuteSerializer},
    ),
)
class MeetingMinuteView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        return [IsAuthenticated(), IsChamaSecretaryOrChairperson()]

    def get(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        minutes = MeetingMinuteService.get_minutes(meeting)
        return success_response(
            data=MeetingMinuteSerializer(minutes).data,
            message="Meeting minutes retrieved successfully.",
        )

    def post(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        serializer = MeetingMinuteCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        minutes = MeetingMinuteService.create_minutes(
            meeting, request.user, serializer.validated_data
        )
        return success_response(
            data=MeetingMinuteSerializer(minutes).data,
            message="Meeting minutes created successfully.",
            status_code=status.HTTP_201_CREATED,
        )

    def patch(self, request, chama_id, pk):
        chama = MeetingService.get_chama(chama_id)
        meeting = MeetingService.get_meeting(chama, pk)
        minutes = MeetingMinuteService.get_minutes(meeting)
        serializer = MeetingMinuteUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        minutes = MeetingMinuteService.update_minutes(
            minutes, request.user, serializer.validated_data
        )
        return success_response(
            data=MeetingMinuteSerializer(minutes).data,
            message="Meeting minutes updated successfully.",
        )


class MeetingMinuteApproveView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    @extend_schema(
        tags=["Meeting Minutes"],
        summary="Approve meeting minutes",
        responses={200: MeetingMinuteSerializer},
    )
    def post(self, request, chama_id, pk):
        from apps.memberships.services.membership_service import MembershipService
        from apps.roles.constants import CHAIRPERSON

        chama = MeetingService.get_chama(chama_id)
        if not MembershipService.user_has_role(request.user, chama, [CHAIRPERSON]):
            from apps.core.exceptions import DomainError

            raise DomainError(
                "Only the Chairperson can approve meeting minutes.",
                status_code=403,
            )

        meeting = MeetingService.get_meeting(chama, pk)
        minutes = MeetingMinuteService.get_minutes(meeting)
        minutes = MeetingMinuteService.approve_minutes(minutes, request.user)
        return success_response(
            data=MeetingMinuteSerializer(minutes).data,
            message="Meeting minutes approved successfully.",
        )
