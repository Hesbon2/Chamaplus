from drf_spectacular.utils import extend_schema
from rest_framework.permissions import IsAuthenticated

from apps.core.pagination import StandardPagination
from apps.core.responses import EnvelopeAPIView, success_response
from apps.notifications.serializers import (
    NotificationSerializer,
    NotificationUpdateSerializer,
)
from apps.notifications.services.notification_service import NotificationService


class NotificationListView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Notifications"],
        summary="List notifications for the authenticated user",
        responses={200: NotificationSerializer(many=True)},
    )
    def get(self, request):
        is_read = request.query_params.get("is_read")
        ordering = request.query_params.get("ordering", "-created_at")
        notifications = NotificationService.list_for_user(
            request.user, is_read=is_read, ordering=ordering
        )
        paginator = StandardPagination()
        page = paginator.paginate_queryset(notifications, request)
        serializer = NotificationSerializer(page, many=True)
        return success_response(
            data={
                "count": paginator.page.paginator.count,
                "next": paginator.get_next_link(),
                "previous": paginator.get_previous_link(),
                "results": serializer.data,
            },
            message="Notifications retrieved successfully.",
        )


class NotificationDetailView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Notifications"],
        summary="Retrieve notification details",
        responses={200: NotificationSerializer},
    )
    def get(self, request, pk):
        notification = NotificationService.get_notification(request.user, pk)
        return success_response(
            data=NotificationSerializer(notification).data,
            message="Notification retrieved successfully.",
        )

    @extend_schema(
        tags=["Notifications"],
        summary="Mark notification as read",
        request=NotificationUpdateSerializer,
        responses={200: NotificationSerializer},
    )
    def patch(self, request, pk):
        notification = NotificationService.get_notification(request.user, pk)
        serializer = NotificationUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if serializer.validated_data.get("is_read"):
            notification = NotificationService.mark_read(notification)
        return success_response(
            data=NotificationSerializer(notification).data,
            message="Notification updated successfully.",
        )


class NotificationMarkAllReadView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Notifications"],
        summary="Mark all notifications as read",
        responses={200: None},
    )
    def post(self, request):
        count = NotificationService.mark_all_read(request.user)
        return success_response(
            data={"updated_count": count},
            message="All notifications marked as read.",
        )
