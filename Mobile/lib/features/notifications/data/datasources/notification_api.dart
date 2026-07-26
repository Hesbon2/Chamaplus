import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/notification_dtos.dart';

/// Remote notifications API.
abstract class NotificationRemoteDataSource {
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<NotificationItemDto> getNotification(String notificationId);

  Future<NotificationItemDto> markRead(String notificationId);

  Future<int> markAllRead();
}

class NotificationApi implements NotificationRemoteDataSource {
  NotificationApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {
        if (isRead != null) 'is_read': isRead.toString(),
        'page': page,
        'page_size': pageSize,
        'ordering': '-created_at',
      },
    );
    return NotificationsPageDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<NotificationItemDto> getNotification(String notificationId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.notificationDetail(notificationId),
    );
    return NotificationItemDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<NotificationItemDto> markRead(String notificationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.notificationDetail(notificationId),
      data: const {'is_read': true},
    );
    return NotificationItemDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<int> markAllRead() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.notificationsMarkAllRead,
    );
    final data = _unwrapMap(response.data);
    return data['updated_count'] as int? ?? 0;
  }

  Map<String, dynamic> _unwrapMap(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!;
  }
}
