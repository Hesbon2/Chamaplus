from rest_framework import serializers

from apps.governance.models import Attendance, Meeting, MeetingMinute


class MeetingSerializer(serializers.ModelSerializer):
    created_by_id = serializers.UUIDField(read_only=True, allow_null=True)

    class Meta:
        model = Meeting
        fields = (
            "id",
            "chama_id",
            "title",
            "description",
            "meeting_type",
            "venue",
            "meeting_date",
            "start_time",
            "end_time",
            "status",
            "attendance_finalized",
            "created_by_id",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "chama_id",
            "status",
            "attendance_finalized",
            "created_by_id",
            "created_at",
            "updated_at",
        )


class MeetingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Meeting
        fields = (
            "title",
            "description",
            "meeting_type",
            "venue",
            "meeting_date",
            "start_time",
            "end_time",
        )


class MeetingUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Meeting
        fields = (
            "title",
            "description",
            "meeting_type",
            "venue",
            "meeting_date",
            "start_time",
            "end_time",
        )


class AttendanceSerializer(serializers.ModelSerializer):
    member_id = serializers.UUIDField(read_only=True)
    meeting_id = serializers.UUIDField(read_only=True)
    recorded_by_id = serializers.UUIDField(read_only=True, allow_null=True)

    class Meta:
        model = Attendance
        fields = (
            "id",
            "meeting_id",
            "member_id",
            "status",
            "arrival_time",
            "remarks",
            "recorded_by_id",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class AttendanceCreateSerializer(serializers.Serializer):
    member_id = serializers.UUIDField()
    status = serializers.ChoiceField(
        choices=["present", "late", "absent", "excused"]
    )
    arrival_time = serializers.TimeField(required=False, allow_null=True)
    remarks = serializers.CharField(required=False, allow_blank=True, default="")


class AttendanceBulkCreateSerializer(serializers.Serializer):
    records = AttendanceCreateSerializer(many=True)


class AttendanceUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(
        choices=["present", "late", "absent", "excused"]
    )
    arrival_time = serializers.TimeField(required=False, allow_null=True)
    remarks = serializers.CharField(required=False, allow_blank=True)


class AttendanceListItemSerializer(serializers.Serializer):
    member_id = serializers.UUIDField()
    member_name = serializers.CharField()
    attendance_id = serializers.UUIDField(allow_null=True)
    status = serializers.CharField(allow_null=True)
    arrival_time = serializers.TimeField(allow_null=True)
    remarks = serializers.CharField()
    recorded_by_id = serializers.UUIDField(allow_null=True)


class MeetingMinuteSerializer(serializers.ModelSerializer):
    prepared_by_id = serializers.UUIDField(read_only=True, allow_null=True)
    approved_by_id = serializers.UUIDField(read_only=True, allow_null=True)

    class Meta:
        model = MeetingMinute
        fields = (
            "id",
            "meeting_id",
            "minutes",
            "resolutions",
            "action_items",
            "prepared_by_id",
            "approved",
            "approved_by_id",
            "approved_at",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "meeting_id",
            "prepared_by_id",
            "approved",
            "approved_by_id",
            "approved_at",
            "created_at",
            "updated_at",
        )


class MeetingMinuteCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MeetingMinute
        fields = ("minutes", "resolutions", "action_items")


class MeetingMinuteUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MeetingMinute
        fields = ("minutes", "resolutions", "action_items")
