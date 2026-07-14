import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/api_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ApiStateBuilder<Dashboard>(
        state: dashboardState,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        loading: const DashboardSkeleton(),
        emptyTitle: 'No Chama yet',
        emptyMessage:
            'Join or create a chama to see your dashboard summary.',
        emptyIcon: Icons.groups_outlined,
        builder: (context, dashboard) =>
            DashboardContent(dashboard: dashboard),
      ),
    );
  }
}
