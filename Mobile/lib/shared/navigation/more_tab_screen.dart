import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_paths.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../components/components.dart';
import 'quick_action_tile.dart';
import 'role_navigation_service.dart';

/// More tab — overflow destinations (governance, settings stubs, profile).
class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authControllerProvider).user;
    final actions = RoleNavigationService.moreMenuActions();

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Row(
              children: [
                AvatarBadge(
                  initials: user?.displayName.isNotEmpty == true
                      ? user!.displayName[0]
                      : 'U',
                  icon: Icons.person_outline,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Member',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user?.phoneNumber ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () => context.push(RoutePaths.editProfile),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Explore'),
          const SizedBox(height: AppSpacing.sm),
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: QuickActionTile(
                label: action.label,
                subtitle: action.subtitle,
                icon: action.icon,
                onTap: () => context.push(action.route),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Preferences'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark mode'),
              subtitle: Text(
                themeMode == ThemeMode.dark
                    ? 'On'
                    : themeMode == ThemeMode.light
                        ? 'Off'
                        : 'System',
              ),
              value: themeMode == ThemeMode.dark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ActionButton(
            label: 'Sign out',
            icon: Icons.logout,
            isDestructive: true,
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              ref.read(onboardingGateProvider.notifier).state =
                  OnboardingGate.unknown;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
