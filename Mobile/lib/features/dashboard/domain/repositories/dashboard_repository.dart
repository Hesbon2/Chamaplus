import '../entities/dashboard.dart';

/// Contract for loading the member dashboard.
abstract class DashboardRepository {
  /// Loads the dashboard, using a short-lived cache unless [forceRefresh] is true.
  Future<Dashboard> getDashboard({
    required String userId,
    required String welcomeName,
    bool forceRefresh = false,
  });

  void clearCache();
}
