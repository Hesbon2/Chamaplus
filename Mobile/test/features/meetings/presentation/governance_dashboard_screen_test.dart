import 'package:chamaplus_mobile/features/meetings/domain/entities/meeting.dart';
import 'package:chamaplus_mobile/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:chamaplus_mobile/features/meetings/presentation/controllers/meeting_controllers.dart';
import 'package:chamaplus_mobile/features/meetings/presentation/providers/meeting_providers.dart';
import 'package:chamaplus_mobile/features/meetings/presentation/screens/governance_dashboard_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMeetingRepository implements MeetingRepository {
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
    return GovernanceDashboard(
      nextMeeting: Meeting(
        id: 'm1',
        chamaId: chamaId,
        title: 'July review',
        meetingType: MeetingType.ordinary,
        venue: 'Community hall',
        meetingDate: DateTime.now().add(const Duration(days: 3)),
        startTime: '10:00',
        status: MeetingStatus.scheduled,
        attendanceFinalized: false,
      ),
      upcomingMeetings: const [],
      recentMeetings: const [],
      scheduledCount: 2,
      ongoingCount: 0,
      completedCount: 5,
      openActionItems: const [
        MeetingActionItem(task: 'Follow up on arrears'),
      ],
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
  }) async =>
      [];

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

class _SeededDashboardController extends GovernanceDashboardController {
  _SeededDashboardController()
      : super(
          repository: _FakeMeetingRepository(),
          chamaId: 'c1',
        ) {
    state = ApiState.success(
      GovernanceDashboard(
        nextMeeting: Meeting(
          id: 'm1',
          chamaId: 'c1',
          title: 'July review',
          meetingType: MeetingType.ordinary,
          venue: 'Community hall',
          meetingDate: DateTime.now().add(const Duration(days: 3)),
          startTime: '10:00',
          status: MeetingStatus.scheduled,
          attendanceFinalized: false,
        ),
        upcomingMeetings: const [],
        recentMeetings: const [],
        scheduledCount: 2,
        ongoingCount: 0,
        completedCount: 5,
        openActionItems: const [
          MeetingActionItem(task: 'Follow up on arrears'),
        ],
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets('GovernanceDashboardScreen shows next meeting and stats',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingRepositoryProvider.overrideWithValue(_FakeMeetingRepository()),
          governanceDashboardProvider.overrideWith(
            (ref, chamaId) => _SeededDashboardController(),
          ),
        ],
        child: const MaterialApp(
          home: GovernanceDashboardScreen(chamaId: 'c1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Governance'), findsOneWidget);
    expect(find.text('July review'), findsOneWidget);
    expect(find.text('Meeting completion'), findsOneWidget);
    expect(find.text('Open action items'), findsOneWidget);
    expect(find.text('Follow up on arrears'), findsOneWidget);
    expect(find.text('Schedule'), findsWidgets);
  });
}
