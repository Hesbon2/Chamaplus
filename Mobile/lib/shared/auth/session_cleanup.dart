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

/// Clears session secrets, local caches, and Riverpod state, then signs out.
Future<void> performSecureLogout(WidgetRef ref) async {
  try {
    ref.read(dashboardRepositoryProvider).clearCache();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Dashboard cache clear skipped: $error');
    }
  }

  try {
    await ref.read(offlineCacheStoreProvider).clearAll();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Offline cache clear skipped: $error');
    }
  }

  await ref.read(authControllerProvider.notifier).logout();

  ref.read(onboardingGateProvider.notifier).state = OnboardingGate.unknown;
  ref.read(pendingDeepLinkProvider.notifier).state = null;

  ref.invalidate(profileControllerProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(chamaListControllerProvider);
  ref.invalidate(notificationsDashboardProvider);
  ref.invalidate(notificationUnreadCountProvider);
}
