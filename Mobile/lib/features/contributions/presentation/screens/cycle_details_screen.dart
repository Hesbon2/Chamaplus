import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';
import '../utils/contribution_ui_mapper.dart';

/// Details for a single contribution cycle, with close action.
class CycleDetailsScreen extends ConsumerWidget {
  const CycleDetailsScreen({
    super.key,
    required this.chamaId,
    required this.cycleId,
  });

  final String chamaId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, cycleId: cycleId);
    final state = ref.watch(cycleDetailsControllerProvider(args));
    final controller =
        ref.read(cycleDetailsControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.data?.name ?? 'Cycle details'),
      ),
      body: ApiStateBuilder<ContributionCycle>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, cycle) {
          final dateFmt = DateFormat('EEE, d MMM yyyy');
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
                            cycle.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        StatusChip(
                          label: cycle.status.label,
                          tone: ContributionUiMapper.toneForCycle(
                            cycle.status,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InfoTile(
                      title: 'Frequency',
                      subtitle: cycle.frequency.label,
                      leading: const Icon(Icons.repeat),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Expected amount',
                      subtitle: cycle.contributionAmount,
                      leading: const Icon(Icons.payments_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Penalty',
                      subtitle: cycle.penaltyAmount,
                      leading: const Icon(Icons.warning_amber_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Due day',
                      subtitle: '${cycle.dueDay}',
                      leading: const Icon(Icons.today_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Period',
                      subtitle:
                          '${dateFmt.format(cycle.startDate)} – ${dateFmt.format(cycle.endDate)}',
                      leading: const Icon(Icons.date_range),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ActionButton(
                label: 'View contributions',
                icon: Icons.history,
                onPressed: () => context.push(
                  RoutePaths.contributionHistory(
                    chamaId,
                    cycleId: cycle.id,
                  ),
                ),
              ),
              if (cycle.isOpen) ...[
                const SizedBox(height: AppSpacing.sm),
                ActionButton(
                  label: 'Close cycle',
                  variant: ActionButtonVariant.secondary,
                  isDestructive: true,
                  isLoading: controller.isClosing,
                  icon: Icons.lock_outline,
                  onPressed: controller.isClosing
                      ? null
                      : () async {
                          final confirmed = await showAppConfirmationDialog(
                            context: context,
                            title: 'Close this cycle?',
                            message:
                                'Closed cycles cannot accept new contributions.',
                            confirmLabel: 'Close cycle',
                            isDestructive: true,
                          );
                          if (!confirmed) return;
                          final ok = await controller.closeCycle();
                          if (!context.mounted) return;
                          if (ok) {
                            AppSnackbar.success(context, 'Cycle closed.');
                          } else {
                            AppSnackbar.error(
                              context,
                              controller.actionError ??
                                  'Failed to close cycle.',
                            );
                          }
                        },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
