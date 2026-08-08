import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/navigation/navigation.dart';

/// Dashboard quick-actions grid powered by [RoleNavigationService].
class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shellCtx = ref.watch(shellNavigationContextProvider);
    final roleActions = RoleNavigationService.quickActionsFor(
      roleLabel: shellCtx.roleLabel,
      chamaId: shellCtx.chamaId,
    );

    // Keep a compact browse grid for core destinations, then role actions.
    final chamaId = shellCtx.chamaId;
    final hasChama = chamaId != null && chamaId.isNotEmpty;
    final browse = <NavQuickAction>[
      const NavQuickAction(
        id: 'browse_chamas',
        label: 'Chamas',
        icon: Icons.groups_outlined,
        route: RoutePaths.chamas,
      ),
      const NavQuickAction(
        id: 'browse_loans',
        label: 'Loans',
        icon: Icons.account_balance_wallet_outlined,
        route: RoutePaths.loans,
      ),
      NavQuickAction(
        id: 'browse_meetings',
        label: 'Meetings',
        icon: Icons.event_outlined,
        route: hasChama
            ? RoutePaths.chamaMeetings(chamaId)
            : RoutePaths.meetings,
      ),
      NavQuickAction(
        id: 'browse_contributions',
        label: 'Contribute',
        icon: Icons.payments_outlined,
        route: hasChama
            ? RoutePaths.chamaContributions(chamaId)
            : RoutePaths.contributions,
      ),
      const NavQuickAction(
        id: 'browse_alerts',
        label: 'Alerts',
        icon: Icons.notifications_outlined,
        route: RoutePaths.alerts,
      ),
      const NavQuickAction(
        id: 'browse_more',
        label: 'More',
        icon: Icons.menu_outlined,
        route: RoutePaths.more,
      ),
    ];

    final seen = <String>{};
    final actions = <NavQuickAction>[];
    for (final action in [...browse, ...roleActions]) {
      if (seen.add(action.id)) actions.add(action);
    }
    final display = actions.take(6).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: display.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final action = display[index];
            return QuickActionTile(
              compact: true,
              label: action.label,
              icon: action.icon,
              onTap: () {
                final route = action.route;
                if (route == RoutePaths.home) return;
                if (route == RoutePaths.chamas ||
                    route == RoutePaths.loans ||
                    route == RoutePaths.alerts ||
                    route == RoutePaths.more) {
                  context.go(route);
                  return;
                }
                context.push(route);
              },
            );
          },
        );
      },
    );
  }
}
