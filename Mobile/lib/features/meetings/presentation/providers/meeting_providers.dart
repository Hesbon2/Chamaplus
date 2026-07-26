import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../data/datasources/meeting_api.dart';
import '../../data/repositories/meeting_repository_impl.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../controllers/meeting_controllers.dart';

final meetingApiProvider = Provider<MeetingApi>((ref) {
  return MeetingApi(ref.watch(apiClientProvider));
});

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepositoryImpl(ref.watch(meetingApiProvider));
});

final governanceDashboardProvider = StateNotifierProvider.autoDispose
    .family<GovernanceDashboardController, ApiState<GovernanceDashboard>,
        String>((ref, chamaId) {
  final controller = GovernanceDashboardController(
    repository: ref.watch(meetingRepositoryProvider),
    chamaId: chamaId,
  );
  Future.microtask(controller.load);
  return controller;
});

final meetingsListControllerProvider = StateNotifierProvider.autoDispose
    .family<MeetingsListController, ApiState<List<Meeting>>,
        ({String chamaId, bool upcomingOnly})>((ref, args) {
  final controller = MeetingsListController(
    repository: ref.watch(meetingRepositoryProvider),
    chamaId: args.chamaId,
    upcomingOnly: args.upcomingOnly,
  );
  Future.microtask(controller.load);
  return controller;
});

final meetingDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<MeetingDetailsController, ApiState<Meeting>,
        ({String chamaId, String meetingId})>((ref, args) {
  final controller = MeetingDetailsController(
    repository: ref.watch(meetingRepositoryProvider),
    chamaId: args.chamaId,
    meetingId: args.meetingId,
  );
  Future.microtask(controller.load);
  return controller;
});

final attendanceControllerProvider = StateNotifierProvider.autoDispose.family<
    AttendanceController,
    ApiState<List<AttendanceRecord>>,
    ({String chamaId, String meetingId})>((ref, args) {
  final controller = AttendanceController(
    repository: ref.watch(meetingRepositoryProvider),
    chamaId: args.chamaId,
    meetingId: args.meetingId,
  );
  Future.microtask(controller.load);
  return controller;
});

final meetingMinutesControllerProvider =
    StateNotifierProvider.autoDispose.family<
        MeetingMinutesController,
        MeetingMinutesState,
        ({String chamaId, String meetingId})>((ref, args) {
  final controller = MeetingMinutesController(
    repository: ref.watch(meetingRepositoryProvider),
    chamaId: args.chamaId,
    meetingId: args.meetingId,
  );
  Future.microtask(controller.load);
  return controller;
});

final scheduleMeetingControllerProvider = StateNotifierProvider.autoDispose<
    ScheduleMeetingController, ScheduleMeetingState>(
  (ref) => ScheduleMeetingController(ref.watch(meetingRepositoryProvider)),
);
