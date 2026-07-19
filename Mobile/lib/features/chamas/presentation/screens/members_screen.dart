import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';
import '../utils/chama_ui_mapper.dart';

/// Paginated active members for a Chama.
class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  late final InfiniteScrollListener _infiniteScroll;

  @override
  void initState() {
    super.initState();
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () => ref
          .read(membersControllerProvider(widget.chamaId).notifier)
          .loadMore(),
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
      ref
          .read(membersControllerProvider(widget.chamaId).notifier)
          .search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersControllerProvider(widget.chamaId));
    final controller =
        ref.read(membersControllerProvider(widget.chamaId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by name or phone…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SectionHeader(
              title: 'Active members',
              subtitle: '${controller.totalCount ?? state.data?.length ?? 0} total',
            ),
          ),
          Expanded(
            child: ApiStateBuilder<List<Membership>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No members found',
              emptyMessage: 'Active members will appear here.',
              emptyIcon: Icons.people_outline,
              shimmerItemCount: 6,
              shimmerItemHeight: 72,
              builder: (context, members) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount:
                      members.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= members.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final member = members[index];
                    return AppCard(
                      onTap: () => context.push(
                        RoutePaths.memberDetails(
                          widget.chamaId,
                          member.id,
                        ),
                      ),
                      child: Row(
                        children: [
                          AvatarBadge(initials: member.user.initials),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.user.displayName,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  member.user.phoneNumber,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusChip(
                                label: member.role.name,
                                tone: StatusChipTone.info,
                                compact: true,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              StatusChip(
                                label: member.status.label,
                                tone: ChamaUiMapper.toneForStatus(
                                  member.status,
                                ),
                                compact: true,
                              ),
                            ],
                          ),
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
