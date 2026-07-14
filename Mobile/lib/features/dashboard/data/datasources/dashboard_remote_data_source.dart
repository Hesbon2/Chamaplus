import '../dtos/chama_dto.dart';
import '../dtos/dashboard_response_dto.dart';
import '../dtos/monthly_report_dto.dart';
import '../dtos/notification_dto.dart';

/// Contract for dashboard remote data operations.
abstract class DashboardRemoteDataSource {
  Future<List<ChamaDto>> listChamas();
  Future<DashboardResponseDto> getDashboard(String chamaId);
  Future<String?> getUserRole({
    required String chamaId,
    required String userId,
  });
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int pageSize = 10,
  });
  Future<MonthlyReportDto?> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  });
}
