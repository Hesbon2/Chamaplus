export '../../../../core/models/paged_result.dart';

/// Lifecycle status of a meeting.
enum MeetingStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
  unknown;

  static MeetingStatus fromApi(String? value) {
    switch (value) {
      case 'scheduled':
        return MeetingStatus.scheduled;
      case 'ongoing':
        return MeetingStatus.ongoing;
      case 'completed':
        return MeetingStatus.completed;
      case 'cancelled':
        return MeetingStatus.cancelled;
      default:
        return MeetingStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case MeetingStatus.scheduled:
        return 'scheduled';
      case MeetingStatus.ongoing:
        return 'ongoing';
      case MeetingStatus.completed:
        return 'completed';
      case MeetingStatus.cancelled:
        return 'cancelled';
      case MeetingStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case MeetingStatus.scheduled:
        return 'Scheduled';
      case MeetingStatus.ongoing:
        return 'Ongoing';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.cancelled:
        return 'Cancelled';
      case MeetingStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isOpen =>
      this == MeetingStatus.scheduled || this == MeetingStatus.ongoing;
}

/// Type of chama meeting.
enum MeetingType {
  ordinary,
  agm,
  emergency,
  committee,
  unknown;

  static MeetingType fromApi(String? value) {
    switch (value) {
      case 'ordinary':
        return MeetingType.ordinary;
      case 'agm':
        return MeetingType.agm;
      case 'emergency':
        return MeetingType.emergency;
      case 'committee':
        return MeetingType.committee;
      default:
        return MeetingType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case MeetingType.ordinary:
        return 'ordinary';
      case MeetingType.agm:
        return 'agm';
      case MeetingType.emergency:
        return 'emergency';
      case MeetingType.committee:
        return 'committee';
      case MeetingType.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case MeetingType.ordinary:
        return 'Ordinary';
      case MeetingType.agm:
        return 'AGM';
      case MeetingType.emergency:
        return 'Emergency';
      case MeetingType.committee:
        return 'Committee';
      case MeetingType.unknown:
        return 'Unknown';
    }
  }
}

/// Member attendance status for a meeting.
enum AttendanceStatus {
  present,
  late,
  absent,
  excused,
  unknown;

  static AttendanceStatus fromApi(String? value) {
    switch (value) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
        return AttendanceStatus.absent;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.excused:
        return 'excused';
      case AttendanceStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.unknown:
        return 'Not recorded';
    }
  }
}

/// A scheduled or past chama meeting.
class Meeting {
  const Meeting({
    required this.id,
    required this.chamaId,
    required this.title,
    this.description,
    required this.meetingType,
    required this.venue,
    required this.meetingDate,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.attendanceFinalized,
    this.createdById,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chamaId;
  final String title;
  final String? description;
  final MeetingType meetingType;
  final String venue;
  final DateTime meetingDate;
  final String startTime;
  final String? endTime;
  final MeetingStatus status;
  final bool attendanceFinalized;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isUpcoming {
    if (status != MeetingStatus.scheduled && status != MeetingStatus.ongoing) {
      return false;
    }
    final today = DateTime.now();
    final dateOnly = DateTime(meetingDate.year, meetingDate.month, meetingDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return !dateOnly.isBefore(todayOnly);
  }
}

/// Roster row for meeting attendance.
class AttendanceRecord {
  const AttendanceRecord({
    required this.memberId,
    required this.memberName,
    this.attendanceId,
    this.status,
    this.arrivalTime,
    this.remarks = '',
    this.recordedById,
  });

  final String memberId;
  final String memberName;
  final String? attendanceId;
  final AttendanceStatus? status;
  final String? arrivalTime;
  final String remarks;
  final String? recordedById;

  bool get isRecorded => attendanceId != null && status != null;
}

/// Saved attendance entity from create/update.
class Attendance {
  const Attendance({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.status,
    this.arrivalTime,
    this.remarks = '',
    this.recordedById,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String memberId;
  final AttendanceStatus status;
  final String? arrivalTime;
  final String remarks;
  final String? recordedById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Action item embedded in meeting minutes JSON.
class MeetingActionItem {
  const MeetingActionItem({
    required this.task,
    this.owner,
    this.dueDate,
    this.isDone = false,
  });

  final String task;
  final String? owner;
  final String? dueDate;
  final bool isDone;

  Map<String, dynamic> toJson() => {
        'task': task,
        if (owner != null) 'owner': owner,
        if (dueDate != null) 'due_date': dueDate,
        'is_done': isDone,
      };

  factory MeetingActionItem.fromJson(Map<String, dynamic> json) {
    return MeetingActionItem(
      task: '${json['task'] ?? json['title'] ?? ''}',
      owner: json['owner']?.toString(),
      dueDate: json['due_date']?.toString() ?? json['dueDate']?.toString(),
      isDone: json['is_done'] == true || json['done'] == true,
    );
  }
}

/// Meeting minutes document.
class MeetingMinutes {
  const MeetingMinutes({
    required this.id,
    required this.meetingId,
    required this.minutes,
    required this.resolutions,
    required this.actionItems,
    this.preparedById,
    required this.approved,
    this.approvedById,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String minutes;
  final List<String> resolutions;
  final List<MeetingActionItem> actionItems;
  final String? preparedById;
  final bool approved;
  final String? approvedById;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Composite governance dashboard for a chama.
class GovernanceDashboard {
  const GovernanceDashboard({
    this.nextMeeting,
    required this.upcomingMeetings,
    required this.recentMeetings,
    required this.scheduledCount,
    required this.ongoingCount,
    required this.completedCount,
    required this.openActionItems,
  });

  final Meeting? nextMeeting;
  final List<Meeting> upcomingMeetings;
  final List<Meeting> recentMeetings;
  final int scheduledCount;
  final int ongoingCount;
  final int completedCount;
  final List<MeetingActionItem> openActionItems;
}

/// Input to schedule a meeting.
class ScheduleMeetingInput {
  const ScheduleMeetingInput({
    required this.title,
    this.description,
    required this.meetingType,
    required this.venue,
    required this.meetingDate,
    required this.startTime,
    this.endTime,
  });

  final String title;
  final String? description;
  final MeetingType meetingType;
  final String venue;
  final DateTime meetingDate;
  final String startTime;
  final String? endTime;
}

/// Input to record / update attendance for one member.
class RecordAttendanceInput {
  const RecordAttendanceInput({
    required this.memberId,
    required this.status,
    this.arrivalTime,
    this.remarks,
  });

  final String memberId;
  final AttendanceStatus status;
  final String? arrivalTime;
  final String? remarks;
}

/// Input to create / update minutes.
class MeetingMinutesInput {
  const MeetingMinutesInput({
    required this.minutes,
    this.resolutions = const [],
    this.actionItems = const [],
  });

  final String minutes;
  final List<String> resolutions;
  final List<MeetingActionItem> actionItems;
}
