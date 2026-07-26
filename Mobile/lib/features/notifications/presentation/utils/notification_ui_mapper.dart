import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/components.dart';
import '../../domain/entities/notification.dart';

/// Maps notification domain values to design-system presentation.
class NotificationUiMapper {
  NotificationUiMapper._();

  static NotificationCardTone toneFor(NotificationType type) {
    switch (type) {
      case NotificationType.loanApproved:
      case NotificationType.contributionRecorded:
      case NotificationType.repaymentRecorded:
        return NotificationCardTone.success;
      case NotificationType.loanRejected:
        return NotificationCardTone.error;
      case NotificationType.loanApplied:
      case NotificationType.committeeVoteCompleted:
        return NotificationCardTone.warning;
      case NotificationType.attendanceFinalized:
        return NotificationCardTone.info;
      case NotificationType.unknown:
        return NotificationCardTone.neutral;
    }
  }

  static IconData iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.loanApplied:
      case NotificationType.loanApproved:
      case NotificationType.loanRejected:
      case NotificationType.repaymentRecorded:
      case NotificationType.committeeVoteCompleted:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.contributionRecorded:
        return Icons.payments_outlined;
      case NotificationType.attendanceFinalized:
        return Icons.event_outlined;
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  static String formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat.MMMd().format(local);
  }

  static String formatFullTimestamp(DateTime value) {
    return DateFormat.yMMMd().add_jm().format(value.toLocal());
  }

  static List<TimelineStep> timelineFor(AppNotification notification) {
    return [
      TimelineStep(
        title: 'Received',
        subtitle: notification.channel.label,
        timestamp: formatFullTimestamp(notification.createdAt),
        isCompleted: true,
        isActive: !notification.isRead,
        icon: Icons.inbox_outlined,
      ),
      TimelineStep(
        title: notification.isRead ? 'Read' : 'Unread',
        subtitle: notification.readAt == null
            ? null
            : formatFullTimestamp(notification.readAt!),
        isCompleted: notification.isRead,
        isActive: notification.isRead,
        icon: notification.isRead
            ? Icons.mark_email_read_outlined
            : Icons.mark_email_unread_outlined,
      ),
      TimelineStep(
        title: 'Related',
        subtitle: notification.type.categoryLabel,
        isCompleted: true,
        icon: iconFor(notification.type),
      ),
    ];
  }
}
