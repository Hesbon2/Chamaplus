import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_api.dart';

/// Concrete [NotificationRepository] backed by [NotificationRemoteDataSource].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);

  final NotificationRemoteDataSource _api;

  @override
  Future<PagedResult<AppNotification>> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await _api.listNotifications(
      isRead: isRead,
      page: page,
      pageSize: pageSize,
    );
    final items = dto.results.map((e) => e.toEntity()).toList();
    final hasMore = dto.next != null && dto.next!.isNotEmpty;
    return PagedResult(
      items: items,
      count: dto.count,
      nextPage: hasMore ? page + 1 : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<AppNotification> getNotification(String notificationId) async {
    final dto = await _api.getNotification(notificationId);
    return dto.toEntity();
  }

  @override
  Future<AppNotification> markRead(String notificationId) async {
    final dto = await _api.markRead(notificationId);
    return dto.toEntity();
  }

  @override
  Future<int> markAllRead() => _api.markAllRead();

  @override
  Future<int> countUnread() async {
    final page = await listNotifications(isRead: false, page: 1, pageSize: 1);
    return page.count;
  }

  @override
  Future<NotificationsDashboard> getDashboard() async {
    final unreadPage =
        await listNotifications(isRead: false, page: 1, pageSize: 1);
    final recentPage = await listNotifications(page: 1, pageSize: 8);
    return NotificationsDashboard(
      unreadCount: unreadPage.count,
      totalCount: recentPage.count,
      recent: recentPage.items,
    );
  }
}
