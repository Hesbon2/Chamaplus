import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../datasources/meeting_api.dart';

/// Concrete [MeetingRepository] backed by [MeetingRemoteDataSource].
class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._api);

  final MeetingRemoteDataSource _api;

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _timeApi(String hhmm) {
    if (hhmm.length == 5) return '$hhmm:00';
    return hhmm;
  }

  Map<String, dynamic> _scheduleBody(ScheduleMeetingInput input) => {
        'title': input.title,
        if (input.description != null && input.description!.trim().isNotEmpty)
          'description': input.description!.trim(),
        'meeting_type': input.meetingType.apiValue,
        'venue': input.venue,
        'meeting_date': _dateOnly(input.meetingDate),
        'start_time': _timeApi(input.startTime),
        if (input.endTime != null && input.endTime!.isNotEmpty)
          'end_time': _timeApi(input.endTime!),
      };

  Map<String, dynamic> _attendanceBody(RecordAttendanceInput input) => {
        'member_id': input.memberId,
        'status': input.status.apiValue,
        if (input.arrivalTime != null && input.arrivalTime!.isNotEmpty)
          'arrival_time': _timeApi(input.arrivalTime!),
        if (input.remarks != null) 'remarks': input.remarks,
      };

  @override
  Future<List<Meeting>> listMeetings({
    required String chamaId,
    String? search,
    MeetingStatus? status,
  }) async {
    final dtos = await _api.listMeetings(
      chamaId: chamaId,
      search: search,
      status: status?.apiValue,
    );
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Meeting> getMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto =
        await _api.getMeeting(chamaId: chamaId, meetingId: meetingId);
    return dto.toEntity();
  }

  @override
  Future<Meeting> scheduleMeeting({
    required String chamaId,
    required ScheduleMeetingInput input,
  }) async {
    final dto = await _api.scheduleMeeting(
      chamaId: chamaId,
      body: _scheduleBody(input),
    );
    return dto.toEntity();
  }

  @override
  Future<Meeting> updateMeeting({
    required String chamaId,
    required String meetingId,
    required ScheduleMeetingInput input,
  }) async {
    final dto = await _api.updateMeeting(
      chamaId: chamaId,
      meetingId: meetingId,
      body: _scheduleBody(input),
    );
    return dto.toEntity();
  }

  @override
  Future<Meeting> cancelMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto =
        await _api.cancelMeeting(chamaId: chamaId, meetingId: meetingId);
    return dto.toEntity();
  }

  @override
  Future<Meeting> startMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto =
        await _api.startMeeting(chamaId: chamaId, meetingId: meetingId);
    return dto.toEntity();
  }

  @override
  Future<Meeting> closeMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto =
        await _api.closeMeeting(chamaId: chamaId, meetingId: meetingId);
    return dto.toEntity();
  }

  @override
  Future<List<AttendanceRecord>> listAttendance({
    required String chamaId,
    required String meetingId,
  }) async {
    final dtos = await _api.listAttendance(
      chamaId: chamaId,
      meetingId: meetingId,
    );
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Attendance> recordAttendance({
    required String chamaId,
    required String meetingId,
    required RecordAttendanceInput input,
  }) async {
    final dto = await _api.recordAttendance(
      chamaId: chamaId,
      meetingId: meetingId,
      body: _attendanceBody(input),
    );
    return dto.toEntity();
  }

  @override
  Future<List<Attendance>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required List<RecordAttendanceInput> records,
  }) async {
    final dtos = await _api.recordAttendanceBulk(
      chamaId: chamaId,
      meetingId: meetingId,
      body: {
        'records': records.map(_attendanceBody).toList(),
      },
    );
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Attendance> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required RecordAttendanceInput input,
  }) async {
    final body = <String, dynamic>{
      'status': input.status.apiValue,
      if (input.arrivalTime != null && input.arrivalTime!.isNotEmpty)
        'arrival_time': _timeApi(input.arrivalTime!),
      if (input.remarks != null) 'remarks': input.remarks,
    };
    final dto = await _api.updateAttendance(
      chamaId: chamaId,
      meetingId: meetingId,
      attendanceId: attendanceId,
      body: body,
    );
    return dto.toEntity();
  }

  @override
  Future<MeetingMinutes?> getMinutes({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto = await _api.getMinutes(chamaId: chamaId, meetingId: meetingId);
    return dto?.toEntity();
  }

  @override
  Future<MeetingMinutes> saveMinutes({
    required String chamaId,
    required String meetingId,
    required MeetingMinutesInput input,
    required bool isUpdate,
  }) async {
    final body = {
      'minutes': input.minutes,
      'resolutions': input.resolutions,
      'action_items': input.actionItems.map((a) => a.toJson()).toList(),
    };
    final dto = isUpdate
        ? await _api.updateMinutes(
            chamaId: chamaId,
            meetingId: meetingId,
            body: body,
          )
        : await _api.createMinutes(
            chamaId: chamaId,
            meetingId: meetingId,
            body: body,
          );
    return dto.toEntity();
  }

  @override
  Future<MeetingMinutes> approveMinutes({
    required String chamaId,
    required String meetingId,
  }) async {
    final dto =
        await _api.approveMinutes(chamaId: chamaId, meetingId: meetingId);
    return dto.toEntity();
  }

  @override
  Future<GovernanceDashboard> getDashboard({
    required String chamaId,
  }) async {
    final meetings = await listMeetings(chamaId: chamaId);
    final upcoming = meetings.where((m) => m.isUpcoming).toList()
      ..sort((a, b) => a.meetingDate.compareTo(b.meetingDate));
    final recent = meetings
        .where((m) =>
            m.status == MeetingStatus.completed ||
            m.status == MeetingStatus.cancelled)
        .take(5)
        .toList();

    final openActions = <MeetingActionItem>[];
    for (final meeting in upcoming.take(3)) {
      try {
        final minutes =
            await getMinutes(chamaId: chamaId, meetingId: meeting.id);
        if (minutes != null) {
          openActions.addAll(
            minutes.actionItems.where((a) => !a.isDone),
          );
        }
      } catch (_) {
        // Minutes may not exist yet.
      }
    }

    return GovernanceDashboard(
      nextMeeting: upcoming.isEmpty ? null : upcoming.first,
      upcomingMeetings: upcoming,
      recentMeetings: recent,
      scheduledCount:
          meetings.where((m) => m.status == MeetingStatus.scheduled).length,
      ongoingCount:
          meetings.where((m) => m.status == MeetingStatus.ongoing).length,
      completedCount:
          meetings.where((m) => m.status == MeetingStatus.completed).length,
      openActionItems: openActions.take(8).toList(),
    );
  }
}
