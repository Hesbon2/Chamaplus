import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Lists the authenticated user's Chamas with search and pull-to-refresh.
class MyChamasScreen extends ConsumerStatefulWidget {
  const MyChamasScreen({super.key});

  @override
  ConsumerState<MyChamasScreen> createState() => _MyChamasScreenState();
}

class _MyChamasScreenState extends ConsumerState<MyChamasScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  late final InfiniteScrollListener _infiniteScroll;

  @override
  void initState() {
    super.initState();
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () =>
          ref.read(chamaListControllerProvider.notifier).loadMore(),
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
      ref.read(chamaListControllerProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chamaListControllerProvider);
    final controller = ref.read(chamaListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Chamas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.createChama),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
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
              hint: 'Search chamas…',
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: ApiStateBuilder<List<Chama>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              empty: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyActionCard(
                  title: controller.searchQuery.isEmpty
                      ? 'No chamas yet'
                      : 'No matches',
                  message: controller.searchQuery.isEmpty
                      ? 'Create a chama or join with an invite code to get started.'
                      : 'Try a different search term.',
                  icon: Icons.groups_outlined,
                  actionLabel: 'Create Chama',
                  onAction: () => context.push(RoutePaths.createChama),
                  secondaryActionLabel: 'Join with code',
                  onSecondaryAction: () => context.push(RoutePaths.joinChama),
                ),
              ),
              shimmerItemCount: 4,
              shimmerItemHeight: 96,
              builder: (context, chamas) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: chamas.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= chamas.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final chama = chamas[index];
                    return AppCard(
                      onTap: () => context.push(
                        RoutePaths.chamaDetails(chama.id),
                      ),
                      child: Row(
                        children: [
                          AvatarBadge(
                            initials: chama.name.isNotEmpty
                                ? chama.name[0]
                                : 'C',
                            icon: Icons.savings_outlined,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chama.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                if (chama.location != null &&
                                    chama.location!.isNotEmpty)
                                  Text(
                                    chama.location!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                const SizedBox(height: AppSpacing.xs),
                                StatusChip(
                                  label:
                                      chama.isActive ? 'Active' : 'Archived',
                                  tone: chama.isActive
                                      ? StatusChipTone.success
                                      : StatusChipTone.neutral,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
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
