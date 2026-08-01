import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final PreferencesStorage _storage;

  @override
  Future<NotificationPreferences> getNotificationPreferences() async {
    return NotificationPreferences(
      contributions: _storage.readBool(
        AppConstants.notifyContributionsKey,
      ),
      loans: _storage.readBool(AppConstants.notifyLoansKey),
      meetings: _storage.readBool(AppConstants.notifyMeetingsKey),
      announcements: _storage.readBool(AppConstants.notifyAnnouncementsKey),
    );
  }

  @override
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await _storage.writeBool(
      AppConstants.notifyContributionsKey,
      preferences.contributions,
    );
    await _storage.writeBool(AppConstants.notifyLoansKey, preferences.loans);
    await _storage.writeBool(
      AppConstants.notifyMeetingsKey,
      preferences.meetings,
    );
    await _storage.writeBool(
      AppConstants.notifyAnnouncementsKey,
      preferences.announcements,
    );
    return preferences;
  }

  @override
  Future<void> clearLocalPreferences() {
    return _storage.clearPreferenceKeys();
  }
}
