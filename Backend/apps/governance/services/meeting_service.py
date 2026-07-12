from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from apps.chamas.services.chama_service import ChamaService
from apps.core.exceptions import DomainError
from apps.governance.constants import (
    CANCELLED,
    COMPLETED,
    ONGOING,
    OPEN_MEETING_STATUSES,
    SCHEDULED,
)
from apps.governance.models import Meeting
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, SECRETARY

User = get_user_model()


class MeetingService:
    @staticmethod
    def get_chama(chama_id):
        return ChamaService.get_chama(chama_id)

    @staticmethod
    def create_meeting(chama, created_by, validated_data):
        if not MembershipService.user_has_role(
            created_by, chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can schedule meetings.",
                status_code=403,
            )

        return Meeting.objects.create(
            chama=chama,
            created_by=created_by,
            **validated_data,
        )

    @staticmethod
    def list_meetings(chama, status=None, search=None, ordering="-meeting_date"):
        queryset = Meeting.objects.filter(chama=chama).select_related("created_by")

        if status:
            queryset = queryset.filter(status=status)

        if search:
            queryset = queryset.filter(
                Q(title__icontains=search)
                | Q(description__icontains=search)
                | Q(venue__icontains=search)
            )

        allowed_ordering = {
            "meeting_date",
            "-meeting_date",
            "created_at",
            "-created_at",
            "start_time",
            "-start_time",
        }
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_meeting(chama, meeting_id):
        try:
            return Meeting.objects.select_related("created_by").get(
                pk=meeting_id, chama=chama
            )
        except Meeting.DoesNotExist as exc:
            raise DomainError("Meeting not found.", status_code=404) from exc

    @staticmethod
    def update_meeting(meeting, user, validated_data):
        if not MembershipService.user_has_role(
            user, meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can update meetings.",
                status_code=403,
            )

        if meeting.status not in OPEN_MEETING_STATUSES:
            raise DomainError("Only scheduled or ongoing meetings can be updated.")

        for field, value in validated_data.items():
            setattr(meeting, field, value)
        meeting.save()
        return meeting

    @staticmethod
    def cancel_meeting(meeting, user):
        if not MembershipService.user_has_role(
            user, meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can cancel meetings.",
                status_code=403,
            )

        if meeting.status not in OPEN_MEETING_STATUSES:
            raise DomainError("Only scheduled or ongoing meetings can be cancelled.")

        meeting.status = CANCELLED
        meeting.save(update_fields=["status", "updated_at"])
        return meeting

    @staticmethod
    def start_meeting(meeting, user):
        if meeting.status != SCHEDULED:
            raise DomainError("Only scheduled meetings can be started.")

        if not MembershipService.user_has_role(
            user, meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can start meetings.",
                status_code=403,
            )

        meeting.status = ONGOING
        meeting.save(update_fields=["status", "updated_at"])
        return meeting

    @staticmethod
    def _active_member_count(chama):
        return Membership.objects.filter(chama=chama, status=ACTIVE).count()

    @staticmethod
    def close_meeting(meeting, user):
        if meeting.status not in (SCHEDULED, ONGOING):
            raise DomainError("Only scheduled or ongoing meetings can be closed.")

        if not MembershipService.user_has_role(
            user, meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can close meetings.",
                status_code=403,
            )

        active_count = MeetingService._active_member_count(meeting.chama)
        recorded_count = meeting.attendance_records.count()
        if recorded_count < active_count:
            raise DomainError(
                "Attendance must be recorded for all active members before closing.",
                status_code=400,
            )

        with transaction.atomic():
            meeting.status = COMPLETED
            meeting.attendance_finalized = True
            meeting.save(
                update_fields=["status", "attendance_finalized", "updated_at"]
            )

        from apps.governance.services.attendance_service import AttendanceService

        AttendanceService.dispatch_attendance_finalized(meeting, user)
        return meeting

    @staticmethod
    def get_next_meeting(chama):
        today = timezone.localdate()
        return (
            Meeting.objects.filter(
                chama=chama,
                status__in=(SCHEDULED, ONGOING),
                meeting_date__gte=today,
            )
            .order_by("meeting_date", "start_time")
            .first()
        )
