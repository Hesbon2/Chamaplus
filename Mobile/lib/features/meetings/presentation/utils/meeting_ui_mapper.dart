import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';

/// Maps meeting domain enums to design-system tones.
class MeetingUiMapper {
  MeetingUiMapper._();

  static StatusChipTone toneForStatus(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return StatusChipTone.info;
      case MeetingStatus.ongoing:
        return StatusChipTone.warning;
      case MeetingStatus.completed:
        return StatusChipTone.success;
      case MeetingStatus.cancelled:
        return StatusChipTone.neutral;
      case MeetingStatus.unknown:
        return StatusChipTone.neutral;
    }
  }

  static StatusChipTone toneForAttendance(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return StatusChipTone.success;
      case AttendanceStatus.late:
        return StatusChipTone.warning;
      case AttendanceStatus.absent:
        return StatusChipTone.error;
      case AttendanceStatus.excused:
        return StatusChipTone.info;
      case AttendanceStatus.unknown:
      case null:
        return StatusChipTone.neutral;
    }
  }

  /// Lifecycle timeline for a meeting detail screen.
  static List<TimelineStep> timelineFor(Meeting meeting) {
    final status = meeting.status;
    return [
      TimelineStep(
        title: 'Scheduled',
        subtitle: meeting.venue,
        timestamp: MeetingFormatters.date(meeting.meetingDate),
        isCompleted: true,
        isActive: status == MeetingStatus.scheduled,
        icon: Icons.event_available,
      ),
      TimelineStep(
        title: 'In progress',
        subtitle: status == MeetingStatus.ongoing ? 'Meeting started' : null,
        isCompleted: status == MeetingStatus.ongoing ||
            status == MeetingStatus.completed,
        isActive: status == MeetingStatus.ongoing,
        icon: Icons.play_circle_outline,
      ),
      TimelineStep(
        title: 'Attendance',
        subtitle: meeting.attendanceFinalized
            ? 'Finalized'
            : 'Pending finalization',
        isCompleted: meeting.attendanceFinalized,
        isActive: status.isOpen && !meeting.attendanceFinalized,
        icon: Icons.how_to_reg_outlined,
      ),
      TimelineStep(
        title: status == MeetingStatus.cancelled ? 'Cancelled' : 'Completed',
        isCompleted: status == MeetingStatus.completed ||
            status == MeetingStatus.cancelled,
        isActive: status == MeetingStatus.completed ||
            status == MeetingStatus.cancelled,
        icon: status == MeetingStatus.cancelled
            ? Icons.cancel_outlined
            : Icons.check_circle_outline,
      ),
    ];
  }
}

/// Date / time formatters for meetings.
class MeetingFormatters {
  MeetingFormatters._();

  static final _date = DateFormat('EEE, d MMM yyyy');
  static final _shortDate = DateFormat('d MMM yyyy');

  static String date(DateTime value) => _date.format(value.toLocal());

  static String shortDate(DateTime value) =>
      _shortDate.format(value.toLocal());

  static String timeRange(String start, String? end) {
    if (end == null || end.isEmpty) return start;
    return '$start – $end';
  }
}
