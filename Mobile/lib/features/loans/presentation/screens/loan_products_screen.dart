import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_tiles.dart';

/// Lists loan products with search and active filter.
class LoanProductsScreen extends ConsumerStatefulWidget {
  const LoanProductsScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<LoanProductsScreen> createState() => _LoanProductsScreenState();
}

class _LoanProductsScreenState extends ConsumerState<LoanProductsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref
          .read(loanProductsControllerProvider(widget.chamaId).notifier)
          .search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loanProductsControllerProvider(widget.chamaId));
    final controller =
        ref.read(loanProductsControllerProvider(widget.chamaId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Loan products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search products…',
              onChanged: _onSearchChanged,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Active'),
                  selected: controller.activeOnly == true,
                  onSelected: (_) => controller.setActiveOnly(true),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('All'),
                  selected: controller.activeOnly == null,
                  onSelected: (_) => controller.setActiveOnly(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: controller.activeOnly == false,
                  onSelected: (_) => controller.setActiveOnly(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ApiStateBuilder<List<LoanProduct>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No products found',
              emptyMessage: 'Ask your chairperson to create a loan product.',
              emptyIcon: Icons.inventory_2_outlined,
              builder: (context, products) {
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return LoanProductTile(
                      product: product,
                      onTap: () => context.push(
                        RoutePaths.loanProductDetails(
                          widget.chamaId,
                          product.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
