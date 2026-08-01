import 'package:chamaplus_mobile/core/storage/preferences_storage.dart';
import 'package:chamaplus_mobile/core/theme/theme_provider.dart';
import 'package:chamaplus_mobile/features/settings/domain/entities/app_settings.dart';
import 'package:chamaplus_mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:chamaplus_mobile/features/settings/presentation/controllers/settings_controllers.dart';
import 'package:chamaplus_mobile/features/settings/presentation/providers/settings_providers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSettingsRepository implements SettingsRepository {
  NotificationPreferences prefs = const NotificationPreferences();

  @override
  Future<void> clearLocalPreferences() async {}

  @override
  Future<NotificationPreferences> getNotificationPreferences() async => prefs;

  @override
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    prefs = preferences;
    return prefs;
  }
}

void main() {
  test('NotificationPreferencesController patches and persists', () async {
    final repo = _FakeSettingsRepository();
    final controller = NotificationPreferencesController(repository: repo);
    await controller.load();
    expect(controller.state.isSuccess, isTrue);

    await controller.setContributions(false);
    expect(controller.state.data!.contributions, isFalse);
    expect(repo.prefs.contributions, isFalse);
  });

  test('notificationPreferencesProvider loads via override', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = PreferencesStorage(await SharedPreferences.getInstance());
    final container = ProviderContainer(
      overrides: [
        preferencesStorageProvider.overrideWithValue(storage),
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationPreferencesProvider.notifier).load();
    final state = container.read(notificationPreferencesProvider);
    expect(state.status, ApiStatus.success);
  });
}
