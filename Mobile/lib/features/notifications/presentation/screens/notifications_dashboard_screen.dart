import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';
import '../utils/notification_ui_mapper.dart';

/// Alerts tab hub: unread stats, recent inbox, mark-all-read.
class NotificationsDashboardScreen extends ConsumerWidget {
  const NotificationsDashboardScreen({super.key});

  Future<void> _markAll(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(notificationsDashboardProvider.notifier)
        .markAllRead();
    ref.read(notificationUnreadCountProvider.notifier).setCount(0);
    // Keep home dashboard unread badge/stats in sync when possible.
    try {
      await ref.read(dashboardProvider.notifier).refresh();
    } catch (_) {}
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'All notifications marked as read');
    } else {
      final err =
          ref.read(notificationsDashboardProvider.notifier).actionError;
      AppSnackbar.error(context, err ?? 'Could not mark all as read');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsDashboardProvider);
    final controller = ref.read(notificationsDashboardProvider.notifier);

    // Keep shell badge in sync when dashboard loads.
    ref.listen<ApiState<NotificationsDashboard>>(
      notificationsDashboardProvider,
      (prev, next) {
        final data = next.data;
        if (data != null) {
          ref
              .read(notificationUnreadCountProvider.notifier)
              .setCount(data.unreadCount);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: controller.isMarkingAll
                ? null
                : () => _markAll(context, ref),
            child: controller.isMarkingAll
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Mark all read'),
          ),
        ],
      ),
      body: ApiStateBuilder<NotificationsDashboard>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 4,
        emptyTitle: 'No alerts yet',
        emptyMessage:
            'Notifications from loans, contributions, and meetings will appear here.',
        emptyIcon: Icons.notifications_none_outlined,
        builder: (context, dashboard) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    ProgressStatCard(
                      title: 'Inbox progress',
                      subtitle: '${dashboard.unreadCount} unread',
                      currentValue: '${dashboard.totalCount - dashboard.unreadCount}',
                      targetValue: 'of ${dashboard.totalCount} read',
                      percentage: dashboard.readPercentage,
                      icon: Icons.mark_email_read_outlined,
                    ),
                    StatCard(
                      label: 'Unread',
                      value: '${dashboard.unreadCount}',
                      icon: Icons.mark_email_unread_outlined,
                      onTap: () => context.push(
                        '${RoutePaths.alertsList}?unread=1',
                      ),
                    ),
                  ];
                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: AppSpacing.sm),
                      cards[1],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ActionButton(
                label: 'View all notifications',
                icon: Icons.list_alt,
                variant: ActionButtonVariant.secondary,
                onPressed: () => context.push(RoutePaths.alertsList),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent',
                actionLabel: 'See all',
                onAction: () => context.push(RoutePaths.alertsList),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (dashboard.recent.isEmpty)
                const EmptyState(
                  title: 'Inbox is empty',
                  message: 'You are all caught up.',
                  icon: Icons.notifications_none_outlined,
                )
              else
                ...dashboard.recent.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: NotificationCard(
                      title: item.title,
                      body: item.message,
                      timestamp:
                          NotificationUiMapper.formatTimestamp(item.createdAt),
                      categoryLabel: item.type.categoryLabel,
                      tone: NotificationUiMapper.toneFor(item.type),
                      icon: NotificationUiMapper.iconFor(item.type),
                      isUnread: !item.isRead,
                      compact: true,
                      onTap: () => context.push(
                        RoutePaths.alertDetails(item.id),
                      ),
                    ),
                  ),
                ),
              if (dashboard.recent.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                TimelineCard(
                  title: 'Activity pulse',
                  subtitle: 'Latest inbox lifecycle',
                  steps: NotificationUiMapper.timelineFor(dashboard.recent.first),
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
