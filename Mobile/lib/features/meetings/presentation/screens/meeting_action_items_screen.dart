import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../providers/meeting_providers.dart';
import '../utils/meeting_ui_mapper.dart';
import '../widgets/meeting_tiles.dart';

/// Action items extracted from meeting minutes.
class MeetingActionItemsScreen extends ConsumerWidget {
  const MeetingActionItemsScreen({
    super.key,
    required this.chamaId,
    required this.meetingId,
  });

  final String chamaId;
  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, meetingId: meetingId);
    final state = ref.watch(meetingMinutesControllerProvider(args));
    final controller =
        ref.read(meetingMinutesControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action items'),
        actions: [
          IconButton(
            tooltip: 'Edit minutes',
            onPressed: () =>
                context.push(RoutePaths.meetingMinutes(chamaId, meetingId)),
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  TimelineCard(
                    title: 'Follow-up',
                    subtitle: state.minutes == null
                        ? 'No minutes yet'
                        : (state.minutes!.approved
                            ? 'Minutes approved'
                            : 'Minutes draft'),
                    steps: [
                      TimelineStep(
                        title: 'Capture minutes',
                        isCompleted: state.exists,
                        isActive: !state.exists,
                      ),
                      TimelineStep(
                        title: 'Track action items',
                        isCompleted: (state.minutes?.actionItems.isNotEmpty ??
                            false),
                        isActive: state.exists,
                      ),
                      TimelineStep(
                        title: 'Approve minutes',
                        isCompleted: state.minutes?.approved ?? false,
                        isActive: state.exists &&
                            !(state.minutes?.approved ?? false),
                        timestamp: state.minutes?.approvedAt == null
                            ? null
                            : MeetingFormatters.shortDate(
                                state.minutes!.approvedAt!,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.minutes == null ||
                      state.minutes!.actionItems.isEmpty)
                    EmptyActionCard(
                      title: 'No action items',
                      message:
                          'Add action items when writing or editing meeting minutes.',
                      icon: Icons.checklist_outlined,
                      actionLabel: 'Open minutes',
                      onAction: () => context.push(
                        RoutePaths.meetingMinutes(chamaId, meetingId),
                      ),
                    )
                  else ...[
                    ProgressStatCard(
                      title: 'Completion',
                      currentValue:
                          '${state.minutes!.actionItems.where((a) => a.isDone).length}',
                      targetValue:
                          'of ${state.minutes!.actionItems.length} done',
                      percentage: state.minutes!.actionItems.isEmpty
                          ? 0
                          : (state.minutes!.actionItems
                                      .where((a) => a.isDone)
                                      .length /
                                  state.minutes!.actionItems.length) *
                              100,
                      icon: Icons.task_alt,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...state.minutes!.actionItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ActionItemTile(item: item),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
