import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Invitee inbox: accept or decline pending Chama invitations.
class PendingInvitationsScreen extends ConsumerStatefulWidget {
  const PendingInvitationsScreen({super.key});

  @override
  ConsumerState<PendingInvitationsScreen> createState() =>
      _PendingInvitationsScreenState();
}

class _PendingInvitationsScreenState
    extends ConsumerState<PendingInvitationsScreen> {
  String? _busyMembershipId;

  Future<void> _accept(Membership invitation) async {
    if (_busyMembershipId != null) return;
    setState(() => _busyMembershipId = invitation.id);
    try {
      final controller =
          ref.read(pendingInvitationsControllerProvider.notifier);
      final accepted = await controller.accept(invitation.id);
      if (!mounted) return;
      if (accepted == null) {
        AppSnackbar.error(context, 'Could not accept invitation.');
        return;
      }

      markOnboardingReady(ref);
      ref.invalidate(dashboardProvider);
      ref.invalidate(chamaListControllerProvider);

      final chamaId = accepted.chamaId ?? invitation.chamaId;
      AppSnackbar.success(
        context,
        'Welcome to ${accepted.chamaName ?? invitation.chamaName ?? 'your chama'}!',
      );
      if (chamaId != null && chamaId.isNotEmpty) {
        context.go(RoutePaths.chamaDetails(chamaId));
      } else {
        context.go(RoutePaths.home);
      }
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not accept invitation.');
    } finally {
      if (mounted) setState(() => _busyMembershipId = null);
    }
  }

  Future<void> _decline(Membership invitation) async {
    if (_busyMembershipId != null) return;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Decline invitation?',
      message:
          'You will decline the invitation to ${invitation.chamaName ?? 'this chama'}. '
          'You can be invited again later.',
      confirmLabel: 'Decline',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyMembershipId = invitation.id);
    try {
      await ref
          .read(pendingInvitationsControllerProvider.notifier)
          .decline(invitation.id);
      if (!mounted) return;
      AppSnackbar.info(context, 'Invitation declined.');
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not decline invitation.');
    } finally {
      if (mounted) setState(() => _busyMembershipId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingInvitationsControllerProvider);
    final controller =
        ref.read(pendingInvitationsControllerProvider.notifier);
    final pendingCount = state.data?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pendingCount > 0
              ? 'Pending invitations ($pendingCount)'
              : 'Pending invitations',
        ),
      ),
      body: ApiStateBuilder<List<Membership>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        isEmpty: (items) => items.isEmpty,
        emptyTitle: 'No pending invitations',
        emptyMessage:
            'When a chairperson or secretary invites you by phone, it will show up here.',
        emptyIcon: Icons.mail_outline,
        builder: (context, invitations) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: invitations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              final busy = _busyMembershipId == invitation.id;
              return _InvitationCard(
                invitation: invitation,
                isBusy: busy,
                onAccept: () => _accept(invitation),
                onDecline: () => _decline(invitation),
              );
            },
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
  });

  final Membership invitation;
  final bool isBusy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chamaName = invitation.chamaName?.trim().isNotEmpty == true
        ? invitation.chamaName!
        : 'Chama invitation';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  chamaName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StatusChip(
                label: invitation.status.label,
                tone: StatusChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoTile(
            title: 'Invited role',
            subtitle: invitation.role.name,
            leading: const Icon(Icons.badge_outlined),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          if (invitation.createdAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            InfoTile(
              title: 'Invited on',
              subtitle: _formatDate(invitation.createdAt!),
              leading: const Icon(Icons.event_outlined),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Decline',
                  variant: ActionButtonVariant.secondary,
                  isDestructive: true,
                  isLoading: isBusy,
                  expand: true,
                  onPressed: isBusy ? null : onDecline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ActionButton(
                  label: 'Accept',
                  isLoading: isBusy,
                  expand: true,
                  onPressed: isBusy ? null : onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
