import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = [
    QuickActionItem(
      label: 'Chamas',
      icon: Icons.groups_outlined,
      route: RoutePaths.chamas,
    ),
    QuickActionItem(
      label: 'Contributions',
      icon: Icons.payments_outlined,
      route: RoutePaths.contributions,
    ),
    QuickActionItem(
      label: 'Loans',
      icon: Icons.account_balance_wallet_outlined,
      route: RoutePaths.loans,
    ),
    QuickActionItem(
      label: 'Meetings',
      icon: Icons.event_outlined,
      route: RoutePaths.meetings,
    ),
    QuickActionItem(
      label: 'Reports',
      icon: Icons.assessment_outlined,
      route: RoutePaths.reports,
    ),
    QuickActionItem(
      label: 'Profile',
      icon: Icons.person_outline,
      route: RoutePaths.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];
        return _QuickActionTile(
          action: action,
          onTap: () {
            if (action.route == RoutePaths.home) {
              return;
            }
            context.push(action.route);
          },
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.onTap,
  });

  final QuickActionItem action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                action.label,
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
