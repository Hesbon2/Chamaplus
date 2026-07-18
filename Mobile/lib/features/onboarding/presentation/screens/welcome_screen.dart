import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Post-auth landing when the user has no active chama yet.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final theme = Theme.of(context);
    final name = user?.firstName?.trim();
    final greeting = (name != null && name.isNotEmpty)
        ? 'Welcome, $name'
        : 'Welcome to ChamaPlus';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get started'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push(RoutePaths.profile),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 640;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Create a new chama or join one with an invite code.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _createCard(context)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _joinCard(context)),
                          ],
                        )
                      else ...[
                        _createCard(context),
                        const SizedBox(height: AppSpacing.md),
                        _joinCard(context),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      EmptyActionCard(
                        title: 'Waiting for approval?',
                        message:
                            'If a chairperson invited you, wait here while they approve — or join with an invite code.',
                        icon: Icons.hourglass_top_outlined,
                        actionLabel: 'View pending status',
                        onAction: () =>
                            context.push(RoutePaths.pendingApproval),
                        secondaryActionLabel: 'I have an invite code',
                        onSecondaryAction: () =>
                            context.push(RoutePaths.joinChama),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _createCard(BuildContext context) {
    return EmptyActionCard(
      title: 'Create a Chama',
      message:
          'Start a savings group. You become chairperson and get an invite code to share.',
      icon: Icons.add_home_work_outlined,
      actionLabel: 'Create Chama',
      onAction: () => context.push(RoutePaths.createChama),
    );
  }

  Widget _joinCard(BuildContext context) {
    return EmptyActionCard(
      title: 'Join a Chama',
      message:
          'Enter the invite code from your chairperson to become an active member.',
      icon: Icons.group_add_outlined,
      actionLabel: 'Join with code',
      onAction: () => context.push(RoutePaths.joinChama),
    );
  }
}
