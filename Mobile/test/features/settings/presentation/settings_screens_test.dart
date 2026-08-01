import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/core/storage/preferences_storage.dart';
import 'package:chamaplus_mobile/core/theme/theme_provider.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chamaplus_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:chamaplus_mobile/features/settings/presentation/screens/appearance_settings_screen.dart';
import 'package:chamaplus_mobile/features/settings/presentation/screens/diagnostics_screen.dart';
import 'package:chamaplus_mobile/features/settings/presentation/screens/settings_home_screen.dart';
import 'package:chamaplus_mobile/shared/components/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/helpers/fake_auth_repository.dart';

void main() {
  late PreferencesStorage preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = PreferencesStorage(await SharedPreferences.getInstance());
  });

  ProviderScope wrap(Widget child) {
    final auth = AuthController(FakeAuthRepository(restoreResult: testUser()))
      ..setAuthenticated(testUser());
    return ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(restoreResult: testUser()),
        ),
        authControllerProvider.overrideWith((ref) => auth),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: child,
      ),
    );
  }

  testWidgets('SettingsHomeScreen lists core sections', (tester) async {
    await tester.pumpWidget(wrap(const SettingsHomeScreen()));
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.byType(SettingsTile), findsWidgets);
    expect(find.byType(ProfileHeader), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Notifications'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Notifications'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Help & support'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Help & support'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('About'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('About'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sign out'), findsOneWidget);

    if (kDebugMode) {
      await tester.scrollUntilVisible(
        find.text('Diagnostics'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Diagnostics'), findsOneWidget);
    }
  });

  testWidgets('AppearanceSettingsScreen updates theme mode', (tester) async {
    await tester.pumpWidget(wrap(const AppearanceSettingsScreen()));
    await tester.pump();

    expect(find.byType(ThemeSelector), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(preferences.readThemeMode(), ThemeMode.dark);
  });

  testWidgets('DiagnosticsScreen shows environment details', (tester) async {
    await tester.pumpWidget(wrap(const DiagnosticsScreen()));
    await tester.pump();
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('API base URL'), findsOneWidget);
    expect(find.textContaining('127.0.0.1'), findsOneWidget);
  });

  test('settings route paths are stable', () {
    expect(RoutePaths.settings, '/settings');
    expect(RoutePaths.settingsAppearance, '/settings/appearance');
    expect(RoutePaths.settingsDiagnostics, '/settings/diagnostics');
  });
}
