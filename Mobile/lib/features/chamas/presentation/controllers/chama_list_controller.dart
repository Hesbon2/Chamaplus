import '../../../../shared/api_state.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Lists chamas with client-side page slicing for infinite scroll.
class ChamaListController extends PaginationController<Chama> {
  ChamaListController(
    this._repository, {
    super.pageSize = 10,
  });

  final ChamaRepository _repository;

  String searchQuery = '';
  List<Chama> _all = const [];

  @override
  Future<PageResult<Chama>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    if (page == 1) {
      _all = await _repository.listChamas(
        search: searchQuery.isEmpty ? null : searchQuery,
      );
    }

    final start = (page - 1) * pageSize;
    if (start >= _all.length) {
      return PageResult(items: const [], hasMore: false, totalCount: _all.length);
    }
    final end = (start + pageSize).clamp(0, _all.length);
    return PageResult(
      items: _all.sublist(start, end),
      hasMore: end < _all.length,
      totalCount: _all.length,
    );
  }

  Future<void> search(String query) async {
    searchQuery = query;
    await load();
  }
}
