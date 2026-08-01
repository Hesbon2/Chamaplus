import '../../../../shared/api_state.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class NotificationPreferencesController
    extends RefreshController<NotificationPreferences> {
  NotificationPreferencesController({
    required SettingsRepository repository,
  }) : _repository = repository;

  final SettingsRepository _repository;

  @override
  Future<NotificationPreferences> fetchData({bool forceRefresh = false}) {
    return _repository.getNotificationPreferences();
  }

  Future<void> setContributions(bool value) => _patch(
        (p) => p.copyWith(contributions: value),
      );

  Future<void> setLoans(bool value) => _patch(
        (p) => p.copyWith(loans: value),
      );

  Future<void> setMeetings(bool value) => _patch(
        (p) => p.copyWith(meetings: value),
      );

  Future<void> setAnnouncements(bool value) => _patch(
        (p) => p.copyWith(announcements: value),
      );

  Future<void> _patch(
    NotificationPreferences Function(NotificationPreferences) transform,
  ) async {
    final current = state.data ?? await _repository.getNotificationPreferences();
    final next = transform(current);
    state = ApiState.success(next);
    try {
      final saved = await _repository.updateNotificationPreferences(next);
      if (!mounted) return;
      state = ApiState.success(saved);
    } catch (error, stack) {
      if (!mounted) return;
      state = ApiState.error(error, stackTrace: stack, data: current);
    }
  }
}
