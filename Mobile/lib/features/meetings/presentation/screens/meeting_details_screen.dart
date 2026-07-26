import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_providers.dart';
import '../utils/meeting_ui_mapper.dart';
import '../widgets/meeting_tiles.dart';

/// Meeting detail with timeline, actions, and shortcuts.
class MeetingDetailsScreen extends ConsumerWidget {
  const MeetingDetailsScreen({
    super.key,
    required this.chamaId,
    required this.meetingId,
  });

  final String chamaId;
  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, meetingId: meetingId);
    final state = ref.watch(meetingDetailsControllerProvider(args));
    final controller =
        ref.read(meetingDetailsControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Meeting details')),
      body: ApiStateBuilder<Meeting>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, meeting) {
          final recorded = controller.attendance.where((a) => a.isRecorded).length;
          final total = controller.attendance.length;
          final attendancePct =
              total == 0 ? 0.0 : (recorded / total) * 100;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meeting.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: StatusChip(
                            key: ValueKey(meeting.status),
                            label: meeting.status.label,
                            tone: MeetingUiMapper.toneForStatus(meeting.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${MeetingFormatters.date(meeting.meetingDate)} · '
                      '${MeetingFormatters.timeRange(meeting.startTime, meeting.endTime)}',
                    ),
                    Text('${meeting.venue} · ${meeting.meetingType.label}'),
                    if (meeting.description != null &&
                        meeting.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(meeting.description!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TimelineCard(
                title: 'Meeting timeline',
                steps: MeetingUiMapper.timelineFor(meeting),
              ),
              const SizedBox(height: AppSpacing.md),
              ProgressStatCard(
                title: 'Attendance recorded',
                currentValue: '$recorded',
                targetValue: 'of $total members',
                percentage: attendancePct,
                icon: Icons.how_to_reg_outlined,
                onTap: () => context.push(
                  RoutePaths.meetingAttendance(chamaId, meetingId),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Actions'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionButton(
                    label: 'Attendance',
                    icon: Icons.how_to_reg_outlined,
                    expand: false,
                    variant: ActionButtonVariant.secondary,
                    onPressed: () => context.push(
                      RoutePaths.meetingAttendance(chamaId, meetingId),
                    ),
                  ),
                  ActionButton(
                    label: 'Minutes',
                    icon: Icons.description_outlined,
                    expand: false,
                    variant: ActionButtonVariant.secondary,
                    onPressed: () => context.push(
                      RoutePaths.meetingMinutes(chamaId, meetingId),
                    ),
                  ),
                  ActionButton(
                    label: 'Action items',
                    icon: Icons.checklist_outlined,
                    expand: false,
                    variant: ActionButtonVariant.secondary,
                    onPressed: () => context.push(
                      RoutePaths.meetingActionItems(chamaId, meetingId),
                    ),
                  ),
                  if (meeting.status == MeetingStatus.scheduled)
                    ActionButton(
                      label: 'Start',
                      icon: Icons.play_arrow,
                      expand: false,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final ok = await controller.start();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Meeting started.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                  if (meeting.status.isOpen)
                    ActionButton(
                      label: 'Close',
                      icon: Icons.stop_circle_outlined,
                      expand: false,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final confirmed = await showAppConfirmationDialog(
                          context: context,
                          title: 'Close meeting?',
                          message:
                              'All attendance must be recorded. This finalizes the meeting.',
                          confirmLabel: 'Close meeting',
                        );
                        if (!confirmed) return;
                        final ok = await controller.close();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Meeting closed.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                  if (meeting.status.isOpen)
                    ActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      expand: false,
                      variant: ActionButtonVariant.secondary,
                      isDestructive: true,
                      isLoading: controller.isActing,
                      onPressed: () async {
                        final confirmed = await showAppConfirmationDialog(
                          context: context,
                          title: 'Cancel meeting?',
                          message: 'The meeting will be marked cancelled.',
                          confirmLabel: 'Cancel meeting',
                          isDestructive: true,
                        );
                        if (!confirmed) return;
                        final ok = await controller.cancel();
                        if (!context.mounted) return;
                        if (ok) {
                          AppSnackbar.success(context, 'Meeting cancelled.');
                        } else if (controller.actionError != null) {
                          AppSnackbar.error(context, controller.actionError!);
                        }
                      },
                    ),
                ],
              ),
              if (controller.minutes != null &&
                  controller.minutes!.actionItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Action items'),
                ...controller.minutes!.actionItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ActionItemTile(item: item),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
