from django.utils import timezone

from apps.core.exceptions import DomainError
from apps.governance.constants import COMPLETED
from apps.governance.models import MeetingMinute
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, SECRETARY


class MeetingMinuteService:
    @staticmethod
    def get_minutes(meeting):
        try:
            return MeetingMinute.objects.select_related(
                "prepared_by", "approved_by"
            ).get(meeting=meeting)
        except MeetingMinute.DoesNotExist as exc:
            raise DomainError("Meeting minutes not found.", status_code=404) from exc

    @staticmethod
    def create_minutes(meeting, prepared_by, validated_data):
        if meeting.status != COMPLETED:
            raise DomainError("Minutes can only be created for completed meetings.")

        if not MembershipService.user_has_role(
            prepared_by, meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can prepare minutes.",
                status_code=403,
            )

        if hasattr(meeting, "minutes"):
            raise DomainError("Minutes already exist for this meeting.", status_code=409)

        return MeetingMinute.objects.create(
            meeting=meeting,
            prepared_by=prepared_by,
            **validated_data,
        )

    @staticmethod
    def update_minutes(minute, user, validated_data):
        if minute.approved:
            raise DomainError("Approved minutes cannot be modified.")

        if not MembershipService.user_has_role(
            user, minute.meeting.chama, [SECRETARY, CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Secretary or Chairperson can update minutes.",
                status_code=403,
            )

        for field, value in validated_data.items():
            setattr(minute, field, value)
        minute.save()
        return minute

    @staticmethod
    def approve_minutes(minute, approver):
        if minute.approved:
            raise DomainError("Minutes are already approved.")

        if not MembershipService.user_has_role(
            approver, minute.meeting.chama, [CHAIRPERSON]
        ):
            raise DomainError(
                "Only the Chairperson can approve meeting minutes.",
                status_code=403,
            )

        minute.approved = True
        minute.approved_by = approver
        minute.approved_at = timezone.now()
        minute.save(
            update_fields=["approved", "approved_by", "approved_at", "updated_at"]
        )
        return minute
