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

/// Waiting state for invitees until a chairperson activates membership.
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
      } else {
        AppSnackbar.info(
          context,
          'Still pending. Ask your chairperson to approve, or join with a code.',
        );
      }
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
                        'Waiting for approval',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'When a chairperson invites you, your membership stays pending until they approve it under Join requests. You can also join instantly with an invite code.',
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
                title: 'Check status',
                message:
                    'Refresh to see whether your membership has been activated.',
                icon: Icons.refresh,
                actionLabel: _checking ? 'Checking…' : 'Refresh status',
                onAction: _refreshStatus,
                secondaryActionLabel: 'Join with invite code',
                onSecondaryAction: () => context.push(RoutePaths.joinChama),
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
