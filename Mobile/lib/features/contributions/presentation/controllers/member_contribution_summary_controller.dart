import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Loads a member's contribution / financial summary.
class MemberContributionSummaryController
    extends RefreshController<MemberContributionSummary> {
  MemberContributionSummaryController({
    required ContributionRepository repository,
    required String chamaId,
    required String memberId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _memberId = memberId;

  final ContributionRepository _repository;
  final String _chamaId;
  final String _memberId;

  @override
  Future<MemberContributionSummary> fetchData({bool forceRefresh = false}) {
    return _repository.getMemberSummary(
      chamaId: _chamaId,
      memberId: _memberId,
    );
  }
}
