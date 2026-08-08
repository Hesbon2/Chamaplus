import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/navigation/navigation.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Details for a single loan product with role-aware actions.
class LoanProductDetailsScreen extends ConsumerWidget {
  const LoanProductDetailsScreen({
    super.key,
    required this.chamaId,
    required this.productId,
  });

  final String chamaId;
  final String productId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Delete loan product?',
      message:
          'This permanently removes the product. Existing applications are not deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    final ok = await ref
        .read(manageLoanProductControllerProvider.notifier)
        .delete(chamaId: chamaId, productId: productId);
    if (!context.mounted) return;

    if (!ok) {
      final err = ref.read(manageLoanProductControllerProvider).errorMessage;
      AppSnackbar.error(
        context,
        (err == null || err.isEmpty)
            ? 'Could not delete loan product.'
            : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
      return;
    }

    ref.invalidate(loanProductsControllerProvider(chamaId));
    ref.invalidate(activeLoanProductsProvider(chamaId));
    AppSnackbar.success(context, 'Loan product deleted.');
    context.go(RoutePaths.loanProducts(chamaId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, productId: productId);
    final state = ref.watch(loanProductDetailsProvider(args));
    final controller = ref.read(loanProductDetailsProvider(args).notifier);
    final role = ref.watch(currentMemberRoleProvider);
    final manageState = ref.watch(manageLoanProductControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          if (role.canManageLoanProducts)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                RoutePaths.editLoanProduct(chamaId, productId),
              ),
            ),
        ],
      ),
      body: ApiStateBuilder<LoanProduct>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        StatusChip(
                          label: product.isActive ? 'Active' : 'Inactive',
                          tone: product.isActive
                              ? StatusChipTone.success
                              : StatusChipTone.neutral,
                        ),
                      ],
                    ),
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Terms'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  children: [
                    InfoTile(
                      title: 'Interest rate',
                      subtitle: LoanFormatters.percent(product.interestRate),
                      leading: const Icon(Icons.percent),
                    ),
                    InfoTile(
                      title: 'Amount range',
                      subtitle:
                          '${LoanFormatters.money(product.minimumAmount)} – ${LoanFormatters.money(product.maximumAmount)}',
                      leading: const Icon(Icons.payments_outlined),
                    ),
                    InfoTile(
                      title: 'Maximum duration',
                      subtitle: '${product.maximumDuration} months',
                      leading: const Icon(Icons.schedule),
                    ),
                    InfoTile(
                      title: 'Grace period',
                      subtitle: '${product.gracePeriodDays} days',
                      leading: const Icon(Icons.hourglass_empty),
                    ),
                    InfoTile(
                      title: 'Processing fee',
                      subtitle: LoanFormatters.money(product.processingFee),
                      leading: const Icon(Icons.receipt_long_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Eligibility'),
              const SizedBox(height: AppSpacing.sm),
              const AppCard(
                child: Text(
                  'Active chama members in good standing may apply. '
                  'Committee approval is required before disbursement. '
                  'Your credit score and contribution history may affect approval.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (product.isActive)
                ActionButton(
                  label: 'Apply for Loan',
                  icon: Icons.request_quote_outlined,
                  onPressed: () => context.push(
                    RoutePaths.applyLoan(
                      chamaId,
                      productId: product.id,
                    ),
                  ),
                ),
              if (product.isActive) const SizedBox(height: AppSpacing.sm),
              ActionButton(
                label: 'Open calculator',
                icon: Icons.calculate_outlined,
                variant: ActionButtonVariant.secondary,
                onPressed: () =>
                    context.push(RoutePaths.loanCalculator(chamaId)),
              ),
              if (role.canManageLoanProducts) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(title: 'Management'),
                const SizedBox(height: AppSpacing.sm),
                ActionButton(
                  label: 'Edit product',
                  icon: Icons.edit_outlined,
                  variant: ActionButtonVariant.secondary,
                  onPressed: manageState.isSubmitting
                      ? null
                      : () => context.push(
                            RoutePaths.editLoanProduct(chamaId, productId),
                          ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ActionButton(
                  label: 'Delete product',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onPressed: manageState.isSubmitting
                      ? null
                      : () => _delete(context, ref),
                ),
              ],
              ],
            ),
          );
        },
      ),
    );
  }
}
