import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';
import '../widgets/loan_tiles.dart';

/// Loan overview for a chama: active loan, limit, score, recent apps.
class LoanDashboardScreen extends ConsumerWidget {
  const LoanDashboardScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loanDashboardProvider(chamaId));
    final controller = ref.read(loanDashboardProvider(chamaId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.applyLoan(chamaId)),
        icon: const Icon(Icons.add),
        label: const Text('Apply'),
      ),
      body: ApiStateBuilder<LoanDashboard>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 5,
        builder: (context, dashboard) {
          final currency = dashboard.currency;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (dashboard.activeLoan != null) ...[
                ProgressStatCard(
                  title: 'Outstanding loan',
                  subtitle: dashboard.activeProduct?.name,
                  currentValue: LoanFormatters.money(
                    dashboard.outstandingBalance,
                    currency: currency,
                  ),
                  targetValue:
                      'of ${LoanFormatters.money(dashboard.activeLoan!.principalAmount, currency: currency)}',
                  percentage: dashboard.activeLoan!.repaymentProgressPercent,
                  icon: Icons.trending_down,
                  progressColor: AppColors.secondaryDark,
                  onTap: () => context.push(
                    RoutePaths.activeLoan(chamaId, dashboard.activeLoan!.id),
                  ),
                  footer: dashboard.nextInstallmentEstimate == null
                      ? null
                      : Text(
                          'Est. next installment ${LoanFormatters.money(dashboard.nextInstallmentEstimate!, currency: currency)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  final cards = [
                    StatCard(
                      label: 'Loan limit',
                      value: LoanFormatters.money(
                        dashboard.loanLimit,
                        currency: currency,
                      ),
                      icon: Icons.shield_outlined,
                      onTap: () =>
                          context.push(RoutePaths.loanProducts(chamaId)),
                    ),
                    StatCard(
                      label: 'Outstanding',
                      value: LoanFormatters.money(
                        dashboard.outstandingBalance,
                        currency: currency,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppColors.secondaryDark,
                    ),
                    StatCard(
                      label: 'Credit score',
                      value: dashboard.creditScore == null
                          ? 'N/A'
                          : '${dashboard.creditScore!.score}',
                      subtitle: dashboard.creditScore?.riskLevel,
                      icon: Icons.verified_outlined,
                      accentColor: AppColors.info,
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
              const SectionHeader(title: 'Quick actions'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionButton(
                    label: 'Products',
                    icon: Icons.inventory_2_outlined,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.loanProducts(chamaId)),
                  ),
                  ActionButton(
                    label: 'Calculator',
                    icon: Icons.calculate_outlined,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.loanCalculator(chamaId)),
                  ),
                  ActionButton(
                    label: 'History',
                    icon: Icons.history,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.loanHistory(chamaId)),
                  ),
                  ActionButton(
                    label: 'Apply',
                    icon: Icons.request_quote_outlined,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.applyLoan(chamaId)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent applications',
                actionLabel: 'See all',
                onAction: () => context.push(RoutePaths.loanHistory(chamaId)),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (dashboard.recentApplications.isEmpty)
                const EmptyState(
                  title: 'No applications yet',
                  message: 'Apply for a loan product to get started.',
                  icon: Icons.request_quote_outlined,
                )
              else
                ...dashboard.recentApplications.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: LoanApplicationTile(
                      application: app,
                      onTap: () => context.push(
                        RoutePaths.loanDetails(chamaId, app.id),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
