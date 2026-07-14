import '../../../../shared/api_state.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Paginated active members with search + infinite scroll.
class MembersController extends PaginationController<Membership> {
  MembersController({
    required ChamaRepository repository,
    required String chamaId,
    super.pageSize = 20,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ChamaRepository _repository;
  final String _chamaId;

  String searchQuery = '';

  @override
  Future<PageResult<Membership>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.listMembers(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      status: MembershipStatus.active,
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
}
