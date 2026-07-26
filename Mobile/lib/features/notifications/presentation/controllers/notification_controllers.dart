import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/api_state.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationsDashboardController
    extends RefreshController<NotificationsDashboard> {
  NotificationsDashboardController({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;

  bool isMarkingAll = false;
  String? actionError;

  @override
  Future<NotificationsDashboard> fetchData({bool forceRefresh = false}) {
    return _repository.getDashboard();
  }

  Future<bool> markAllRead() async {
    if (isMarkingAll) return false;
    isMarkingAll = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      await _repository.markAllRead();
      if (!mounted) return false;
      await load(forceRefresh: true);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isMarkingAll = false;
      if (mounted) state = state.copyWith();
    }
  }
}

class NotificationsListController
    extends PaginationController<AppNotification> {
  NotificationsListController({
    required NotificationRepository repository,
    this.unreadOnly = false,
    super.pageSize = 20,
  }) : _repository = repository;

  final NotificationRepository _repository;
  bool unreadOnly;

  @override
  Future<PageResult<AppNotification>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.listNotifications(
      isRead: unreadOnly ? false : null,
      page: page,
      pageSize: pageSize,
    );
    return PageResult(
      items: result.items,
      hasMore: result.hasMore,
      totalCount: result.count,
    );
  }

  Future<void> setUnreadOnly(bool value) async {
    unreadOnly = value;
    await load();
  }

  Future<bool> markAllRead() async {
    try {
      await _repository.markAllRead();
      if (!mounted) return false;
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class NotificationDetailsController
    extends RefreshController<AppNotification> {
  NotificationDetailsController({
    required NotificationRepository repository,
    required String notificationId,
  })  : _repository = repository,
        _notificationId = notificationId;

  final NotificationRepository _repository;
  final String _notificationId;

  bool isMarking = false;
  String? actionError;

  @override
  Future<AppNotification> fetchData({bool forceRefresh = false}) {
    return _repository.getNotification(_notificationId);
  }

  Future<bool> markRead() async {
    if (isMarking) return false;
    final current = state.data;
    if (current != null && current.isRead) return true;

    isMarking = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      final updated = await _repository.markRead(_notificationId);
      if (!mounted) return false;
      state = ApiState.success(updated);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isMarking = false;
      if (mounted) state = state.copyWith();
    }
  }
}

/// Live unread badge count — refreshed by inbox actions.
class NotificationUnreadCountController extends StateNotifier<int> {
  NotificationUnreadCountController({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(0);

  final NotificationRepository _repository;
  bool _loading = false;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final count = await _repository.countUnread();
      if (!mounted) return;
      state = count;
    } catch (_) {
      // Keep last known count on transient failures.
    } finally {
      _loading = false;
    }
  }

  void setCount(int value) {
    if (!mounted) return;
    state = value < 0 ? 0 : value;
  }

  void decrement([int by = 1]) {
    if (!mounted) return;
    state = (state - by).clamp(0, 1 << 30);
  }
}
