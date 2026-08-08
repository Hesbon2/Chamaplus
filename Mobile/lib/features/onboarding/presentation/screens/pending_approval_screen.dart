import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';
import '../../../chamas/presentation/providers/chama_providers.dart';
import '../providers/onboarding_providers.dart';

/// Waiting state helper that points invitees to pending invitations.
class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _checking = false;

  Future<void> _refreshStatus() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final chamas = await ref.read(chamaRepositoryProvider).listChamas();
      if (!mounted) return;
      if (chamas.isNotEmpty) {
        markOnboardingReady(ref);
        AppSnackbar.success(context, 'You are now an active member!');
        context.go(RoutePaths.chamaDetails(chamas.first.id));
        return;
      }

      final pending =
          await ref.read(chamaRepositoryProvider).listPendingInvitations();
      if (!mounted) return;
      if (pending.isNotEmpty) {
        context.push(RoutePaths.pendingInvitations);
        return;
      }

      AppSnackbar.info(
        context,
        'No active membership yet. Check pending invitations or join with a code.',
      );
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not refresh status.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending approval')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: child,
                ),
                child: AppCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_top_outlined,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Waiting to join a Chama',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Phone invitations appear under Pending invitations where you can accept or decline. You can also join instantly with an invite code.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              EmptyActionCard(
                title: 'Pending invitations',
                message:
                    'Review invitations sent to your phone number and respond.',
                icon: Icons.mail_outline,
                actionLabel: 'View invitations',
                onAction: () => context.push(RoutePaths.pendingInvitations),
                secondaryActionLabel: 'Join with invite code',
                onSecondaryAction: () => context.push(RoutePaths.joinChama),
              ),
              const SizedBox(height: AppSpacing.md),
              ActionButton(
                label: _checking ? 'Checking…' : 'Refresh status',
                icon: Icons.refresh,
                variant: ActionButtonVariant.secondary,
                isLoading: _checking,
                onPressed: _refreshStatus,
              ),
              const Spacer(),
              ActionButton(
                label: 'Back to welcome',
                variant: ActionButtonVariant.text,
                onPressed: () => context.go(RoutePaths.welcome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
