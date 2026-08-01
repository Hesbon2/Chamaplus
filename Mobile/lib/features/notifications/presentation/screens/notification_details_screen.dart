import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';
import '../utils/notification_deep_link.dart';
import '../utils/notification_ui_mapper.dart';

/// Single notification detail with mark-read and deep-link CTA.
class NotificationDetailsScreen extends ConsumerWidget {
  const NotificationDetailsScreen({
    super.key,
    required this.notificationId,
  });

  final String notificationId;

  Future<void> _ensureRead(WidgetRef ref, AppNotification notification) async {
    if (notification.isRead) return;
    final ok = await ref
        .read(notificationDetailsControllerProvider(notificationId).notifier)
        .markRead();
    if (ok) {
      ref.read(notificationUnreadCountProvider.notifier).decrement();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(notificationDetailsControllerProvider(notificationId));
    final controller =
        ref.read(notificationDetailsControllerProvider(notificationId).notifier);

    ref.listen<ApiState<AppNotification>>(
      notificationDetailsControllerProvider(notificationId),
      (prev, next) {
        final data = next.data;
        final justLoaded = next.isSuccess &&
            data != null &&
            !data.isRead &&
            (prev == null || !prev.isSuccess || prev.data?.isRead == true);
        if (justLoaded) {
          Future.microtask(() => _ensureRead(ref, data));
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: ApiStateBuilder<AppNotification>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, notification) {
          final deepLink = NotificationDeepLink.resolve(notification);
          final cta = NotificationDeepLink.actionLabel(notification);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              NotificationCard(
                title: notification.title,
                body: notification.message,
                timestamp: NotificationUiMapper.formatFullTimestamp(
                  notification.createdAt,
                ),
                categoryLabel: notification.type.categoryLabel,
                tone: NotificationUiMapper.toneFor(notification.type),
                icon: NotificationUiMapper.iconFor(notification.type),
                isUnread: !notification.isRead,
              ),
              const SizedBox(height: AppSpacing.md),
              TimelineCard(
                title: 'Status',
                steps: NotificationUiMapper.timelineFor(notification),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InfoTile(
                      title: 'Type',
                      subtitle: notification.type.label,
                      dense: true,
                    ),
                    InfoTile(
                      title: 'Channel',
                      subtitle: notification.channel.label,
                      dense: true,
                    ),
                    if (notification.chamaId != null)
                      InfoTile(
                        title: 'Chama',
                        subtitle: notification.chamaId!,
                        dense: true,
                      ),
                    if (notification.meetingId != null)
                      InfoTile(
                        title: 'Meeting',
                        subtitle: notification.meetingId!,
                        dense: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!notification.isRead)
                ActionButton(
                  label: 'Mark as read',
                  icon: Icons.done,
                  isLoading: controller.isMarking,
                  variant: ActionButtonVariant.secondary,
                  onPressed: () async {
                    final ok = await controller.markRead();
                    if (ok) {
                      ref
                          .read(notificationUnreadCountProvider.notifier)
                          .decrement();
                    }
                    if (!context.mounted) return;
                    if (ok) {
                      AppSnackbar.success(context, 'Marked as read');
                    } else {
                      AppSnackbar.error(
                        context,
                        controller.actionError ?? 'Could not update',
                      );
                    }
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
              ActionButton(
                label: cta,
                icon: Icons.open_in_new,
                onPressed: () => context.push(deepLink),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
