import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../data/datasources/notification_api.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../controllers/notification_controllers.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationApiProvider));
});

/// Unread count for [NavigationBadge] on the Alerts tab.
final notificationUnreadCountProvider =
    StateNotifierProvider<NotificationUnreadCountController, int>((ref) {
  final controller = NotificationUnreadCountController(
    repository: ref.watch(notificationRepositoryProvider),
  );
  Future.microtask(controller.refresh);
  return controller;
});

final notificationsDashboardProvider = StateNotifierProvider.autoDispose<
    NotificationsDashboardController, ApiState<NotificationsDashboard>>((ref) {
  final controller = NotificationsDashboardController(
    repository: ref.watch(notificationRepositoryProvider),
  );
  Future.microtask(controller.load);
  return controller;
});

final notificationsListControllerProvider = StateNotifierProvider.autoDispose
    .family<NotificationsListController, ApiState<List<AppNotification>>, bool>(
        (ref, unreadOnly) {
  final controller = NotificationsListController(
    repository: ref.watch(notificationRepositoryProvider),
    unreadOnly: unreadOnly,
  );
  Future.microtask(controller.load);
  return controller;
});

final notificationDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<NotificationDetailsController, ApiState<AppNotification>, String>(
        (ref, notificationId) {
  final controller = NotificationDetailsController(
    repository: ref.watch(notificationRepositoryProvider),
    notificationId: notificationId,
  );
  Future.microtask(controller.load);
  return controller;
});
