import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Loan application detail with timeline, votes, and actions.
class LoanDetailsScreen extends ConsumerWidget {
  const LoanDetailsScreen({
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
      appBar: AppBar(title: const Text('Loan details')),
      body: ApiStateBuilder<LoanApplication>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, app) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LoanFormatters.money(app.requestedAmount),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: StatusChip(
                            key: ValueKey(app.status),
                            label: app.status.label,
                            tone: LoanUiMapper.toneForStatus(app.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(app.purpose),
                    if (app.remarks != null && app.remarks!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        app.remarks!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (app.status.isActiveLoan ||
                  app.outstandingBalance != null) ...[
                const SizedBox(height: AppSpacing.md),
                ProgressStatCard(
                  title: 'Repayment progress',
                  currentValue: LoanFormatters.money(app.amountPaid),
                  targetValue:
                      'of ${LoanFormatters.money(app.principalAmount)}',
                  percentage: app.repaymentProgressPercent,
                  icon: Icons.trending_up,
                  progressColor: AppColors.primary,
                  footer: Text(
                    'Outstanding ${LoanFormatters.money(app.outstandingBalance ?? 0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: app.status.isActiveLoan
                      ? () => context.push(
                            RoutePaths.activeLoan(chamaId, app.id),
                          )
                      : null,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Timeline'),
              AppCard(
                child: Column(
                  children: [
                    InfoTile(
                      title: 'Applied',
                      subtitle: LoanFormatters.date(app.appliedAt ?? app.createdAt),
                      leading: const Icon(Icons.edit_calendar_outlined),
                    ),
                    InfoTile(
                      title: 'Approved',
                      subtitle: LoanFormatters.date(app.approvedAt),
                      leading: const Icon(Icons.verified_outlined),
                    ),
                    InfoTile(
                      title: 'Rejected',
                      subtitle: LoanFormatters.date(app.rejectedAt),
                      leading: const Icon(Icons.cancel_outlined),
                    ),
                    InfoTile(
                      title: 'Duration',
                      subtitle: '${app.requestedDuration} months',
                      leading: const Icon(Icons.schedule),
                    ),
                    if (app.approvedAmount != null)
                      InfoTile(
                        title: 'Approved amount',
                        subtitle: LoanFormatters.money(app.approvedAmount!),
                        leading: const Icon(Icons.payments_outlined),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(
                title: 'Committee votes',
                actionLabel: app.status == LoanApplicationStatus.pending
                    ? 'Vote'
                    : null,
                onAction: app.status == LoanApplicationStatus.pending
                    ? () => context.push(
                          RoutePaths.loanCommitteeVoting(chamaId, app.id),
                        )
                    : null,
              ),
              if (controller.votes.isEmpty)
                const AppCard(
                  child: Text('No votes cast yet.'),
                )
              else
                ...controller.votes.map(
                  (vote) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vote.decision.label,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (vote.comment != null)
                                  Text(vote.comment!),
                                Text(
                                  LoanFormatters.date(vote.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: vote.decision.label,
                            tone: LoanUiMapper.toneForVote(vote.decision),
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Actions'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (app.status.isActiveLoan)
                    ActionButton(
                      label: 'Repayments',
                      icon: Icons.history,
                      expand: false,
                      variant: ActionButtonVariant.secondary,
                      onPressed: () => context.push(
                        RoutePaths.loanRepaymentHistory(chamaId, app.id),
                      ),
                    ),
                  if (app.status == LoanApplicationStatus.draft)
                    ActionButton(
                      label: 'Submit',
                      icon: Icons.send_outlined,
                      expand: false,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final ok = await controller.submit();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Application submitted.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                  if (app.status == LoanApplicationStatus.draft ||
                      app.status == LoanApplicationStatus.pending)
                    ActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      expand: false,
                      variant: ActionButtonVariant.secondary,
                      isDestructive: true,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final confirmed = await showAppConfirmationDialog(
                          context: context,
                          title: 'Cancel application?',
                          message: 'This cannot be undone.',
                          confirmLabel: 'Cancel application',
                          isDestructive: true,
                        );
                        if (!confirmed) return;
                        final ok = await controller.cancel();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Application cancelled.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                  if (app.status == LoanApplicationStatus.pending) ...[
                    ActionButton(
                      label: 'Approve',
                      icon: Icons.check,
                      expand: false,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final ok = await controller.approve();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Application approved.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                    ActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      expand: false,
                      variant: ActionButtonVariant.secondary,
                      isDestructive: true,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final ok = await controller.reject();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Application rejected.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                  ],
                  if (app.status == LoanApplicationStatus.approved)
                    ActionButton(
                      label: 'Disburse',
                      icon: Icons.payments_outlined,
                      expand: false,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final ok = await controller.disburse();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Loan disbursed.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
