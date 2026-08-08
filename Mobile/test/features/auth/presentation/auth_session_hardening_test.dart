import 'package:chamaplus_mobile/core/cache/offline_cache_store.dart';
import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/routing/pending_deep_link.dart';
import 'package:chamaplus_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:chamaplus_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:chamaplus_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:chamaplus_mobile/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:chamaplus_mobile/shared/auth/session_cleanup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';

class _RecordingAuthRepo extends FakeAuthRepository {
  _RecordingAuthRepo()
      : super(restoreResult: testUser(), loginResult: testUser());

  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
    logoutCalled = true;
  }
}

class _FailingChamaRepo implements ChamaRepository {
  @override
  Future<List<Chama>> listChamas({String? search}) async {
    throw const NetworkException(message: 'Offline');
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyChamaRepo implements ChamaRepository {
  @override
  Future<List<Chama>> listChamas({String? search}) async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReadyChamaRepo implements ChamaRepository {
  @override
  Future<List<Chama>> listChamas({String? search}) async => const [
        Chama(
          id: 'c1',
          name: 'Unity',
          currency: 'KES',
          isActive: true,
        ),
      ];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDashboardRepo implements DashboardRepository {
  bool cleared = false;

  @override
  void clearCache() {
    cleared = true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ForgotAuthRepo implements AuthRepository {
  _ForgotAuthRepo({
    this.requestError,
    this.resetError,
    this.debugCode = '654321',
  });

  Object? requestError;
  Object? resetError;
  String? debugCode;
  bool resetCalled = false;

  @override
  Future<String?> requestPasswordReset({required String phoneNumber}) async {
    if (requestError != null) throw requestError!;
    return debugCode;
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (resetError != null) throw resetError!;
    resetCalled = true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('resolveOnboardingGate', () {
    test('empty chamas → needsOnboarding', () async {
      final container = ProviderContainer(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(_EmptyChamaRepo()),
        ],
      );
      addTearDown(container.dispose);

      final gate = await resolveOnboardingGate(container);
      expect(gate, OnboardingGate.needsOnboarding);
      expect(
        container.read(onboardingGateProvider),
        OnboardingGate.needsOnboarding,
      );
    });

    test('active chamas → ready', () async {
      final container = ProviderContainer(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(_ReadyChamaRepo()),
        ],
      );
      addTearDown(container.dispose);

      final gate = await resolveOnboardingGate(container);
      expect(gate, OnboardingGate.ready);
    });

    test('network failure → unresolved (not Welcome)', () async {
      final container = ProviderContainer(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(_FailingChamaRepo()),
        ],
      );
      addTearDown(container.dispose);

      final gate = await resolveOnboardingGate(container);
      expect(gate, OnboardingGate.unresolved);
      expect(gate, isNot(OnboardingGate.needsOnboarding));
    });
  });

  group('performSecureLogout', () {
    test('clears caches, gate, deep link, and calls server logout', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final offline = OfflineCacheStore(prefs);
      await offline.write(
        key: OfflineCacheStore.keyPrefix + 'GET:/chamas/?',
        data: [
          {'id': 'c1'}
        ],
      );

      final authRepo = _RecordingAuthRepo();
      final dashboard = _FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          offlineCacheStoreProvider.overrideWithValue(offline),
          dashboardRepositoryProvider.overrideWithValue(dashboard),
        ],
      );
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).setAuthenticated(testUser());
      container.read(onboardingGateProvider.notifier).state =
          OnboardingGate.ready;
      container.read(pendingDeepLinkProvider.notifier).state = '/chamas/c1';

      await performSecureLogoutWithReader(
        read: container.read,
        invalidate: container.invalidate,
      );

      expect(authRepo.logoutCalls, 1);
      expect(dashboard.cleared, isTrue);
      expect(container.read(onboardingGateProvider), OnboardingGate.unknown);
      expect(container.read(pendingDeepLinkProvider), isNull);
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      expect(
        offline.read(OfflineCacheStore.keyPrefix + 'GET:/chamas/?'),
        isNull,
      );
    });

    test('session expiry skips server logout but still cleans up', () async {
      SharedPreferences.setMockInitialValues({});
      final offline =
          OfflineCacheStore(await SharedPreferences.getInstance());
      final authRepo = _RecordingAuthRepo();
      final dashboard = _FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          offlineCacheStoreProvider.overrideWithValue(offline),
          dashboardRepositoryProvider.overrideWithValue(dashboard),
        ],
      );
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).setAuthenticated(testUser());

      await performSecureLogoutWithReader(
        read: container.read,
        invalidate: container.invalidate,
        attemptServerLogout: false,
      );

      expect(authRepo.logoutCalls, 0);
      expect(dashboard.cleared, isTrue);
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    });
  });

  group('ForgotPasswordController', () {
    test('requestCode moves to reset step', () async {
      final controller = ForgotPasswordController(_ForgotAuthRepo());
      final ok = await controller.requestCode(phoneNumber: '0712345678');
      expect(ok, isTrue);
      expect(controller.state.step, ForgotPasswordStep.resetPassword);
      expect(controller.state.debugResetCode, '654321');
    });

    test('requestCode surfaces API errors', () async {
      final controller = ForgotPasswordController(
        _ForgotAuthRepo(
          requestError: const ServerException(message: 'Unavailable'),
        ),
      );
      final ok = await controller.requestCode(phoneNumber: '0712345678');
      expect(ok, isFalse);
      expect(controller.state.errorMessage, contains('Unavailable'));
    });

    test('confirmReset succeeds', () async {
      final repo = _ForgotAuthRepo();
      final controller = ForgotPasswordController(repo);
      await controller.requestCode(phoneNumber: '0712345678');
      final ok = await controller.confirmReset(
        code: '654321',
        newPassword: 'NewPass123',
        newPasswordConfirm: 'NewPass123',
      );
      expect(ok, isTrue);
      expect(repo.resetCalled, isTrue);
      expect(controller.state.resetSucceeded, isTrue);
    });

    test('confirmReset surfaces API errors', () async {
      final controller = ForgotPasswordController(
        _ForgotAuthRepo(
          resetError: const ServerException(message: 'Invalid code'),
        ),
      );
      await controller.requestCode(phoneNumber: '0712345678');
      final ok = await controller.confirmReset(
        code: '000000',
        newPassword: 'NewPass123',
        newPasswordConfirm: 'NewPass123',
      );
      expect(ok, isFalse);
      expect(controller.state.errorMessage, contains('Invalid code'));
    });
  });

  testWidgets('ForgotPasswordScreen validates phone before submit',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_ForgotAuthRepo()),
        ],
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send reset code'));
    await tester.pumpAndSettle();

    expect(find.text('Send reset code'), findsOneWidget);
  });
}
