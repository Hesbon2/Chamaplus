import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_providers.dart';
import '../widgets/meeting_tiles.dart';

/// Searchable / filterable meetings list.
class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({
    super.key,
    required this.chamaId,
    this.upcomingOnly = false,
  });

  final String chamaId;
  final bool upcomingOnly;

  @override
  ConsumerState<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends ConsumerState<MeetingsListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  late final ({String chamaId, bool upcomingOnly}) _args;

  @override
  void initState() {
    super.initState();
    _args = (chamaId: widget.chamaId, upcomingOnly: widget.upcomingOnly);
  }

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
      ref.read(meetingsListControllerProvider(_args).notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetingsListControllerProvider(_args));
    final controller =
        ref.read(meetingsListControllerProvider(_args).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.upcomingOnly ? 'Upcoming meetings' : 'Meetings'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(RoutePaths.scheduleMeeting(widget.chamaId)),
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
              hint: 'Search meetings…',
              onChanged: _onSearchChanged,
            ),
          ),
          if (!widget.upcomingOnly)
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
                    MeetingStatus.scheduled,
                    MeetingStatus.ongoing,
                    MeetingStatus.completed,
                    MeetingStatus.cancelled,
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
            child: ApiStateBuilder<List<Meeting>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No meetings found',
              emptyMessage: widget.upcomingOnly
                  ? 'Nothing upcoming. Schedule a meeting.'
                  : 'Schedule your first meeting.',
              emptyIcon: Icons.event_outlined,
              builder: (context, meetings) {
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: meetings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    return MeetingListTile(
                      meeting: meeting,
                      onTap: () => context.push(
                        RoutePaths.meetingDetails(
                          widget.chamaId,
                          meeting.id,
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
