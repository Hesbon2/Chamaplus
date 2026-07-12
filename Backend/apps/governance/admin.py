from django.contrib import admin

from apps.governance.models import Attendance, Meeting, MeetingMinute


@admin.register(Meeting)
class MeetingAdmin(admin.ModelAdmin):
    list_display = ("title", "chama", "meeting_date", "status", "meeting_type")
    list_filter = ("status", "meeting_type", "meeting_date")
    search_fields = ("title", "venue", "chama__name")


@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ("meeting", "member", "status", "arrival_time")
    list_filter = ("status",)
    search_fields = ("member__phone_number", "meeting__title")


@admin.register(MeetingMinute)
class MeetingMinuteAdmin(admin.ModelAdmin):
    list_display = ("meeting", "prepared_by", "approved", "approved_at")
    list_filter = ("approved",)
