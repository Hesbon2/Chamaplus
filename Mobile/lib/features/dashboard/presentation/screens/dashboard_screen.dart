import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/dashboard.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/dashboard_skeleton.dart';

/// Main authenticated dashboard screen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final themeMode = ref.watch(themeModeProvider);
    final controller = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push(RoutePaths.profile),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              ref.read(onboardingGateProvider.notifier).state =
                  OnboardingGate.unknown;
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ApiStateBuilder<Dashboard>(
        state: dashboardState,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        loading: const DashboardSkeleton(),
        empty: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: EmptyActionCard(
            title: 'No Chama yet',
            message:
                'Join or create a chama to see your dashboard summary.',
            icon: Icons.groups_outlined,
            actionLabel: 'Get started',
            onAction: () => context.push(RoutePaths.welcome),
            secondaryActionLabel: 'Join with code',
            onSecondaryAction: () => context.push(RoutePaths.joinChama),
          ),
        ),
        builder: (context, dashboard) =>
            DashboardContent(dashboard: dashboard),
      ),
    );
  }
}
