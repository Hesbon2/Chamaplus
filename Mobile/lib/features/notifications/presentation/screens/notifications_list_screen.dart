import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';
import '../utils/notification_ui_mapper.dart';

/// Paginated notifications inbox with unread filter.
class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({
    super.key,
    this.unreadOnly = false,
  });

  final bool unreadOnly;

  @override
  ConsumerState<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState
    extends ConsumerState<NotificationsListScreen> {
  final _scrollController = ScrollController();
  late final InfiniteScrollListener _infiniteScroll;
  late bool _unreadOnly;

  @override
  void initState() {
    super.initState();
    _unreadOnly = widget.unreadOnly;
    _infiniteScroll = InfiniteScrollListener(
      onLoadMore: () => ref
          .read(notificationsListControllerProvider(_unreadOnly).notifier)
          .loadMore(),
    );
    _infiniteScroll.attach(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAll() async {
    final ok = await ref
        .read(notificationsListControllerProvider(_unreadOnly).notifier)
        .markAllRead();
    ref.read(notificationUnreadCountProvider.notifier).setCount(0);
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'All notifications marked as read');
      await ref.read(notificationsDashboardProvider.notifier).refresh();
    } else {
      AppSnackbar.error(context, 'Could not mark all as read');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsListControllerProvider(_unreadOnly));
    final controller =
        ref.read(notificationsListControllerProvider(_unreadOnly).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_unreadOnly ? 'Unread' : 'Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            onPressed: _markAll,
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('All')),
                ButtonSegment(value: true, label: Text('Unread')),
              ],
              selected: {_unreadOnly},
              onSelectionChanged: (values) {
                setState(() => _unreadOnly = values.first);
              },
            ),
          ),
          Expanded(
            child: ApiStateBuilder<List<AppNotification>>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: _unreadOnly ? 'No unread alerts' : 'No notifications',
              emptyMessage: _unreadOnly
                  ? 'You are all caught up.'
                  : 'Alerts from your chamas will show up here.',
              emptyIcon: Icons.notifications_none_outlined,
              builder: (context, items) {
                return ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = items[index];
                    return NotificationCard(
                      title: item.title,
                      body: item.message,
                      timestamp: NotificationUiMapper.formatTimestamp(
                        item.createdAt,
                      ),
                      categoryLabel: item.type.categoryLabel,
                      tone: NotificationUiMapper.toneFor(item.type),
                      icon: NotificationUiMapper.iconFor(item.type),
                      isUnread: !item.isRead,
                      onTap: () => context.push(
                        RoutePaths.alertDetails(item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
