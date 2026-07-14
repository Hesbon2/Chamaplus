import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard.dart';
import '../utils/dashboard_formatters.dart';

class RecentActivitiesList extends StatelessWidget {
  const RecentActivitiesList({
    super.key,
    required this.activities,
  });

  final List<RecentActivity> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'No recent activity yet.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: activity.isRead
                ? theme.colorScheme.surfaceVariant
                : theme.colorScheme.primary.withOpacity(0.12),
            child: Icon(
              activity.isRead
                  ? Icons.notifications_none
                  : Icons.notifications_active_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            activity.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight:
                  activity.isRead ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
          subtitle: Text(
            activity.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DashboardFormatters.relativeTime(activity.createdAt),
            style: theme.textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
