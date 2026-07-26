import '../entities/meeting.dart';

/// Contract for chama meetings, attendance, and minutes.
abstract class MeetingRepository {
  Future<List<Meeting>> listMeetings({
    required String chamaId,
    String? search,
    MeetingStatus? status,
  });

  Future<Meeting> getMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<Meeting> scheduleMeeting({
    required String chamaId,
    required ScheduleMeetingInput input,
  });

  Future<Meeting> updateMeeting({
    required String chamaId,
    required String meetingId,
    required ScheduleMeetingInput input,
  });

  Future<Meeting> cancelMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<Meeting> startMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<Meeting> closeMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<List<AttendanceRecord>> listAttendance({
    required String chamaId,
    required String meetingId,
  });

  Future<Attendance> recordAttendance({
    required String chamaId,
    required String meetingId,
    required RecordAttendanceInput input,
  });

  Future<List<Attendance>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required List<RecordAttendanceInput> records,
  });

  Future<Attendance> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required RecordAttendanceInput input,
  });

  Future<MeetingMinutes?> getMinutes({
    required String chamaId,
    required String meetingId,
  });

  Future<MeetingMinutes> saveMinutes({
    required String chamaId,
    required String meetingId,
    required MeetingMinutesInput input,
    required bool isUpdate,
  });

  Future<MeetingMinutes> approveMinutes({
    required String chamaId,
    required String meetingId,
  });

  Future<GovernanceDashboard> getDashboard({
    required String chamaId,
  });
}
