import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_providers.dart';
import '../utils/meeting_ui_mapper.dart';
import '../widgets/meeting_tiles.dart';

/// Governance overview: upcoming meetings, stats, action items.
class GovernanceDashboardScreen extends ConsumerWidget {
  const GovernanceDashboardScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(governanceDashboardProvider(chamaId));
    final controller =
        ref.read(governanceDashboardProvider(chamaId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Governance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.scheduleMeeting(chamaId)),
        icon: const Icon(Icons.add),
        label: const Text('Schedule'),
      ),
      body: ApiStateBuilder<GovernanceDashboard>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 5,
        builder: (context, dashboard) {
          final totalMeetings = dashboard.scheduledCount +
              dashboard.ongoingCount +
              dashboard.completedCount;
          final completedPct = totalMeetings == 0
              ? 0.0
              : (dashboard.completedCount / totalMeetings) * 100;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (dashboard.nextMeeting != null) ...[
                TimelineCard(
                  title: 'Next meeting',
                  subtitle: dashboard.nextMeeting!.title,
                  steps: MeetingUiMapper.timelineFor(dashboard.nextMeeting!),
                  onTap: () => context.push(
                    RoutePaths.meetingDetails(
                      chamaId,
                      dashboard.nextMeeting!.id,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              ProgressStatCard(
                title: 'Meeting completion',
                subtitle: '${dashboard.completedCount} completed',
                currentValue: '${dashboard.completedCount}',
                targetValue: 'of $totalMeetings meetings',
                percentage: completedPct,
                icon: Icons.event_available,
                progressColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    StatCard(
                      label: 'Scheduled',
                      value: '${dashboard.scheduledCount}',
                      icon: Icons.schedule,
                      onTap: () =>
                          context.push(RoutePaths.meetingsList(chamaId)),
                    ),
                    StatCard(
                      label: 'Ongoing',
                      value: '${dashboard.ongoingCount}',
                      icon: Icons.play_circle_outline,
                      accentColor: AppColors.warning,
                    ),
                    StatCard(
                      label: 'Upcoming',
                      value: '${dashboard.upcomingMeetings.length}',
                      icon: Icons.upcoming_outlined,
                      onTap: () =>
                          context.push(RoutePaths.upcomingMeetings(chamaId)),
                    ),
                  ];
                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm),
                        cards[i],
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Quick actions'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionButton(
                    label: 'All meetings',
                    icon: Icons.list_alt,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.meetingsList(chamaId)),
                  ),
                  ActionButton(
                    label: 'Upcoming',
                    icon: Icons.upcoming_outlined,
                    variant: ActionButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.upcomingMeetings(chamaId)),
                  ),
                  ActionButton(
                    label: 'Schedule',
                    icon: Icons.event_available,
                    expand: false,
                    onPressed: () =>
                        context.push(RoutePaths.scheduleMeeting(chamaId)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Upcoming meetings',
                actionLabel: 'See all',
                onAction: () =>
                    context.push(RoutePaths.upcomingMeetings(chamaId)),
              ),
              if (dashboard.upcomingMeetings.isEmpty)
                const EmptyState(
                  title: 'No upcoming meetings',
                  message: 'Schedule a meeting to get started.',
                  icon: Icons.event_outlined,
                )
              else
                ...dashboard.upcomingMeetings.take(3).map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MeetingListTile(
                          meeting: m,
                          onTap: () => context.push(
                            RoutePaths.meetingDetails(chamaId, m.id),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Open action items'),
              if (dashboard.openActionItems.isEmpty)
                const AppCard(
                  child: Text('No open action items from recent meetings.'),
                )
              else
                ...dashboard.openActionItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ActionItemTile(item: item),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
