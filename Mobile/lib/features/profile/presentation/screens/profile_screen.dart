import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// Read-only profile overview for the signed-in user.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => context.push(RoutePaths.editProfile),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ApiStateBuilder<User>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 3,
        shimmerItemHeight: 72,
        builder: (context, user) => _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          child: Row(
            children: [
              AvatarBadge(
                initials: _initials(user),
                size: 72,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.phoneNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              InfoTile(
                title: 'Email',
                subtitle: (user.email == null || user.email!.isEmpty)
                    ? 'Not set'
                    : user.email,
                leading: const Icon(Icons.email_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              InfoTile(
                title: 'Member since',
                subtitle: dateFormat.format(user.dateJoined.toLocal()),
                leading: const Icon(Icons.calendar_today_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              if (user.lastLogin != null) ...[
                const Divider(),
                InfoTile(
                  title: 'Last login',
                  subtitle: dateFormat.format(user.lastLogin!.toLocal()),
                  leading: const Icon(Icons.login),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ActionButton(
          label: 'Edit profile',
          icon: Icons.edit_outlined,
          onPressed: () => context.push(RoutePaths.editProfile),
        ),
        const SizedBox(height: AppSpacing.sm),
        ActionButton(
          label: 'Sign out',
          icon: Icons.logout,
          variant: ActionButtonVariant.secondary,
          isDestructive: true,
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ],
    );
  }

  String _initials(User user) {
    final first = user.firstName?.trim();
    final last = user.lastName?.trim();
    if (first != null &&
        first.isNotEmpty &&
        last != null &&
        last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first != null && first.isNotEmpty) {
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    final digits = user.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) return digits.substring(digits.length - 2);
    return '?';
  }
}
