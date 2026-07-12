from django.contrib.auth import get_user_model
from django.db import transaction
from django.utils import timezone

from apps.core.exceptions import DomainError
from apps.governance.constants import OPEN_MEETING_STATUSES
from apps.governance.models import Attendance
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, SECRETARY

User = get_user_model()


class AttendanceService:
    @staticmethod
    def _can_record(user, chama):
        return MembershipService.user_has_role(user, chama, [SECRETARY, CHAIRPERSON])

    @staticmethod
    def _active_members(chama):
        return (
            Membership.objects.filter(chama=chama, status=ACTIVE)
            .select_related("user", "role")
            .order_by("user__first_name", "user__last_name")
        )

    @staticmethod
    def list_attendance(meeting):
        memberships = AttendanceService._active_members(meeting.chama)
        records = {
            record.member_id: record
            for record in meeting.attendance_records.select_related("member", "recorded_by")
        }

        results = []
        for membership in memberships:
            record = records.get(membership.user_id)
            results.append(
                {
                    "member_id": str(membership.user_id),
                    "member_name": (
                        f"{membership.user.first_name} {membership.user.last_name}".strip()
                    ),
                    "attendance_id": str(record.id) if record else None,
                    "status": record.status if record else None,
                    "arrival_time": record.arrival_time if record else None,
                    "remarks": record.remarks if record else "",
                    "recorded_by_id": (
                        str(record.recorded_by_id) if record and record.recorded_by_id else None
                    ),
                }
            )
        return results

    @staticmethod
    def record_attendance(meeting, recorded_by, validated_data):
        if meeting.status not in OPEN_MEETING_STATUSES:
            raise DomainError("Attendance can only be recorded for open meetings.")

        if not AttendanceService._can_record(recorded_by, meeting.chama):
            raise DomainError(
                "Only the Secretary or Chairperson can record attendance.",
                status_code=403,
            )

        member_id = validated_data["member_id"]
        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        if not MembershipService.user_is_active_member(member, meeting.chama):
            raise DomainError(
                "Attendance can only be recorded for active Chama members.",
                status_code=400,
            )

        if Attendance.objects.filter(meeting=meeting, member=member).exists():
            raise DomainError(
                "Attendance already recorded for this member.",
                status_code=409,
            )

        return Attendance.objects.create(
            meeting=meeting,
            member=member,
            status=validated_data["status"],
            arrival_time=validated_data.get("arrival_time"),
            remarks=validated_data.get("remarks", ""),
            recorded_by=recorded_by,
        )

    @staticmethod
    def bulk_record_attendance(meeting, recorded_by, records):
        if meeting.status not in OPEN_MEETING_STATUSES:
            raise DomainError("Attendance can only be recorded for open meetings.")

        if not AttendanceService._can_record(recorded_by, meeting.chama):
            raise DomainError(
                "Only the Secretary or Chairperson can record attendance.",
                status_code=403,
            )

        created = []
        with transaction.atomic():
            for entry in records:
                member_id = entry["member_id"]
                if Attendance.objects.filter(meeting=meeting, member_id=member_id).exists():
                    raise DomainError(
                        f"Attendance already recorded for member {member_id}.",
                        status_code=409,
                    )
                try:
                    member = User.objects.get(pk=member_id)
                except User.DoesNotExist as exc:
                    raise DomainError("Member not found.", status_code=404) from exc

                if not MembershipService.user_is_active_member(member, meeting.chama):
                    raise DomainError(
                        "Attendance can only be recorded for active Chama members.",
                        status_code=400,
                    )

                created.append(
                    Attendance.objects.create(
                        meeting=meeting,
                        member=member,
                        status=entry["status"],
                        arrival_time=entry.get("arrival_time"),
                        remarks=entry.get("remarks", ""),
                        recorded_by=recorded_by,
                    )
                )
        return created

    @staticmethod
    def update_attendance(attendance, user, validated_data):
        meeting = attendance.meeting
        if meeting.status not in OPEN_MEETING_STATUSES:
            raise DomainError("Attendance can only be updated for open meetings.")

        if not AttendanceService._can_record(user, meeting.chama):
            raise DomainError(
                "Only the Secretary or Chairperson can update attendance.",
                status_code=403,
            )

        for field, value in validated_data.items():
            setattr(attendance, field, value)
        attendance.save()
        return attendance

    @staticmethod
    def get_attendance(meeting, attendance_id):
        try:
            return Attendance.objects.select_related("member", "recorded_by").get(
                pk=attendance_id, meeting=meeting
            )
        except Attendance.DoesNotExist as exc:
            raise DomainError("Attendance record not found.", status_code=404) from exc

    @staticmethod
    def dispatch_attendance_finalized(meeting, actor):
        from apps.core.integration.decision_support import dispatch_decision_support_event
        from apps.core.integration.events import EVENT_ATTENDANCE_FINALIZED

        dispatch_decision_support_event(
            EVENT_ATTENDANCE_FINALIZED,
            actor=actor,
            chama=meeting.chama,
            entity_type="meeting",
            entity_id=meeting.id,
            changes={"title": meeting.title, "meeting_date": str(meeting.meeting_date)},
        )

        for attendance in meeting.attendance_records.select_related("member"):
            dispatch_decision_support_event(
                EVENT_ATTENDANCE_FINALIZED,
                actor=actor,
                chama=meeting.chama,
                member=attendance.member,
                entity_type="attendance",
                entity_id=attendance.id,
                changes={"status": attendance.status},
                metadata={
                    "meeting_id": str(meeting.id),
                    "meeting_title": meeting.title,
                },
            )
