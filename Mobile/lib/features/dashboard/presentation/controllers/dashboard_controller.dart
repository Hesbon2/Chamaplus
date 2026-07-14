import '../../../../shared/api_state.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Loads and caches dashboard data with pull-to-refresh support.
class DashboardController extends RefreshController<Dashboard> {
  DashboardController({
    required DashboardRepository repository,
    required String userId,
    required String welcomeName,
  })  : _repository = repository,
        _userId = userId,
        _welcomeName = welcomeName;

  final DashboardRepository _repository;
  final String _userId;
  final String _welcomeName;

  @override
  Future<Dashboard> fetchData({bool forceRefresh = false}) {
    return _repository.getDashboard(
      userId: _userId,
      welcomeName: _welcomeName,
      forceRefresh: forceRefresh,
    );
  }

  @override
  bool isEmptyData(Dashboard data) => !data.hasChama;
}
