import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/chama_dto.dart';
import '../dtos/dashboard_response_dto.dart';
import '../dtos/monthly_report_dto.dart';
import '../dtos/notification_dto.dart';
import 'dashboard_remote_data_source.dart';

/// Remote API client for dashboard-related endpoints.
class DashboardApi implements DashboardRemoteDataSource {
  DashboardApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ChamaDto>> listChamas() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamas,
    );

    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return envelope.data!
        .map((item) => ChamaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DashboardResponseDto> getDashboard(String chamaId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaDashboard(chamaId),
    );

    return _parseDashboard(response.data);
  }

  @override
  Future<String?> getUserRole({
    required String chamaId,
    required String userId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMembers(chamaId),
      queryParameters: {'page_size': 100},
    );

    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );

    if (!envelope.success || envelope.data == null) {
      return null;
    }

    final results = envelope.data!['results'] as List<dynamic>? ?? [];
    for (final item in results) {
      final member = item as Map<String, dynamic>;
      final user = member['user'] as Map<String, dynamic>?;
      if (user != null && user['id'] == userId) {
        final role = member['role'] as Map<String, dynamic>?;
        return role?['name'] as String? ?? role?['slug'] as String?;
      }
    }

    return null;
  }

  @override
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {
        if (isRead != null) 'is_read': isRead.toString(),
        'page_size': pageSize,
        'ordering': '-created_at',
      },
    );

    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return NotificationsPageDto.fromJson(envelope.data!);
  }

  @override
  Future<MonthlyReportDto?> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.chamaMonthlyReport(chamaId),
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data ?? {},
        (data) => Map<String, dynamic>.from(data as Map? ?? {}),
      );

      if (!envelope.success || envelope.data == null) {
        return null;
      }

      return MonthlyReportDto.fromJson(envelope.data!);
    } on AppException {
      return null;
    }
  }

  DashboardResponseDto _parseDashboard(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return DashboardResponseDto.fromJson(envelope.data!);
  }
}
