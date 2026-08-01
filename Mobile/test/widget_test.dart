import 'package:chamaplus_mobile/app.dart';
import 'package:chamaplus_mobile/core/storage/preferences_storage.dart';
import 'package:chamaplus_mobile/core/theme/theme_provider.dart';
import 'package:chamaplus_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/helpers/fake_auth_repository.dart';

void main() {
  testWidgets('App shows splash then login when unauthenticated',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesStorage(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(restoreResult: null),
          ),
        ],
        child: const ChamaplusApp(),
      ),
    );

    expect(find.text('Restoring your session…'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
