import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Loads the chama-scoped contributions dashboard.
class ContributionDashboardController
    extends RefreshController<ContributionDashboard> {
  ContributionDashboardController({
    required ContributionRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ContributionRepository _repository;
  final String _chamaId;

  @override
  Future<ContributionDashboard> fetchData({bool forceRefresh = false}) {
    return _repository.getDashboard(chamaId: _chamaId);
  }
}
