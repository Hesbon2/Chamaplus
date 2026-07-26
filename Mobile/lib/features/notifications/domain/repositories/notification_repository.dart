import '../entities/notification.dart';

/// Contract for the notifications inbox.
abstract class NotificationRepository {
  Future<PagedResult<AppNotification>> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  });

  Future<AppNotification> getNotification(String notificationId);

  Future<AppNotification> markRead(String notificationId);

  Future<int> markAllRead();

  Future<int> countUnread();

  Future<NotificationsDashboard> getDashboard();
}
