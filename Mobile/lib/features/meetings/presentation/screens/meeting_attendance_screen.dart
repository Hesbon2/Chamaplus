import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_providers.dart';
import '../utils/meeting_ui_mapper.dart';

/// Record / update attendance for a meeting roster.
class MeetingAttendanceScreen extends ConsumerWidget {
  const MeetingAttendanceScreen({
    super.key,
    required this.chamaId,
    required this.meetingId,
  });

  final String chamaId;
  final String meetingId;

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    AttendanceRecord record,
    AttendanceStatus status,
  ) async {
    final args = (chamaId: chamaId, meetingId: meetingId);
    final controller = ref.read(attendanceControllerProvider(args).notifier);
    final ok = await controller.saveRecord(
      RecordAttendanceInput(
        memberId: record.memberId,
        status: status,
        remarks: record.remarks,
      ),
      attendanceId: record.attendanceId,
    );
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.success(context, '${record.memberName}: ${status.label}');
    } else if (controller.actionError != null) {
      AppSnackbar.error(
        context,
        controller.actionError!.replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, meetingId: meetingId);
    final state = ref.watch(attendanceControllerProvider(args));
    final controller = ref.read(attendanceControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: ApiStateBuilder<List<AttendanceRecord>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        emptyTitle: 'No members',
        emptyMessage: 'Active members will appear here for roll call.',
        emptyIcon: Icons.how_to_reg_outlined,
        builder: (context, records) {
          final recorded = records.where((r) => r.isRecorded).length;
          final present = records
              .where((r) =>
                  r.status == AttendanceStatus.present ||
                  r.status == AttendanceStatus.late)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ProgressStatCard(
                  title: 'Roll call progress',
                  subtitle: '$present present / late',
                  currentValue: '$recorded',
                  targetValue: 'of ${records.length} recorded',
                  percentage: records.isEmpty
                      ? 0
                      : (recorded / records.length) * 100,
                  icon: Icons.fact_check_outlined,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: records.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              AvatarBadge(
                                initials: record.memberName.isNotEmpty
                                    ? record.memberName[0]
                                    : 'M',
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  record.memberName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              StatusChip(
                                label: record.status?.label ?? 'Pending',
                                tone: MeetingUiMapper.toneForAttendance(
                                  record.status,
                                ),
                                compact: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: [
                              for (final status in [
                                AttendanceStatus.present,
                                AttendanceStatus.late,
                                AttendanceStatus.absent,
                                AttendanceStatus.excused,
                              ])
                                ChoiceChip(
                                  label: Text(status.label),
                                  selected: record.status == status,
                                  onSelected: controller.isSaving
                                      ? null
                                      : (_) => _setStatus(
                                            context,
                                            ref,
                                            record,
                                            status,
                                          ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
