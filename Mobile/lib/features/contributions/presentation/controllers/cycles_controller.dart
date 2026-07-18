import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Lists contribution cycles with optional status / search filters.
class CyclesController extends RefreshController<List<ContributionCycle>> {
  CyclesController({
    required ContributionRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ContributionRepository _repository;
  final String _chamaId;

  String searchQuery = '';
  CycleStatus? statusFilter;

  @override
  Future<List<ContributionCycle>> fetchData({bool forceRefresh = false}) {
    return _repository.listCycles(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      status: statusFilter,
    );
  }

  @override
  bool isEmptyData(List<ContributionCycle> data) => data.isEmpty;

  Future<void> search(String query) async {
    searchQuery = query;
    await load(forceRefresh: true);
  }

  Future<void> setStatusFilter(CycleStatus? status) async {
    statusFilter = status;
    await load(forceRefresh: true);
  }

  Future<ContributionCycle> createCycle(CreateCycleInput input) {
    return _repository.createCycle(chamaId: _chamaId, input: input);
  }

  Future<void> closeCycle(String cycleId) async {
    await _repository.closeCycle(chamaId: _chamaId, cycleId: cycleId);
    await refresh();
  }
}
