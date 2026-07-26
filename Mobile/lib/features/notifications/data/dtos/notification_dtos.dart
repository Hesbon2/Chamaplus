import '../../domain/entities/notification.dart';

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}

class NotificationItemDto {
  const NotificationItemDto({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.channel,
    required this.isRead,
    this.readAt,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String notificationType;
  final String channel;
  final bool isRead;
  final String? readAt;
  final Map<String, dynamic> metadata;
  final String createdAt;

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['metadata'];
    return NotificationItemDto(
      id: '${json['id']}',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      notificationType: json['notification_type'] as String? ?? '',
      channel: json['channel'] as String? ?? 'in_app',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      metadata: rawMeta is Map
          ? Map<String, dynamic>.from(rawMeta)
          : const <String, dynamic>{},
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: NotificationType.fromApi(notificationType),
      channel: NotificationChannel.fromApi(channel),
      isRead: isRead,
      readAt: _asDate(readAt),
      metadata: metadata,
      createdAt: _asDate(createdAt) ?? DateTime.now(),
    );
  }
}

class NotificationsPageDto {
  const NotificationsPageDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<NotificationItemDto> results;
  final String? next;
  final String? previous;

  factory NotificationsPageDto.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return NotificationsPageDto(
      count: json['count'] as int? ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results
          .map((e) => NotificationItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
