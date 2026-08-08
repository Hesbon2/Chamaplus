import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/navigation/navigation.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Pending membership invitations awaiting chairperson decision.
class JoinRequestsScreen extends ConsumerWidget {
  const JoinRequestsScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(joinRequestsControllerProvider(chamaId));
    final controller =
        ref.read(joinRequestsControllerProvider(chamaId).notifier);
    final canManage =
        ref.watch(currentMemberRoleProvider).canManageMemberships;

    ref.listen(joinRequestsControllerProvider(chamaId), (previous, next) {
      final ctrl = ref.read(joinRequestsControllerProvider(chamaId).notifier);
      if (ctrl.errorMessage != null) {
        AppSnackbar.error(context, ctrl.errorMessage!);
        ctrl.errorMessage = null;
      }
      if (ctrl.actionMessage != null) {
        AppSnackbar.success(context, ctrl.actionMessage!);
        ctrl.actionMessage = null;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Join requests')),
      body: ApiStateBuilder<List<Membership>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        emptyTitle: 'No pending requests',
        emptyMessage: canManage
            ? 'Invited members waiting for approval will appear here.'
            : 'Only the chairperson can approve or reject join requests.',
        emptyIcon: Icons.mark_email_read_outlined,
        shimmerItemCount: 4,
        shimmerItemHeight: 96,
        builder: (context, requests) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: requests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final request = requests[index];
              final processing =
                  controller.processingIds.contains(request.id);

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AvatarBadge(initials: request.user.initials),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.user.displayName,
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                request.user.phoneNumber,
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(
                          label: 'Pending',
                          tone: StatusChipTone.warning,
                          compact: true,
                        ),
                      ],
                    ),
                    if (canManage) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              label: 'Reject',
                              variant: ActionButtonVariant.secondary,
                              isDestructive: true,
                              isLoading: processing,
                              expand: true,
                              onPressed: processing
                                  ? null
                                  : () async {
                                      final confirmed =
                                          await showAppConfirmationDialog(
                                        context: context,
                                        title: 'Reject join request?',
                                        message:
                                            'This will mark ${request.user.displayName} as left.',
                                        confirmLabel: 'Reject',
                                        isDestructive: true,
                                      );
                                      if (!confirmed) return;
                                      await controller.reject(request.id);
                                    },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ActionButton(
                              label: 'Approve',
                              isLoading: processing,
                              expand: true,
                              onPressed: processing
                                  ? null
                                  : () async {
                                      final confirmed =
                                          await showAppConfirmationDialog(
                                        context: context,
                                        title: 'Approve join request?',
                                        message:
                                            'Activate membership for ${request.user.displayName}.',
                                        confirmLabel: 'Approve',
                                      );
                                      if (!confirmed) return;
                                      await controller.approve(request.id);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Waiting for chairperson approval.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
