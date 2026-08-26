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
import '../utils/chama_ui_mapper.dart';

/// Paginated members for a Chama with status filter and financial details.
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

  static const _filters = <(MembershipStatus?, String)>[
    (null, 'All'),
    (MembershipStatus.active, 'Active'),
    (MembershipStatus.pending, 'Pending'),
    (MembershipStatus.suspended, 'Suspended'),
    (MembershipStatus.left, 'Left'),
  ];

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
    final filterLabel = _filters
        .firstWhere(
          (f) => f.$1 == controller.statusFilter,
          orElse: () => (null, 'All'),
        )
        .$2;

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search by name or phone…',
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final option in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(option.$2),
                        selected: controller.statusFilter == option.$1,
                        onSelected: (_) =>
                            controller.setStatusFilter(option.$1),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: SectionHeader(
              title: '$filterLabel members',
              subtitle:
                  '${controller.totalCount ?? state.data?.length ?? 0} total',
            ),
          ),
          Expanded(
            child: ApiStateBuilder<List<Membership>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No members found',
              emptyMessage: 'Members matching this filter will appear here.',
              emptyIcon: Icons.people_outline,
              shimmerItemCount: 6,
              shimmerItemHeight: 88,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  'Contributed KES ${member.contributionsTotal}'
                                  ' · ${member.activeLoansCount} active loan(s)',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
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
