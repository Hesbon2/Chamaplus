import 'package:chamaplus_mobile/features/notifications/domain/entities/notification.dart';
import 'package:chamaplus_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/controllers/notification_controllers.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/providers/notification_providers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements NotificationRepository {
  _FakeRepo({this.unread = 3});

  final int unread;
  final List<AppNotification> items = [
    AppNotification(
      id: 'n1',
      title: 'Loan approved',
      message: 'Approved',
      type: NotificationType.loanApproved,
      channel: NotificationChannel.inApp,
      isRead: false,
      metadata: const {'chama_id': 'c1'},
      createdAt: DateTime(2026, 7, 26),
    ),
  ];

  @override
  Future<int> countUnread() async => unread;

  @override
  Future<NotificationsDashboard> getDashboard() async {
    return NotificationsDashboard(
      unreadCount: unread,
      totalCount: items.length,
      recent: items,
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
    return PagedResult(items: items, count: items.length);
  }

  @override
  Future<int> markAllRead() async => unread;

  @override
  Future<AppNotification> markRead(String notificationId) async {
    return items.first.copyWith(isRead: true, readAt: DateTime.now());
  }
}

void main() {
  test('notificationUnreadCountProvider refreshes from repository', () async {
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(_FakeRepo(unread: 4)),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(notificationUnreadCountProvider.notifier);
    await controller.refresh();
    expect(container.read(notificationUnreadCountProvider), 4);
  });

  test('notificationsDashboardProvider loads success state', () async {
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
    );
    addTearDown(container.dispose);

    // Wait for microtask load from provider.
    await Future<void>.delayed(Duration.zero);
    await container.read(notificationsDashboardProvider.notifier).load();

    final state = container.read(notificationsDashboardProvider);
    expect(state.isSuccess, isTrue);
    expect(state.data!.unreadCount, 3);
    expect(state.data!.recent, hasLength(1));
  });

  test('notificationDetailsControllerProvider exposes loaded notification',
      () async {
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(notificationDetailsControllerProvider('n1').notifier)
        .load();

    final state = container.read(notificationDetailsControllerProvider('n1'));
    expect(state, isA<ApiState<AppNotification>>());
    expect(state.data!.title, 'Loan approved');
  });
}
