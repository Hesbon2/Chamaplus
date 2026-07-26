import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/meetings/domain/entities/meeting.dart';
import 'package:chamaplus_mobile/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:chamaplus_mobile/features/meetings/presentation/controllers/meeting_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMeetingRepository implements MeetingRepository {
  List<Meeting> meetings = [];
  Object? error;

  @override
  Future<MeetingMinutes> approveMinutes({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Meeting> cancelMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Meeting> closeMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GovernanceDashboard> getDashboard({required String chamaId}) async {
    if (error != null) throw error!;
    return GovernanceDashboard(
      nextMeeting: meetings.isEmpty ? null : meetings.first,
      upcomingMeetings: meetings.where((m) => m.isUpcoming).toList(),
      recentMeetings: const [],
      scheduledCount:
          meetings.where((m) => m.status == MeetingStatus.scheduled).length,
      ongoingCount:
          meetings.where((m) => m.status == MeetingStatus.ongoing).length,
      completedCount:
          meetings.where((m) => m.status == MeetingStatus.completed).length,
      openActionItems: const [],
    );
  }

  @override
  Future<Meeting> getMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingMinutes?> getMinutes({
    required String chamaId,
    required String meetingId,
  }) async =>
      null;

  @override
  Future<List<AttendanceRecord>> listAttendance({
    required String chamaId,
    required String meetingId,
  }) async =>
      [];

  @override
  Future<List<Meeting>> listMeetings({
    required String chamaId,
    String? search,
    MeetingStatus? status,
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
  Future<Attendance> recordAttendance({
    required String chamaId,
    required String meetingId,
    required RecordAttendanceInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Attendance>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required List<RecordAttendanceInput> records,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MeetingMinutes> saveMinutes({
    required String chamaId,
    required String meetingId,
    required MeetingMinutesInput input,
    required bool isUpdate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Meeting> scheduleMeeting({
    required String chamaId,
    required ScheduleMeetingInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Meeting> startMeeting({
    required String chamaId,
    required String meetingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Attendance> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required RecordAttendanceInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Meeting> updateMeeting({
    required String chamaId,
    required String meetingId,
    required ScheduleMeetingInput input,
  }) {
    throw UnimplementedError();
  }
}

Meeting _meeting({
  required String id,
  required String title,
  MeetingStatus status = MeetingStatus.scheduled,
  DateTime? date,
}) {
  return Meeting(
    id: id,
    chamaId: 'c1',
    title: title,
    meetingType: MeetingType.ordinary,
    venue: 'Hall',
    meetingDate: date ?? DateTime.now().add(const Duration(days: 2)),
    startTime: '10:00',
    status: status,
    attendanceFinalized: false,
  );
}

void main() {
  test('MeetingsListController loads meetings', () async {
    final repo = FakeMeetingRepository()
      ..meetings = [
        _meeting(id: 'm1', title: 'Monthly'),
      ];
    final controller = MeetingsListController(
      repository: repo,
      chamaId: 'c1',
    );

    await controller.load();
    expect(controller.state.isSuccess, isTrue);
    expect(controller.state.data, hasLength(1));
  });

  test('MeetingsListController upcomingOnly filters past statuses', () async {
    final repo = FakeMeetingRepository()
      ..meetings = [
        _meeting(id: 'm1', title: 'Soon'),
        _meeting(
          id: 'm2',
          title: 'Old',
          status: MeetingStatus.completed,
          date: DateTime(2025, 1, 1),
        ),
      ];
    final controller = MeetingsListController(
      repository: repo,
      chamaId: 'c1',
      upcomingOnly: true,
    );

    await controller.load();
    expect(controller.state.data, hasLength(1));
    expect(controller.state.data!.first.id, 'm1');
  });

  test('MeetingsListController search refreshes list', () async {
    final repo = FakeMeetingRepository()
      ..meetings = [
        _meeting(id: 'm1', title: 'AGM Planning'),
        _meeting(id: 'm2', title: 'Weekly check-in'),
      ];
    final controller = MeetingsListController(
      repository: repo,
      chamaId: 'c1',
    );

    await controller.search('agm');
    expect(controller.state.data, hasLength(1));
    expect(controller.state.data!.first.title, 'AGM Planning');
  });

  test('GovernanceDashboardController surfaces errors', () async {
    final repo = FakeMeetingRepository()
      ..error = const ServerException(message: 'Offline');
    final controller = GovernanceDashboardController(
      repository: repo,
      chamaId: 'c1',
    );

    await controller.load();
    expect(controller.state.isError, isTrue);
    expect(controller.state.errorMessage, contains('Offline'));
  });
}
