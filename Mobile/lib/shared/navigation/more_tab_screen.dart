import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_paths.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/auth/session_cleanup.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../components/components.dart';
import 'navigation_provider.dart';
import 'quick_action_tile.dart';
import 'role_navigation_service.dart';

/// More tab — overflow destinations including Settings.
class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final chamaId = ref.watch(shellNavigationContextProvider).chamaId;
    final actions = RoleNavigationService.moreMenuActions(chamaId: chamaId);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ProfileHeader(
            displayName: user?.displayName ?? 'Member',
            subtitle: user?.phoneNumber,
            onTap: () => context.push(RoutePaths.profile),
            trailing: IconButton(
              tooltip: 'Edit profile',
              onPressed: () => context.push(RoutePaths.editProfile),
              icon: const Icon(Icons.edit_outlined),
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
          ActionButton(
            label: 'Sign out',
            icon: Icons.logout,
            isDestructive: true,
            onPressed: () async {
              final confirmed = await showAppConfirmationDialog(
                context: context,
                title: 'Sign out?',
                message:
                    'You will need to sign in again to access your chamas.',
                confirmLabel: 'Sign out',
                isDestructive: true,
              );
              if (confirmed) {
                await performSecureLogout(ref);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
