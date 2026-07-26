import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/api_state.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';

class GovernanceDashboardController
    extends RefreshController<GovernanceDashboard> {
  GovernanceDashboardController({
    required MeetingRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final MeetingRepository _repository;
  final String _chamaId;

  @override
  Future<GovernanceDashboard> fetchData({bool forceRefresh = false}) {
    return _repository.getDashboard(chamaId: _chamaId);
  }
}

class MeetingsListController extends RefreshController<List<Meeting>> {
  MeetingsListController({
    required MeetingRepository repository,
    required String chamaId,
    this.upcomingOnly = false,
  })  : _repository = repository,
        _chamaId = chamaId;

  final MeetingRepository _repository;
  final String _chamaId;
  final bool upcomingOnly;

  String searchQuery = '';
  MeetingStatus? statusFilter;

  @override
  Future<List<Meeting>> fetchData({bool forceRefresh = false}) async {
    final meetings = await _repository.listMeetings(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      status: statusFilter,
    );
    if (!upcomingOnly) return meetings;
    return meetings.where((m) => m.isUpcoming).toList()
      ..sort((a, b) => a.meetingDate.compareTo(b.meetingDate));
  }

  @override
  bool isEmptyData(List<Meeting> data) => data.isEmpty;

  Future<void> search(String query) async {
    searchQuery = query;
    await load(forceRefresh: true);
  }

  Future<void> setStatusFilter(MeetingStatus? status) async {
    statusFilter = status;
    await load(forceRefresh: true);
  }
}

class MeetingDetailsController extends RefreshController<Meeting> {
  MeetingDetailsController({
    required MeetingRepository repository,
    required String chamaId,
    required String meetingId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _meetingId = meetingId;

  final MeetingRepository _repository;
  final String _chamaId;
  final String _meetingId;

  bool isActing = false;
  String? actionError;
  List<AttendanceRecord> attendance = const [];
  MeetingMinutes? minutes;

  @override
  Future<Meeting> fetchData({bool forceRefresh = false}) async {
    final meeting = await _repository.getMeeting(
      chamaId: _chamaId,
      meetingId: _meetingId,
    );
    try {
      attendance = await _repository.listAttendance(
        chamaId: _chamaId,
        meetingId: _meetingId,
      );
    } catch (_) {
      attendance = const [];
    }
    try {
      minutes = await _repository.getMinutes(
        chamaId: _chamaId,
        meetingId: _meetingId,
      );
    } catch (_) {
      minutes = null;
    }
    return meeting;
  }

  Future<bool> start() => _mutate(
        () => _repository.startMeeting(
          chamaId: _chamaId,
          meetingId: _meetingId,
        ),
      );

  Future<bool> close() => _mutate(
        () => _repository.closeMeeting(
          chamaId: _chamaId,
          meetingId: _meetingId,
        ),
      );

  Future<bool> cancel() => _mutate(
        () => _repository.cancelMeeting(
          chamaId: _chamaId,
          meetingId: _meetingId,
        ),
      );

  Future<bool> _mutate(Future<Meeting> Function() action) async {
    if (isActing) return false;
    isActing = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      final updated = await action();
      if (!mounted) return false;
      state = ApiState.success(updated);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isActing = false;
      if (mounted) state = state.copyWith();
    }
  }
}

class AttendanceController extends RefreshController<List<AttendanceRecord>> {
  AttendanceController({
    required MeetingRepository repository,
    required String chamaId,
    required String meetingId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _meetingId = meetingId;

  final MeetingRepository _repository;
  final String _chamaId;
  final String _meetingId;

  bool isSaving = false;
  String? actionError;

  @override
  Future<List<AttendanceRecord>> fetchData({bool forceRefresh = false}) {
    return _repository.listAttendance(
      chamaId: _chamaId,
      meetingId: _meetingId,
    );
  }

  @override
  bool isEmptyData(List<AttendanceRecord> data) => data.isEmpty;

  Future<bool> saveRecord(RecordAttendanceInput input, {String? attendanceId}) async {
    if (isSaving) return false;
    isSaving = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      if (attendanceId != null) {
        await _repository.updateAttendance(
          chamaId: _chamaId,
          meetingId: _meetingId,
          attendanceId: attendanceId,
          input: input,
        );
      } else {
        await _repository.recordAttendance(
          chamaId: _chamaId,
          meetingId: _meetingId,
          input: input,
        );
      }
      if (!mounted) return false;
      await load(forceRefresh: true);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isSaving = false;
      if (mounted) state = state.copyWith();
    }
  }
}

class MeetingMinutesState {
  const MeetingMinutesState({
    this.isLoading = false,
    this.isSaving = false,
    this.isApproving = false,
    this.minutes,
    this.errorMessage,
    this.exists = false,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isApproving;
  final MeetingMinutes? minutes;
  final String? errorMessage;
  final bool exists;

  MeetingMinutesState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isApproving,
    MeetingMinutes? minutes,
    String? errorMessage,
    bool? exists,
    bool clearError = false,
    bool clearMinutes = false,
  }) {
    return MeetingMinutesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isApproving: isApproving ?? this.isApproving,
      minutes: clearMinutes ? null : (minutes ?? this.minutes),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      exists: exists ?? this.exists,
    );
  }
}

class MeetingMinutesController extends StateNotifier<MeetingMinutesState> {
  MeetingMinutesController({
    required MeetingRepository repository,
    required String chamaId,
    required String meetingId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _meetingId = meetingId,
        super(const MeetingMinutesState(isLoading: true));

  final MeetingRepository _repository;
  final String _chamaId;
  final String _meetingId;

  Future<void> load() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final minutes = await _repository.getMinutes(
        chamaId: _chamaId,
        meetingId: _meetingId,
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        minutes: minutes,
        exists: minutes != null,
        clearMinutes: minutes == null,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<bool> save(MeetingMinutesInput input) async {
    if (!mounted) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final saved = await _repository.saveMinutes(
        chamaId: _chamaId,
        meetingId: _meetingId,
        input: input,
        isUpdate: state.exists,
      );
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        minutes: saved,
        exists: true,
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> approve() async {
    if (!mounted) return false;
    state = state.copyWith(isApproving: true, clearError: true);
    try {
      final approved = await _repository.approveMinutes(
        chamaId: _chamaId,
        meetingId: _meetingId,
      );
      if (!mounted) return false;
      state = state.copyWith(
        isApproving: false,
        minutes: approved,
        exists: true,
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        isApproving: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }
}

class ScheduleMeetingState {
  const ScheduleMeetingState({
    this.isSubmitting = false,
    this.errorMessage,
    this.meeting,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final Meeting? meeting;

  ScheduleMeetingState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    Meeting? meeting,
    bool clearError = false,
  }) {
    return ScheduleMeetingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      meeting: meeting ?? this.meeting,
    );
  }
}

class ScheduleMeetingController extends StateNotifier<ScheduleMeetingState> {
  ScheduleMeetingController(this._repository)
      : super(const ScheduleMeetingState());

  final MeetingRepository _repository;

  Future<Meeting?> submit({
    required String chamaId,
    required ScheduleMeetingInput input,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final meeting = await _repository.scheduleMeeting(
        chamaId: chamaId,
        input: input,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, meeting: meeting);
      return meeting;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }
}
