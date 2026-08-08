import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chamas/presentation/providers/chama_providers.dart';
import '../../../../core/errors/app_exception.dart';

/// Whether the signed-in user still needs to create or join a chama.
enum OnboardingGate {
  /// Session restored but chama membership not resolved yet.
  unknown,

  /// Authenticated with no active chama memberships.
  needsOnboarding,

  /// Authenticated with at least one active chama.
  ready,

  /// Membership lookup failed (network/API). Stay authenticated; show retry.
  unresolved,
}

final onboardingGateProvider =
    StateProvider<OnboardingGate>((ref) => OnboardingGate.unknown);

/// Resolves whether the user should see Welcome or Home.
///
/// Uses [ProviderContainer] (not [WidgetRef]) so it stays valid if the
/// calling widget is disposed mid-await (e.g. auth redirect).
///
/// Network / API failures set [OnboardingGate.unresolved] — they must never
/// be treated as "no chamas" / Welcome.
Future<OnboardingGate> resolveOnboardingGate(ProviderContainer container) async {
  try {
    final chamas = await container.read(chamaRepositoryProvider).listChamas();
    final gate = chamas.isEmpty
        ? OnboardingGate.needsOnboarding
        : OnboardingGate.ready;
    container.read(onboardingGateProvider.notifier).state = gate;
    return gate;
  } on AppException {
    container.read(onboardingGateProvider.notifier).state =
        OnboardingGate.unresolved;
    return OnboardingGate.unresolved;
  } catch (_) {
    container.read(onboardingGateProvider.notifier).state =
        OnboardingGate.unresolved;
    return OnboardingGate.unresolved;
  }
}

/// Marks onboarding complete after create/join.
void markOnboardingReady(WidgetRef ref) {
  ref.read(onboardingGateProvider.notifier).state = OnboardingGate.ready;
}

/// Marks onboarding as needed.
void markOnboardingNeeded(WidgetRef ref) {
  ref.read(onboardingGateProvider.notifier).state =
      OnboardingGate.needsOnboarding;
}
