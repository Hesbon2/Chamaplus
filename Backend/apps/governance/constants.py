SCHEDULED = "scheduled"
ONGOING = "ongoing"
COMPLETED = "completed"
CANCELLED = "cancelled"

MEETING_STATUS_CHOICES = (
    (SCHEDULED, "Scheduled"),
    (ONGOING, "Ongoing"),
    (COMPLETED, "Completed"),
    (CANCELLED, "Cancelled"),
)

ORDINARY = "ordinary"
AGM = "agm"
EMERGENCY = "emergency"
COMMITTEE = "committee"

MEETING_TYPE_CHOICES = (
    (ORDINARY, "Ordinary"),
    (AGM, "Annual General Meeting"),
    (EMERGENCY, "Emergency"),
    (COMMITTEE, "Committee"),
)

PRESENT = "present"
LATE = "late"
ABSENT = "absent"
EXCUSED = "excused"

ATTENDANCE_STATUS_CHOICES = (
    (PRESENT, "Present"),
    (LATE, "Late"),
    (ABSENT, "Absent"),
    (EXCUSED, "Excused"),
)

ATTENDANCE_SCORE_WEIGHTS = {
    PRESENT: 1.0,
    LATE: 0.75,
    EXCUSED: 0.5,
    ABSENT: 0.0,
}

OPEN_MEETING_STATUSES = (SCHEDULED, ONGOING)
CLOSED_MEETING_STATUSES = (COMPLETED, CANCELLED)
