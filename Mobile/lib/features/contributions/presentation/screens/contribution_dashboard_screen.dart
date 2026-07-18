import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';
import '../widgets/contribution_tiles.dart';

/// Overview of contribution totals, open cycles, and recent payments.
class ContributionDashboardScreen extends ConsumerWidget {
  const ContributionDashboardScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contributionDashboardProvider(chamaId));
    final controller =
        ref.read(contributionDashboardProvider(chamaId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(RoutePaths.recordContribution(chamaId)),
        icon: const Icon(Icons.add),
        label: const Text('Record'),
      ),
      body: ApiStateBuilder<ContributionDashboard>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 5,
        builder: (context, dashboard) {
          final summary = dashboard.summary;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  final cards = [
                    StatCard(
                      label: 'Total collected',
                      value: '${summary.currency} ${summary.totalAmount}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    StatCard(
                      label: 'Payments',
                      value: '${summary.totalCount}',
                      icon: Icons.receipt_long_outlined,
                    ),
                    StatCard(
                      label: 'Open cycles',
                      value: '${dashboard.openCycles.length}',
                      icon: Icons.event_available_outlined,
                      onTap: () => context.push(
                        RoutePaths.contributionCycles(chamaId),
                      ),
                    ),
                  ];
                  if (wide) {
                    return Row(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm),
                        cards[i],
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Quick actions',
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionButton(
                    label: 'Cycles',
                    icon: Icons.loop,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () => context.push(
                      RoutePaths.contributionCycles(chamaId),
                    ),
                  ),
                  ActionButton(
                    label: 'History',
                    icon: Icons.history,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () => context.push(
                      RoutePaths.contributionHistory(chamaId),
                    ),
                  ),
                  ActionButton(
                    label: 'Record',
                    icon: Icons.payments_outlined,
                    expand: false,
                    onPressed: () => context.push(
                      RoutePaths.recordContribution(chamaId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Open cycles',
                actionLabel: 'View all',
                onAction: () =>
                    context.push(RoutePaths.contributionCycles(chamaId)),
              ),
              if (dashboard.openCycles.isEmpty)
                const AppCard(
                  child: Text('No open cycles. Create one to start collecting.'),
                )
              else
                ...dashboard.openCycles.take(3).map(
                      (cycle) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: CycleListTile(
                          cycle: cycle,
                          onTap: () => context.push(
                            RoutePaths.cycleDetails(chamaId, cycle.id),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(
                title: 'Recent contributions',
                actionLabel: 'History',
                onAction: () =>
                    context.push(RoutePaths.contributionHistory(chamaId)),
              ),
              if (dashboard.recentContributions.isEmpty)
                const AppCard(
                  child: Text('No contributions recorded yet.'),
                )
              else
                ...dashboard.recentContributions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ContributionListTile(
                      contribution: item,
                      onTap: () => context.push(
                        RoutePaths.contributionDetails(chamaId, item.id),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}
