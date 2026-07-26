import 'package:chamaplus_mobile/features/notifications/data/datasources/notification_api.dart';
import 'package:chamaplus_mobile/features/notifications/data/dtos/notification_dtos.dart';
import 'package:chamaplus_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:chamaplus_mobile/features/notifications/domain/entities/notification.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotificationApi implements NotificationRemoteDataSource {
  List<NotificationItemDto> items = [];
  int markAllCount = 0;
  Object? error;

  @override
  Future<NotificationItemDto> getNotification(String notificationId) async {
    return items.firstWhere((e) => e.id == notificationId);
  }

  @override
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (error != null) throw error!;
    var list = items;
    if (isRead != null) {
      list = list.where((e) => e.isRead == isRead).toList();
    }
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    final slice =
        start >= list.length ? <NotificationItemDto>[] : list.sublist(start, end);
    final hasMore = end < list.length;
    return NotificationsPageDto(
      count: list.length,
      results: slice,
      next: hasMore ? 'page=${page + 1}' : null,
    );
  }

  @override
  Future<int> markAllRead() async {
    markAllCount = items.where((e) => !e.isRead).length;
    items = items
        .map(
          (e) => NotificationItemDto(
            id: e.id,
            title: e.title,
            message: e.message,
            notificationType: e.notificationType,
            channel: e.channel,
            isRead: true,
            readAt: e.readAt ?? '2026-07-26T10:00:00Z',
            metadata: e.metadata,
            createdAt: e.createdAt,
          ),
        )
        .toList();
    return markAllCount;
  }

  @override
  Future<NotificationItemDto> markRead(String notificationId) async {
    final index = items.indexWhere((e) => e.id == notificationId);
    final current = items[index];
    final updated = NotificationItemDto(
      id: current.id,
      title: current.title,
      message: current.message,
      notificationType: current.notificationType,
      channel: current.channel,
      isRead: true,
      readAt: '2026-07-26T10:00:00Z',
      metadata: current.metadata,
      createdAt: current.createdAt,
    );
    items[index] = updated;
    return updated;
  }
}

void main() {
  late FakeNotificationApi api;
  late NotificationRepositoryImpl repository;

  setUp(() {
    api = FakeNotificationApi();
    repository = NotificationRepositoryImpl(api);
    api.items = [
      const NotificationItemDto(
        id: 'n1',
        title: 'Loan approved',
        message: 'Your loan was approved',
        notificationType: 'loan_approved',
        channel: 'in_app',
        isRead: false,
        metadata: {'chama_id': 'c1', 'loan_id': 'a1'},
        createdAt: '2026-07-26T08:00:00Z',
      ),
      const NotificationItemDto(
        id: 'n2',
        title: 'Contribution recorded',
        message: 'Payment received',
        notificationType: 'contribution_recorded',
        channel: 'in_app',
        isRead: true,
        metadata: {'chama_id': 'c1'},
        createdAt: '2026-07-25T08:00:00Z',
      ),
    ];
  });

  test('listNotifications maps DTOs and filters unread', () async {
    final page = await repository.listNotifications(isRead: false);
    expect(page.count, 1);
    expect(page.items.first.type, NotificationType.loanApproved);
    expect(page.items.first.chamaId, 'c1');
    expect(page.items.first.loanApplicationId, 'a1');
  });

  test('markRead updates entity', () async {
    final updated = await repository.markRead('n1');
    expect(updated.isRead, isTrue);
    expect(updated.readAt, isNotNull);
  });

  test('markAllRead returns updated count', () async {
    final count = await repository.markAllRead();
    expect(count, 1);
    expect(await repository.countUnread(), 0);
  });

  test('getDashboard aggregates unread and recent', () async {
    final dashboard = await repository.getDashboard();
    expect(dashboard.unreadCount, 1);
    expect(dashboard.totalCount, 2);
    expect(dashboard.recent, hasLength(2));
  });
}
