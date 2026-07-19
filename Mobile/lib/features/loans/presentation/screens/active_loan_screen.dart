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

/// Focused view of an active (disbursed) loan.
class ActiveLoanScreen extends ConsumerWidget {
  const ActiveLoanScreen({
    super.key,
    required this.chamaId,
    required this.applicationId,
  });

  final String chamaId;
  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, applicationId: applicationId);
    final state = ref.watch(loanDetailsControllerProvider(args));
    final controller = ref.read(loanDetailsControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Active loan')),
      body: ApiStateBuilder<LoanApplication>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, app) {
          final paid = app.amountPaid;
          final outstanding = app.outstandingBalance ?? 0;
          final remainingInstallments = app.requestedDuration <= 0
              ? 0
              : ((outstanding /
                          (app.principalAmount / app.requestedDuration))
                      .ceil())
                  .clamp(0, app.requestedDuration);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ProgressStatCard(
                title: 'Loan progress',
                subtitle: app.purpose,
                currentValue: LoanFormatters.money(paid),
                targetValue:
                    'of ${LoanFormatters.money(app.principalAmount)}',
                percentage: app.repaymentProgressPercent,
                icon: Icons.savings_outlined,
                progressColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    StatCard(
                      label: 'Original amount',
                      value: LoanFormatters.money(app.principalAmount),
                      icon: Icons.account_balance_outlined,
                    ),
                    StatCard(
                      label: 'Amount paid',
                      value: LoanFormatters.money(paid),
                      icon: Icons.check_circle_outline,
                      accentColor: AppColors.success,
                    ),
                    StatCard(
                      label: 'Outstanding',
                      value: LoanFormatters.money(outstanding),
                      icon: Icons.pending_outlined,
                      accentColor: AppColors.secondaryDark,
                    ),
                    StatCard(
                      label: 'Est. installments left',
                      value: '$remainingInstallments',
                      icon: Icons.calendar_month_outlined,
                    ),
                  ];
                  if (constraints.maxWidth > 600) {
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: cards
                          .map(
                            (c) => SizedBox(
                              width: (constraints.maxWidth - AppSpacing.sm) / 2,
                              child: c,
                            ),
                          )
                          .toList(),
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
              ActionButton(
                label: 'View repayment history',
                icon: Icons.history,
                onPressed: () => context.push(
                  RoutePaths.loanRepaymentHistory(chamaId, applicationId),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionButton(
                label: 'Application details',
                icon: Icons.info_outline,
                variant: ActionButtonVariant.secondary,
                onPressed: () => context.push(
                  RoutePaths.loanDetails(chamaId, applicationId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
