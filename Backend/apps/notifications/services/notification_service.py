from django.utils import timezone

from apps.core.integration.events import (
    EVENT_ATTENDANCE_FINALIZED,
    EVENT_COMMITTEE_VOTE_COMPLETED,
    EVENT_CONTRIBUTION_RECORDED,
    EVENT_LOAN_APPLIED,
    EVENT_LOAN_APPROVED,
    EVENT_LOAN_REJECTED,
    EVENT_REPAYMENT_RECORDED,
)
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership
from apps.notifications.channels.delivery import EmailChannel, InAppChannel, SMSChannel
from apps.notifications.constants import (
    NOTIFICATION_ATTENDANCE_FINALIZED,
    NOTIFICATION_COMMITTEE_VOTE_COMPLETED,
    NOTIFICATION_CONTRIBUTION_RECORDED,
    NOTIFICATION_LOAN_APPLIED,
    NOTIFICATION_LOAN_APPROVED,
    NOTIFICATION_LOAN_REJECTED,
    NOTIFICATION_REPAYMENT_RECORDED,
)
from apps.roles.constants import COMMITTEE_MEMBER, CHAIRPERSON


class NotificationService:
    @staticmethod
    def create(user, title, message, notification_type, metadata=None):
        notification = InAppChannel.send(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            metadata=metadata,
        )
        SMSChannel.send(user, title, message, notification_type, metadata)
        EmailChannel.send(user, title, message, notification_type, metadata)
        return notification

    @staticmethod
    def _committee_members(chama):
        return Membership.objects.filter(
            chama=chama,
            status=ACTIVE,
            role__slug__in=[COMMITTEE_MEMBER, CHAIRPERSON],
        ).select_related("user")

    @staticmethod
    def dispatch_event(event_type, actor, chama, member=None, metadata=None):
        metadata = metadata or {}
        metadata.setdefault("chama_id", str(chama.id))

        if event_type == EVENT_CONTRIBUTION_RECORDED and member:
            NotificationService.create(
                user=member,
                title="Contribution recorded",
                message="Your contribution has been recorded successfully.",
                notification_type=NOTIFICATION_CONTRIBUTION_RECORDED,
                metadata=metadata,
            )

        elif event_type == EVENT_LOAN_APPLIED and member:
            for membership in NotificationService._committee_members(chama):
                NotificationService.create(
                    user=membership.user,
                    title="New loan application",
                    message=(
                        f"A new loan application from {member.first_name} "
                        f"{member.last_name} requires review."
                    ),
                    notification_type=NOTIFICATION_LOAN_APPLIED,
                    metadata=metadata,
                )

        elif event_type == EVENT_LOAN_APPROVED and member:
            NotificationService.create(
                user=member,
                title="Loan approved",
                message="Your loan application has been approved.",
                notification_type=NOTIFICATION_LOAN_APPROVED,
                metadata=metadata,
            )

        elif event_type == EVENT_LOAN_REJECTED and member:
            NotificationService.create(
                user=member,
                title="Loan rejected",
                message="Your loan application has been rejected.",
                notification_type=NOTIFICATION_LOAN_REJECTED,
                metadata=metadata,
            )

        elif event_type == EVENT_REPAYMENT_RECORDED and member:
            NotificationService.create(
                user=member,
                title="Repayment recorded",
                message="A loan repayment has been recorded on your account.",
                notification_type=NOTIFICATION_REPAYMENT_RECORDED,
                metadata=metadata,
            )

        elif event_type == EVENT_COMMITTEE_VOTE_COMPLETED and member:
            NotificationService.create(
                user=member,
                title="Loan decision finalized",
                message="Committee voting on your loan application is complete.",
                notification_type=NOTIFICATION_COMMITTEE_VOTE_COMPLETED,
                metadata=metadata,
            )

        elif event_type == EVENT_ATTENDANCE_FINALIZED and member:
            meeting_title = metadata.get("meeting_title", "the meeting")
            NotificationService.create(
                user=member,
                title="Attendance finalized",
                message=f"Your attendance for {meeting_title} has been finalized.",
                notification_type=NOTIFICATION_ATTENDANCE_FINALIZED,
                metadata=metadata,
            )

    @staticmethod
    def list_for_user(user, is_read=None, ordering="-created_at"):
        queryset = user.notifications.all()
        if is_read is not None:
            queryset = queryset.filter(is_read=is_read.lower() == "true")
        allowed = {"created_at", "-created_at"}
        if ordering not in allowed:
            ordering = "-created_at"
        return queryset.order_by(ordering)

    @staticmethod
    def get_notification(user, notification_id):
        from apps.core.exceptions import DomainError

        try:
            return user.notifications.get(pk=notification_id)
        except Exception as exc:
            raise DomainError("Notification not found.", status_code=404) from exc

    @staticmethod
    def mark_read(notification):
        notification.is_read = True
        notification.read_at = timezone.now()
        notification.save(update_fields=["is_read", "read_at", "updated_at"])
        return notification

    @staticmethod
    def mark_all_read(user):
        return user.notifications.filter(is_read=False).update(
            is_read=True, read_at=timezone.now()
        )
