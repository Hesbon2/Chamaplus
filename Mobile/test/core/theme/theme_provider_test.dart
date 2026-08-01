import 'package:chamaplus_mobile/core/storage/preferences_storage.dart';
import 'package:chamaplus_mobile/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ThemeModeNotifier persists selection', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = PreferencesStorage(await SharedPreferences.getInstance());
    final container = ProviderContainer(
      overrides: [
        preferencesStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(storage.readThemeMode(), ThemeMode.light);

    await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(storage.readThemeMode(), ThemeMode.dark);
  });
}
