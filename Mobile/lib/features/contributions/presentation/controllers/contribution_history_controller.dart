import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Paginated contribution history with search and filters.
class ContributionHistoryController extends PaginationController<Contribution> {
  ContributionHistoryController({
    required ContributionRepository repository,
    required String chamaId,
    this.initialCycleId,
    this.initialMemberId,
    super.pageSize = 20,
  })  : _repository = repository,
        _chamaId = chamaId,
        cycleFilter = initialCycleId,
        memberFilter = initialMemberId;

  final ContributionRepository _repository;
  final String _chamaId;
  final String? initialCycleId;
  final String? initialMemberId;

  String searchQuery = '';
  String? cycleFilter;
  String? memberFilter;

  @override
  Future<PageResult<Contribution>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.listContributions(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      cycleId: cycleFilter,
      memberId: memberFilter,
      page: page,
      pageSize: pageSize,
    );
    return PageResult(
      items: result.items,
      hasMore: result.hasMore,
      totalCount: result.count,
    );
  }

  Future<void> search(String query) async {
    searchQuery = query;
    await load();
  }

  Future<void> setCycleFilter(String? cycleId) async {
    cycleFilter = cycleId;
    await load();
  }
}
