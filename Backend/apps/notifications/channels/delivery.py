class InAppChannel:
    @staticmethod
    def send(user, title, message, notification_type, metadata=None):
        from apps.notifications.models import Notification
        from apps.notifications.constants import CHANNEL_IN_APP

        return Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            channel=CHANNEL_IN_APP,
            metadata=metadata or {},
        )


class SMSChannel:
    """Future-ready SMS delivery interface."""

    @staticmethod
    def send(user, title, message, notification_type, metadata=None):
        return None


class EmailChannel:
    """Future-ready email delivery interface."""

    @staticmethod
    def send(user, title, message, notification_type, metadata=None):
        return None
