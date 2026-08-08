import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/offline_cache_store.dart';
import '../../core/routing/pending_deep_link.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/chamas/presentation/providers/chama_providers.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';

/// Canonical session teardown used by every logout / session-expiry path.
///
/// Clears caches, resets onboarding + deep-link state, invalidates user-scoped
/// providers, and either calls the server logout API or marks the session
/// expired locally (when tokens were already cleared by the interceptor).
Future<void> performSecureLogout(
  WidgetRef ref, {
  bool attemptServerLogout = true,
}) {
  return performSecureLogoutWithReader(
    read: ref.read,
    invalidate: ref.invalidate,
    attemptServerLogout: attemptServerLogout,
  );
}

/// Same cleanup for [Ref] (e.g. session-expiry from [authControllerProvider]).
Future<void> performSecureLogoutWithReader({
  required T Function<T>(ProviderListenable<T> provider) read,
  required void Function(ProviderOrFamily provider) invalidate,
  bool attemptServerLogout = true,
}) async {
  try {
    read(dashboardRepositoryProvider).clearCache();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Dashboard cache clear skipped: $error');
    }
  }

  try {
    await read(offlineCacheStoreProvider).clearAll();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Offline cache clear skipped: $error');
    }
  }

  final auth = read(authControllerProvider.notifier);
  if (attemptServerLogout) {
    await auth.logout();
  } else {
    auth.onSessionExpired();
  }

  read(onboardingGateProvider.notifier).state = OnboardingGate.unknown;
  read(pendingDeepLinkProvider.notifier).state = null;

  invalidate(profileControllerProvider);
  invalidate(dashboardProvider);
  invalidate(chamaListControllerProvider);
  invalidate(pendingInvitationsControllerProvider);
  invalidate(notificationsDashboardProvider);
  invalidate(notificationUnreadCountProvider);
}
