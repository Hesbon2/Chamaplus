import '../entities/app_settings.dart';

/// Local settings contract (theme is owned by [ThemeModeNotifier]).
abstract class SettingsRepository {
  Future<NotificationPreferences> getNotificationPreferences();

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  );

  /// Clears non-secret preference keys (theme + notification toggles).
  Future<void> clearLocalPreferences();
}
