import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/features/notifications/domain/entities/notification.dart';
import 'package:chamaplus_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/controllers/notification_controllers.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/utils/notification_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotificationRepository implements NotificationRepository {
  List<AppNotification> items = [];
  Object? error;
  int markAllCalls = 0;

  @override
  Future<int> countUnread() async =>
      items.where((e) => !e.isRead).length;

  @override
  Future<NotificationsDashboard> getDashboard() async {
    if (error != null) throw error!;
    return NotificationsDashboard(
      unreadCount: items.where((e) => !e.isRead).length,
      totalCount: items.length,
      recent: items.take(5).toList(),
    );
  }

  @override
  Future<AppNotification> getNotification(String notificationId) async {
    return items.firstWhere((e) => e.id == notificationId);
  }

  @override
  Future<PagedResult<AppNotification>> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (error != null) throw error!;
    var list = items;
    if (isRead != null) {
      list = list.where((e) => e.isRead == isRead).toList();
    }
    return PagedResult(
      items: list,
      count: list.length,
      hasMore: false,
    );
  }

  @override
  Future<int> markAllRead() async {
    markAllCalls++;
    items = items
        .map((e) => e.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    return markAllCalls;
  }

  @override
  Future<AppNotification> markRead(String notificationId) async {
    final index = items.indexWhere((e) => e.id == notificationId);
    final updated =
        items[index].copyWith(isRead: true, readAt: DateTime.now());
    items[index] = updated;
    return updated;
  }
}

AppNotification _n({
  required String id,
  required NotificationType type,
  bool isRead = false,
  Map<String, dynamic> metadata = const {},
}) {
  return AppNotification(
    id: id,
    title: 'Title $id',
    message: 'Message',
    type: type,
    channel: NotificationChannel.inApp,
    isRead: isRead,
    metadata: metadata,
    createdAt: DateTime(2026, 7, 26),
  );
}

void main() {
  test('NotificationsDashboardController loads dashboard', () async {
    final repo = FakeNotificationRepository()
      ..items = [
        _n(id: '1', type: NotificationType.loanApproved),
      ];
    final controller = NotificationsDashboardController(repository: repo);
    await controller.load();
    expect(controller.state.isSuccess, isTrue);
    expect(controller.state.data!.unreadCount, 1);
  });

  test('NotificationsDashboardController surfaces errors', () async {
    final repo = FakeNotificationRepository()
      ..error = const ServerException(message: 'Offline');
    final controller = NotificationsDashboardController(repository: repo);
    await controller.load();
    expect(controller.state.isError, isTrue);
    expect(controller.state.errorMessage, contains('Offline'));
  });

  test('NotificationsListController filters unread', () async {
    final repo = FakeNotificationRepository()
      ..items = [
        _n(id: '1', type: NotificationType.loanApplied),
        _n(id: '2', type: NotificationType.contributionRecorded, isRead: true),
      ];
    final controller = NotificationsListController(
      repository: repo,
      unreadOnly: true,
    );
    await controller.load();
    expect(controller.state.data, hasLength(1));
  });

  test('NotificationDetailsController markRead updates state', () async {
    final repo = FakeNotificationRepository()
      ..items = [
        _n(id: '1', type: NotificationType.attendanceFinalized),
      ];
    final controller = NotificationDetailsController(
      repository: repo,
      notificationId: '1',
    );
    await controller.load();
    final ok = await controller.markRead();
    expect(ok, isTrue);
    expect(controller.state.data!.isRead, isTrue);
  });

  test('NotificationUnreadCountController refresh and decrement', () async {
    final repo = FakeNotificationRepository()
      ..items = [
        _n(id: '1', type: NotificationType.loanApplied),
        _n(id: '2', type: NotificationType.loanApplied),
      ];
    final controller = NotificationUnreadCountController(repository: repo);
    await controller.refresh();
    expect(controller.state, 2);
    controller.decrement();
    expect(controller.state, 1);
    controller.setCount(0);
    expect(controller.state, 0);
  });

  group('NotificationDeepLink', () {
    test('resolves meeting with meeting_id', () {
      final n = _n(
        id: '1',
        type: NotificationType.attendanceFinalized,
        metadata: {'chama_id': 'c1', 'meeting_id': 'm1'},
      );
      expect(
        NotificationDeepLink.resolve(n),
        RoutePaths.meetingDetails('c1', 'm1'),
      );
    });

    test('resolves loan to chama loans when no application id', () {
      final n = _n(
        id: '1',
        type: NotificationType.loanApproved,
        metadata: {'chama_id': 'c1'},
      );
      expect(NotificationDeepLink.resolve(n), RoutePaths.chamaLoans('c1'));
    });

    test('resolves contribution hub', () {
      final n = _n(
        id: '1',
        type: NotificationType.contributionRecorded,
        metadata: {'chama_id': 'c1'},
      );
      expect(
        NotificationDeepLink.resolve(n),
        RoutePaths.chamaContributions('c1'),
      );
    });

    test('falls back to home', () {
      final n = _n(id: '1', type: NotificationType.unknown);
      expect(NotificationDeepLink.resolve(n), RoutePaths.home);
    });
  });
}
