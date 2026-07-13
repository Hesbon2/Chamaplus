import 'package:chamaplus_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    test('restoreSession sets authenticated when user is returned', () async {
      repository.restoreResult = testUser();
      final controller = AuthController(repository);

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user?.displayName, 'Jane Doe');
    });

    test('restoreSession sets unauthenticated when no session', () async {
      repository.restoreResult = null;
      final controller = AuthController(repository);

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.user, isNull);
    });

    test('logout clears authenticated state', () async {
      repository.restoreResult = testUser();
      final controller = AuthController(repository);
      await controller.restoreSession();

      await controller.logout();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(repository.logoutCalled, isTrue);
    });

    test('onSessionExpired sets unauthenticated', () {
      final controller = AuthController(repository);
      controller.setAuthenticated(testUser());

      controller.onSessionExpired();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.user, isNull);
    });
  });
}
