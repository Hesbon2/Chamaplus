class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationsPageDto {
  const NotificationsPageDto({
    required this.count,
    required this.results,
  });

  final int count;
  final List<NotificationDto> results;

  factory NotificationsPageDto.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return NotificationsPageDto(
      count: json['count'] as int? ?? results.length,
      results: results
          .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
