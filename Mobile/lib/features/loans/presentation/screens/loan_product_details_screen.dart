import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Details for a single loan product with apply CTA.
class LoanProductDetailsScreen extends ConsumerWidget {
  const LoanProductDetailsScreen({
    super.key,
    required this.chamaId,
    required this.productId,
  });

  final String chamaId;
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, productId: productId);
    final state = ref.watch(loanProductDetailsProvider(args));
    final controller = ref.read(loanProductDetailsProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: ApiStateBuilder<LoanProduct>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, product) {
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
              AppCard(
                child: Column(
                  children: [
                    InfoTile(
                      title: 'Interest rate',
                      subtitle: LoanFormatters.percent(product.interestRate),
                      leading: const Icon(Icons.percent),
                    ),
                    InfoTile(
                      title: 'Minimum amount',
                      subtitle: LoanFormatters.money(product.minimumAmount),
                      leading: const Icon(Icons.arrow_downward),
                    ),
                    InfoTile(
                      title: 'Maximum amount',
                      subtitle: LoanFormatters.money(product.maximumAmount),
                      leading: const Icon(Icons.arrow_upward),
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
              ActionButton(
                label: 'Apply for this loan',
                icon: Icons.request_quote_outlined,
                onPressed: product.isActive
                    ? () => context.push(
                          RoutePaths.applyLoan(
                            chamaId,
                            productId: product.id,
                          ),
                        )
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionButton(
                label: 'Open calculator',
                icon: Icons.calculate_outlined,
                variant: ActionButtonVariant.secondary,
                onPressed: () =>
                    context.push(RoutePaths.loanCalculator(chamaId)),
              ),
            ],
          );
        },
      ),
    );
  }
}
