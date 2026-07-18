import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';
import '../widgets/contribution_tiles.dart';

/// Paginated contribution history with search and cycle filtering.
class ContributionHistoryScreen extends ConsumerStatefulWidget {
  const ContributionHistoryScreen({
    super.key,
    required this.chamaId,
    this.cycleId,
    this.memberId,
  });

  final String chamaId;
  final String? cycleId;
  final String? memberId;

  @override
  ConsumerState<ContributionHistoryScreen> createState() =>
      _ContributionHistoryScreenState();
}

class _ContributionHistoryScreenState
    extends ConsumerState<ContributionHistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  late final InfiniteScrollListener _infiniteScroll;
  late final ({String chamaId, String? cycleId, String? memberId}) _args;

  @override
  void initState() {
    super.initState();
    _args = (
      chamaId: widget.chamaId,
      cycleId: widget.cycleId,
      memberId: widget.memberId,
    );
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () =>
          ref.read(contributionHistoryControllerProvider(_args).notifier).loadMore(),
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
      ref
          .read(contributionHistoryControllerProvider(_args).notifier)
          .search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contributionHistoryControllerProvider(_args));
    final controller =
        ref.read(contributionHistoryControllerProvider(_args).notifier);
    final cyclesAsync = ref.watch(openCyclesProvider(widget.chamaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Contribution history')),
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
              hint: 'Search reference or member…',
              onChanged: _onSearchChanged,
            ),
          ),
          cyclesAsync.when(
            data: (cycles) {
              if (cycles.isEmpty && widget.cycleId == null) {
                return const SizedBox.shrink();
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All cycles'),
                      selected: controller.cycleFilter == null,
                      onSelected: (_) => controller.setCycleFilter(null),
                    ),
                    ...cycles.map(
                      (cycle) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(cycle.name),
                          selected: controller.cycleFilter == cycle.id,
                          onSelected: (_) =>
                              controller.setCycleFilter(cycle.id),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SectionHeader(
              title: 'Payments',
              subtitle: '${controller.totalCount ?? state.data?.length ?? 0} total',
            ),
          ),
          Expanded(
            child: ApiStateBuilder<List<Contribution>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No contributions',
              emptyMessage: 'Recorded payments will appear here.',
              emptyIcon: Icons.receipt_long_outlined,
              builder: (context, items) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = items[index];
                    return ContributionListTile(
                      contribution: item,
                      onTap: () => context.push(
                        RoutePaths.contributionDetails(
                          widget.chamaId,
                          item.id,
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
