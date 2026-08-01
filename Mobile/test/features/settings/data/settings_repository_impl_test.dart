import 'package:chamaplus_mobile/core/constants/app_constants.dart';
import 'package:chamaplus_mobile/core/storage/preferences_storage.dart';
import 'package:chamaplus_mobile/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:chamaplus_mobile/features/settings/domain/entities/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PreferencesStorage storage;
  late SettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = PreferencesStorage(await SharedPreferences.getInstance());
    repository = SettingsRepositoryImpl(storage);
  });

  test('loads default notification preferences as enabled', () async {
    final prefs = await repository.getNotificationPreferences();
    expect(prefs.contributions, isTrue);
    expect(prefs.loans, isTrue);
    expect(prefs.meetings, isTrue);
    expect(prefs.announcements, isTrue);
  });

  test('persists notification preference updates', () async {
    final updated = await repository.updateNotificationPreferences(
      const NotificationPreferences(
        contributions: false,
        loans: true,
        meetings: false,
        announcements: true,
      ),
    );
    expect(updated.contributions, isFalse);
    expect(updated.meetings, isFalse);

    final reloaded = await repository.getNotificationPreferences();
    expect(reloaded.contributions, isFalse);
    expect(reloaded.meetings, isFalse);
    expect(
      storage.readBool(AppConstants.notifyContributionsKey),
      isFalse,
    );
  });

  test('clearLocalPreferences removes theme and notification keys', () async {
    await storage.writeThemeMode(ThemeMode.dark);
    await repository.updateNotificationPreferences(
      const NotificationPreferences(contributions: false),
    );
    await repository.clearLocalPreferences();
    expect(storage.readThemeMode(), ThemeMode.system);
    expect(
      (await repository.getNotificationPreferences()).contributions,
      isTrue,
    );
  });
}
