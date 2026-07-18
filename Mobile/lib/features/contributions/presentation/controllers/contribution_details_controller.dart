import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Loads a single contribution record.
class ContributionDetailsController extends RefreshController<Contribution> {
  ContributionDetailsController({
    required ContributionRepository repository,
    required String chamaId,
    required String contributionId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _contributionId = contributionId;

  final ContributionRepository _repository;
  final String _chamaId;
  final String _contributionId;

  @override
  Future<Contribution> fetchData({bool forceRefresh = false}) {
    return _repository.getContribution(
      chamaId: _chamaId,
      contributionId: _contributionId,
    );
  }
}
