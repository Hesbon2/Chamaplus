import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/auth_providers.dart';

/// Initial screen that restores the user session before routing.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _bootstrapping = true;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _bootstrapping = true;
      _resolveError = null;
    });

    await ref.read(authControllerProvider.notifier).restoreSession();
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      final gate =
          await resolveOnboardingGate(ProviderScope.containerOf(context));
      if (!mounted) return;
      if (gate == OnboardingGate.unresolved) {
        setState(() {
          _bootstrapping = false;
          _resolveError =
              'We could not verify your chama membership. Check your connection and try again.';
        });
        return;
      }
    } else {
      ref.read(onboardingGateProvider.notifier).state = OnboardingGate.unknown;
    }

    if (mounted) {
      setState(() => _bootstrapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gate = ref.watch(onboardingGateProvider);
    final showRetry = !_bootstrapping &&
        gate == OnboardingGate.unresolved &&
        _resolveError != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceDark]
                : [AppColors.backgroundLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (showRetry) ...[
                  EmptyState(
                    title: 'Connection problem',
                    message: _resolveError,
                    icon: Icons.wifi_off_outlined,
                    actionLabel: 'Try again',
                    onAction: _bootstrap,
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Restoring your session…',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
