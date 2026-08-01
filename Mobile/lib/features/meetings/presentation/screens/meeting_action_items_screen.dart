import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';
import '../controllers/meeting_controllers.dart';
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
          ? const ShimmerLoader(itemCount: 4)
          : state.errorMessage != null && state.minutes == null
              ? EmptyState(
                  title: 'Could not load action items',
                  message: state.errorMessage!,
                  icon: Icons.error_outline,
                  actionLabel: 'Retry',
                  onAction: controller.load,
                )
              : RefreshIndicator(
                  onRefresh: controller.load,
                  child: _ActionItemsBody(
                    state: state,
                    chamaId: chamaId,
                    meetingId: meetingId,
                  ),
                ),
    );
  }
}

class _ActionItemsBody extends StatelessWidget {
  const _ActionItemsBody({
    required this.state,
    required this.chamaId,
    required this.meetingId,
  });

  final MeetingMinutesState state;
  final String chamaId;
  final String meetingId;

  @override
  Widget build(BuildContext context) {
    final items = state.minutes?.actionItems ?? const <MeetingActionItem>[];

    return ListView(
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
              isCompleted: items.isNotEmpty,
              isActive: state.exists,
            ),
            TimelineStep(
              title: 'Approve minutes',
              isCompleted: state.minutes?.approved ?? false,
              isActive: state.exists && !(state.minutes?.approved ?? false),
              timestamp: state.minutes?.approvedAt == null
                  ? null
                  : MeetingFormatters.shortDate(state.minutes!.approvedAt!),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          EmptyActionCard(
            title: 'No action items',
            message:
                'Add action items when writing or editing meeting minutes.',
            icon: Icons.checklist_outlined,
            actionLabel: 'Open minutes',
            onAction: () =>
                context.push(RoutePaths.meetingMinutes(chamaId, meetingId)),
          )
        else ...[
          ProgressStatCard(
            title: 'Completion',
            currentValue: '${items.where((a) => a.isDone).length}',
            targetValue: 'of ${items.length} done',
            percentage: items.isEmpty
                ? 0
                : (items.where((a) => a.isDone).length / items.length) * 100,
            icon: Icons.task_alt,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ActionItemTile(item: item),
            ),
        ],
      ],
    );
  }
}
