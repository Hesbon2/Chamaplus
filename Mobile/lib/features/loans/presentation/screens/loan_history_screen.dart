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

/// Paginated loan application history with search and status filters.
class LoanHistoryScreen extends ConsumerStatefulWidget {
  const LoanHistoryScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends ConsumerState<LoanHistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  late final InfiniteScrollListener _infiniteScroll;
  late final ({String chamaId, bool mineOnly}) _args;

  @override
  void initState() {
    super.initState();
    _args = (chamaId: widget.chamaId, mineOnly: false);
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () =>
          ref.read(loanHistoryControllerProvider(_args).notifier).loadMore(),
    );
    _infiniteScroll.attach(_scrollController);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref.read(loanHistoryControllerProvider(_args).notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loanHistoryControllerProvider(_args));
    final controller =
        ref.read(loanHistoryControllerProvider(_args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Loan history')),
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
              hint: 'Search applications…',
              onChanged: _onSearchChanged,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: controller.statusFilter == null,
                  onSelected: (_) => controller.setStatusFilter(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                for (final status in [
                  LoanApplicationStatus.pending,
                  LoanApplicationStatus.approved,
                  LoanApplicationStatus.disbursed,
                  LoanApplicationStatus.repaid,
                  LoanApplicationStatus.rejected,
                ]) ...[
                  FilterChip(
                    label: Text(status.label),
                    selected: controller.statusFilter == status,
                    onSelected: (_) => controller.setStatusFilter(status),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ApiStateBuilder<List<LoanApplication>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No loans found',
              emptyMessage: 'Applications will show up here.',
              emptyIcon: Icons.history,
              builder: (context, applications) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount:
                      applications.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= applications.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final app = applications[index];
                    return LoanApplicationTile(
                      application: app,
                      onTap: () => context.push(
                        RoutePaths.loanDetails(widget.chamaId, app.id),
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
