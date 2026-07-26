import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'status_chip.dart';

/// Visual tone for a [NotificationCard] leading indicator.
enum NotificationCardTone {
  /// Neutral / read inbox item.
  neutral,

  /// Unread or informational.
  info,

  /// Positive outcome.
  success,

  /// Caution / pending.
  warning,

  /// Negative outcome.
  error,
}

/// Generic inbox / alert / announcement card.
///
/// Reusable for notifications, announcements, and future alert channels.
/// Contains no feature-specific business logic — pass display data only.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    this.timestamp,
    this.categoryLabel,
    this.icon,
    this.tone = NotificationCardTone.neutral,
    this.isUnread = false,
    this.onTap,
    this.trailing,
    this.compact = false,
  });

  /// Primary headline.
  final String title;

  /// Supporting message / preview.
  final String body;

  /// Optional relative or absolute time label.
  final String? timestamp;

  /// Optional category chip (e.g. "Loan", "Meeting").
  final String? categoryLabel;

  /// Leading icon; defaults from [tone].
  final IconData? icon;

  /// Accent tone for the leading avatar.
  final NotificationCardTone tone;

  /// When true, emphasizes title and shows an unread dot.
  final bool isUnread;

  final VoidCallback? onTap;

  /// Optional trailing widget (e.g. chevron override).
  final Widget? trailing;

  /// Tighter padding for dense lists.
  final bool compact;

  Color _toneColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (tone) {
      case NotificationCardTone.info:
        return scheme.primary;
      case NotificationCardTone.success:
        return scheme.tertiary;
      case NotificationCardTone.warning:
        return scheme.secondary;
      case NotificationCardTone.error:
        return scheme.error;
      case NotificationCardTone.neutral:
        return scheme.onSurfaceVariant;
    }
  }

  IconData get _resolvedIcon {
    if (icon != null) return icon!;
    switch (tone) {
      case NotificationCardTone.success:
        return Icons.check_circle_outline;
      case NotificationCardTone.warning:
        return Icons.schedule_outlined;
      case NotificationCardTone.error:
        return Icons.error_outline;
      case NotificationCardTone.info:
        return Icons.notifications_outlined;
      case NotificationCardTone.neutral:
        return Icons.mail_outline;
    }
  }

  StatusChipTone get _chipTone {
    switch (tone) {
      case NotificationCardTone.info:
        return StatusChipTone.info;
      case NotificationCardTone.success:
        return StatusChipTone.success;
      case NotificationCardTone.warning:
        return StatusChipTone.warning;
      case NotificationCardTone.error:
        return StatusChipTone.error;
      case NotificationCardTone.neutral:
        return StatusChipTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _toneColor(context);
    final pad = compact ? AppSpacing.sm : AppSpacing.md;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(pad),
      color: isUnread
          ? theme.colorScheme.primaryContainer.withOpacity(0.28)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: compact ? 18 : 22,
                backgroundColor: accent.withOpacity(0.14),
                foregroundColor: accent,
                child: Icon(_resolvedIcon, size: compact ? 18 : 22),
              ),
              if (isUnread)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        timestamp!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (categoryLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  StatusChip(
                    label: categoryLabel!,
                    tone: _chipTone,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
