import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/meeting.dart';
import '../utils/meeting_ui_mapper.dart';

/// List tile for a meeting row.
class MeetingListTile extends StatelessWidget {
  const MeetingListTile({
    super.key,
    required this.meeting,
    this.onTap,
  });

  final Meeting meeting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarBadge(
            initials: meeting.title.isNotEmpty ? meeting.title[0] : 'M',
            icon: Icons.event_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title, style: theme.textTheme.titleSmall),
                Text(
                  '${MeetingFormatters.shortDate(meeting.meetingDate)} · '
                  '${MeetingFormatters.timeRange(meeting.startTime, meeting.endTime)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${meeting.venue} · ${meeting.meetingType.label}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            label: meeting.status.label,
            tone: MeetingUiMapper.toneForStatus(meeting.status),
            compact: true,
          ),
        ],
      ),
    );
  }
}

/// List tile for an action item.
class ActionItemTile extends StatelessWidget {
  const ActionItemTile({
    super.key,
    required this.item,
  });

  final MeetingActionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Icon(
            item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.isDone
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.task,
                  style: theme.textTheme.titleSmall?.copyWith(
                    decoration:
                        item.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.owner != null)
                  Text('Owner: ${item.owner}', style: theme.textTheme.bodySmall),
                if (item.dueDate != null)
                  Text('Due: ${item.dueDate}', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
