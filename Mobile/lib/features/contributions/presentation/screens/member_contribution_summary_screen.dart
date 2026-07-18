import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';

/// Member-level contribution and financial summary.
class MemberContributionSummaryScreen extends ConsumerWidget {
  const MemberContributionSummaryScreen({
    super.key,
    required this.chamaId,
    required this.memberId,
    this.memberName,
  });

  final String chamaId;
  final String memberId;
  final String? memberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, memberId: memberId);
    final state = ref.watch(memberContributionSummaryProvider(args));
    final controller =
        ref.read(memberContributionSummaryProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(memberName ?? 'Member contributions'),
      ),
      body: ApiStateBuilder<MemberContributionSummary>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, summary) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  final cards = [
                    StatCard(
                      label: 'Contributions',
                      value: summary.contributionsTotal,
                      subtitle: '${summary.contributionsCount} payments',
                      icon: Icons.savings_outlined,
                    ),
                    StatCard(
                      label: 'Active loans',
                      value: '${summary.activeLoans}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    StatCard(
                      label: 'Credit score',
                      value: summary.creditScore?.toString() ?? '—',
                      subtitle: summary.creditRiskLevel,
                      icon: Icons.insights_outlined,
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
                      for (final card in cards) ...[
                        card,
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (summary.repaymentsTotal != null)
                AppCard(
                  child: InfoTile(
                    title: 'Repayments total',
                    subtitle: summary.repaymentsTotal,
                    leading: const Icon(Icons.payments_outlined),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              ActionButton(
                label: 'View contribution history',
                icon: Icons.history,
                onPressed: () => context.push(
                  RoutePaths.contributionHistory(
                    chamaId,
                    memberId: memberId,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
