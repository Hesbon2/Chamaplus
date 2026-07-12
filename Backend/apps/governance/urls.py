from django.urls import include, path

from apps.governance.views import (
    AttendanceDetailView,
    AttendanceListCreateView,
    MeetingCloseView,
    MeetingDetailView,
    MeetingListCreateView,
    MeetingMinuteApproveView,
    MeetingMinuteView,
    MeetingStartView,
)

app_name = "governance"

meeting_detail_patterns = [
    path("", MeetingDetailView.as_view(), name="meeting-detail"),
    path("start/", MeetingStartView.as_view(), name="meeting-start"),
    path("close/", MeetingCloseView.as_view(), name="meeting-close"),
    path(
        "attendance/",
        AttendanceListCreateView.as_view(),
        name="attendance-list-create",
    ),
    path(
        "attendance/<uuid:attendance_id>/",
        AttendanceDetailView.as_view(),
        name="attendance-detail",
    ),
    path("minutes/", MeetingMinuteView.as_view(), name="meeting-minutes"),
    path(
        "minutes/approve/",
        MeetingMinuteApproveView.as_view(),
        name="meeting-minutes-approve",
    ),
]

urlpatterns = [
    path("", MeetingListCreateView.as_view(), name="meeting-list-create"),
    path("<uuid:pk>/", include(meeting_detail_patterns)),
]
