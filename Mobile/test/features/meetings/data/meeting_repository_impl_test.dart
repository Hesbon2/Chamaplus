import 'package:chamaplus_mobile/features/meetings/data/datasources/meeting_api.dart';
import 'package:chamaplus_mobile/features/meetings/data/dtos/meeting_dtos.dart';
import 'package:chamaplus_mobile/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:chamaplus_mobile/features/meetings/domain/entities/meeting.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMeetingApi implements MeetingRemoteDataSource {
  List<MeetingDto> meetings = [];
  MeetingMinutesDto? minutes;
  Map<String, dynamic>? lastScheduleBody;
  Object? error;

  @override
  Future<MeetingMinutesDto> approveMinutes({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingDto> cancelMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingDto> closeMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingMinutesDto> createMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingDto> getMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    return meetings.firstWhere((m) => m.id == meetingId);
  }

  @override
  Future<MeetingMinutesDto?> getMinutes({
    required String chamaId,
    required String meetingId,
  }) async {
    if (error != null) throw error!;
    return minutes;
  }

  @override
  Future<List<AttendanceRecordDto>> listAttendance({
    required String chamaId,
    required String meetingId,
  }) async =>
      [];

  @override
  Future<List<MeetingDto>> listMeetings({
    required String chamaId,
    String? search,
    String? status,
  }) async {
    if (error != null) throw error!;
    var list = meetings;
    if (status != null) {
      list = list.where((m) => m.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      list = list
          .where((m) => m.title.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Future<AttendanceDto> recordAttendance({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AttendanceDto>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingDto> scheduleMeeting({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    lastScheduleBody = body;
    return MeetingDto(
      id: 'm-new',
      chamaId: chamaId,
      title: body['title'] as String,
      meetingType: body['meeting_type'] as String,
      venue: body['venue'] as String,
      meetingDate: body['meeting_date'] as String,
      startTime: body['start_time'] as String,
      endTime: body['end_time'] as String?,
      status: 'scheduled',
      attendanceFinalized: false,
    );
  }

  @override
  Future<MeetingDto> startMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AttendanceDto> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingDto> updateMeeting({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingMinutesDto> updateMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeMeetingApi api;
  late MeetingRepositoryImpl repository;

  setUp(() {
    api = FakeMeetingApi();
    repository = MeetingRepositoryImpl(api);
  });

  test('listMeetings maps DTOs to entities', () async {
    api.meetings = [
      const MeetingDto(
        id: 'm1',
        chamaId: 'c1',
        title: 'Monthly contributions',
        meetingType: 'ordinary',
        venue: 'Hall A',
        meetingDate: '2026-08-01',
        startTime: '10:00:00',
        status: 'scheduled',
        attendanceFinalized: false,
      ),
    ];

    final meetings = await repository.listMeetings(chamaId: 'c1');
    expect(meetings, hasLength(1));
    expect(meetings.first.title, 'Monthly contributions');
    expect(meetings.first.startTime, '10:00');
    expect(meetings.first.status, MeetingStatus.scheduled);
  });

  test('scheduleMeeting sends snake_case body with padded time', () async {
    final meeting = await repository.scheduleMeeting(
      chamaId: 'c1',
      input: ScheduleMeetingInput(
        title: 'AGM',
        meetingType: MeetingType.agm,
        venue: 'Church hall',
        meetingDate: DateTime(2026, 9, 15),
        startTime: '14:30',
        endTime: '16:00',
      ),
    );

    expect(meeting.id, 'm-new');
    expect(api.lastScheduleBody, {
      'title': 'AGM',
      'meeting_type': 'agm',
      'venue': 'Church hall',
      'meeting_date': '2026-09-15',
      'start_time': '14:30:00',
      'end_time': '16:00:00',
    });
  });

  test('getDashboard aggregates counts and next meeting', () async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date =
        '${tomorrow.year.toString().padLeft(4, '0')}-'
        '${tomorrow.month.toString().padLeft(2, '0')}-'
        '${tomorrow.day.toString().padLeft(2, '0')}';

    api.meetings = [
      MeetingDto(
        id: 'm1',
        chamaId: 'c1',
        title: 'Next up',
        meetingType: 'ordinary',
        venue: 'Office',
        meetingDate: date,
        startTime: '09:00:00',
        status: 'scheduled',
        attendanceFinalized: false,
      ),
      const MeetingDto(
        id: 'm2',
        chamaId: 'c1',
        title: 'Done',
        meetingType: 'ordinary',
        venue: 'Office',
        meetingDate: '2026-01-01',
        startTime: '09:00:00',
        status: 'completed',
        attendanceFinalized: true,
      ),
    ];
    api.minutes = const MeetingMinutesDto(
      id: 'min1',
      meetingId: 'm1',
      minutes: 'Notes',
      resolutions: [],
      actionItems: [
        {'task': 'Collect dues', 'is_done': false},
        {'task': 'File report', 'is_done': true},
      ],
      approved: false,
    );

    final dashboard = await repository.getDashboard(chamaId: 'c1');
    expect(dashboard.nextMeeting?.id, 'm1');
    expect(dashboard.scheduledCount, 1);
    expect(dashboard.completedCount, 1);
    expect(dashboard.openActionItems, hasLength(1));
    expect(dashboard.openActionItems.first.task, 'Collect dues');
  });
}
