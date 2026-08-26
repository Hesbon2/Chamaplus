import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../../../shared/navigation/navigation.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';
import '../utils/chama_ui_mapper.dart';

/// Membership profile for a single Chama member.
class MemberDetailsScreen extends ConsumerWidget {
  const MemberDetailsScreen({
    super.key,
    required this.chamaId,
    required this.membershipId,
  });

  final String chamaId;
  final String membershipId;

  Future<void> _refreshRelated(WidgetRef ref) async {
    ref.invalidate(
      memberDetailsProvider(
        (chamaId: chamaId, membershipId: membershipId),
      ),
    );
    ref.invalidate(membersControllerProvider(chamaId));
    ref.invalidate(chamaDetailsControllerProvider(chamaId));
    ref.invalidate(joinRequestsControllerProvider(chamaId));
    // May affect the signed-in user's role / shell actions.
    ref.invalidate(dashboardProvider);
  }

  Future<void> _changeRole(
    BuildContext context,
    WidgetRef ref,
    Membership member,
  ) async {
    var selected = member.role.slug;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Changing ${member.user.displayName}\'s role may affect '
                    'their Chama permissions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDropdown<String>(
                    label: 'Role',
                    value: selected,
                    items: ChamaAssignableRoles.options
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.$1,
                            child: Text(r.$2),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selected = value);
                    },
                  ),
                ],
              ),
              actions: [
                ActionButton(
                  label: 'Cancel',
                  variant: ActionButtonVariant.text,
                  expand: false,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                ActionButton(
                  label: 'Confirm',
                  expand: false,
                  onPressed: selected == member.role.slug
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final updated =
          await ref.read(manageMembershipControllerProvider.notifier).updateRole(
                membershipId: membershipId,
                role: selected,
              );
      if (!context.mounted) return;
      if (updated == null) {
        final err = ref.read(manageMembershipControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (err == null || err.isEmpty)
              ? 'Could not update role.'
              : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }

      await _refreshRelated(ref);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Member role updated.');
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    Membership member,
    MembershipStatus nextStatus, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final updated = await ref
          .read(manageMembershipControllerProvider.notifier)
          .updateStatus(
            membershipId: membershipId,
            status: nextStatus,
          );
      if (!context.mounted) return;
      if (updated == null) {
        final err = ref.read(manageMembershipControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (err == null || err.isEmpty)
              ? 'Could not update status.'
              : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }

      await _refreshRelated(ref);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Member status updated.');
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMember = ref.watch(
      memberDetailsProvider(
        (chamaId: chamaId, membershipId: membershipId),
      ),
    );
    final role = ref.watch(currentMemberRoleProvider);
    final manageState = ref.watch(manageMembershipControllerProvider);
    final canManage = role.canManageMemberships;

    return Scaffold(
      appBar: AppBar(title: const Text('Member details')),
      body: asyncMember.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ShimmerLoader(itemCount: 4, itemHeight: 72),
        ),
        error: (error, _) => EmptyState(
          title: 'Unable to load member',
          message: error.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(
            memberDetailsProvider(
              (chamaId: chamaId, membershipId: membershipId),
            ),
          ),
        ),
        data: (member) {
          if (member == null) {
            return const EmptyState(
              title: 'Member not found',
              message: 'This membership may have been removed.',
              icon: Icons.person_off_outlined,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      AvatarBadge(
                        initials: member.user.initials,
                        size: 72,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        member.user.displayName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        alignment: WrapAlignment.center,
                        children: [
                          StatusChip(
                            label: member.role.name,
                            tone: StatusChipTone.info,
                          ),
                          StatusChip(
                            label: member.status.label,
                            tone: ChamaUiMapper.toneForStatus(member.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ActionButton(
                  label: 'Contribution summary',
                  icon: Icons.savings_outlined,
                  onPressed: () => context.push(
                    RoutePaths.memberContributionSummary(
                      chamaId,
                      member.user.id,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(title: 'Profile'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      InfoTile(
                        title: 'Phone',
                        subtitle: member.user.phoneNumber,
                        leading: const Icon(Icons.phone_outlined),
                      ),
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Role',
                        subtitle: member.role.name,
                        leading: const Icon(Icons.badge_outlined),
                      ),
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Status',
                        subtitle: member.status.label,
                        leading: const Icon(Icons.verified_outlined),
                      ),
                      if (member.joinedAt != null) ...[
                        const Divider(height: 1),
                        InfoTile(
                          title: 'Joined',
                          subtitle: DateFormat('d MMM yyyy')
                              .format(member.joinedAt!.toLocal()),
                          leading: const Icon(Icons.calendar_today_outlined),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(title: 'Financial summary'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      InfoTile(
                        title: 'Total contributions',
                        subtitle: 'KES ${member.contributionsTotal}',
                        leading: const Icon(Icons.payments_outlined),
                      ),
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Contribution count',
                        subtitle: '${member.contributionsCount}',
                        leading: const Icon(Icons.receipt_long_outlined),
                      ),
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Active loans',
                        subtitle: '${member.activeLoansCount}',
                        leading: const Icon(Icons.account_balance_outlined),
                      ),
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Outstanding loans',
                        subtitle: 'KES ${member.outstandingLoansBalance}',
                        leading:
                            const Icon(Icons.account_balance_wallet_outlined),
                      ),
                    ],
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(title: 'Management'),
                  const SizedBox(height: AppSpacing.sm),
                  if (member.status == MembershipStatus.active) ...[
                    ActionButton(
                      label: 'Change role',
                      icon: Icons.manage_accounts_outlined,
                      variant: ActionButtonVariant.secondary,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeRole(context, ref, member),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ActionButton(
                      label: 'Suspend member',
                      icon: Icons.pause_circle_outline,
                      variant: ActionButtonVariant.secondary,
                      isDestructive: true,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.suspended,
                                title: 'Suspend member?',
                                message:
                                    '${member.user.displayName} will lose active membership access until reactivated.',
                                confirmLabel: 'Suspend',
                                isDestructive: true,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ActionButton(
                      label: 'Mark as left',
                      icon: Icons.logout,
                      isDestructive: true,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.left,
                                title: 'Mark member as left?',
                                message:
                                    'This ends ${member.user.displayName}\'s active membership.',
                                confirmLabel: 'Mark as left',
                                isDestructive: true,
                              ),
                    ),
                  ],
                  if (member.status == MembershipStatus.suspended) ...[
                    ActionButton(
                      label: 'Reactivate member',
                      icon: Icons.play_circle_outline,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.active,
                                title: 'Reactivate member?',
                                message:
                                    'Restore active membership for ${member.user.displayName}.',
                                confirmLabel: 'Reactivate',
                              ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ActionButton(
                      label: 'Mark as left',
                      icon: Icons.logout,
                      isDestructive: true,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.left,
                                title: 'Mark member as left?',
                                message:
                                    'This ends ${member.user.displayName}\'s membership.',
                                confirmLabel: 'Mark as left',
                                isDestructive: true,
                              ),
                    ),
                  ],
                  if (member.status == MembershipStatus.pending) ...[
                    ActionButton(
                      label: 'Approve membership',
                      icon: Icons.check_circle_outline,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.active,
                                title: 'Approve membership?',
                                message:
                                    'Activate membership for ${member.user.displayName}.',
                                confirmLabel: 'Approve',
                              ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ActionButton(
                      label: 'Reject membership',
                      icon: Icons.cancel_outlined,
                      isDestructive: true,
                      onPressed: manageState.isSubmitting
                          ? null
                          : () => _changeStatus(
                                context,
                                ref,
                                member,
                                MembershipStatus.left,
                                title: 'Reject membership?',
                                message:
                                    'This will mark ${member.user.displayName} as left.',
                                confirmLabel: 'Reject',
                                isDestructive: true,
                              ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
