import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';
import '../widgets/contribution_tiles.dart';

/// Lists contribution cycles with search, status filter, and create action.
class CyclesScreen extends ConsumerStatefulWidget {
  const CyclesScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<CyclesScreen> createState() => _CyclesScreenState();
}

class _CyclesScreenState extends ConsumerState<CyclesScreen> {
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
      ref.read(cyclesControllerProvider(widget.chamaId).notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cyclesControllerProvider(widget.chamaId));
    final controller =
        ref.read(cyclesControllerProvider(widget.chamaId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribution cycles'),
        actions: [
          IconButton(
            tooltip: 'Create cycle',
            onPressed: () => context.push(
              RoutePaths.createContributionCycle(widget.chamaId),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          RoutePaths.createContributionCycle(widget.chamaId),
        ),
        child: const Icon(Icons.add),
      ),
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
              hint: 'Search cycles…',
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
                FilterChip(
                  label: const Text('Open'),
                  selected: controller.statusFilter == CycleStatus.open,
                  onSelected: (_) =>
                      controller.setStatusFilter(CycleStatus.open),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('Closed'),
                  selected: controller.statusFilter == CycleStatus.closed,
                  onSelected: (_) =>
                      controller.setStatusFilter(CycleStatus.closed),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ApiStateBuilder<List<ContributionCycle>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No cycles found',
              emptyMessage: 'Create a contribution cycle to get started.',
              emptyIcon: Icons.event_repeat_outlined,
              builder: (context, cycles) {
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: cycles.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final cycle = cycles[index];
                    return CycleListTile(
                      cycle: cycle,
                      onTap: () => context.push(
                        RoutePaths.cycleDetails(widget.chamaId, cycle.id),
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
