import '../../../../core/errors/app_exception.dart';
import '../../../../shared/api_state.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Paginated join requests with approve / reject actions.
class JoinRequestsController extends PaginationController<Membership> {
  JoinRequestsController({
    required ChamaRepository repository,
    required String chamaId,
    super.pageSize = 20,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ChamaRepository _repository;
  final String _chamaId;

  Set<String> processingIds = {};
  String? actionMessage;
  String? errorMessage;

  @override
  Future<PageResult<Membership>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.listJoinRequests(
      chamaId: _chamaId,
      page: page,
      pageSize: pageSize,
    );
    return PageResult(
      items: result.items,
      hasMore: result.hasMore,
      totalCount: result.count,
    );
  }

  Future<void> approve(String membershipId) async {
    await _process(
      membershipId,
      () => _repository.approveJoinRequest(membershipId),
      successMessage: 'Join request approved.',
    );
  }

  Future<void> reject(String membershipId) async {
    await _process(
      membershipId,
      () => _repository.rejectJoinRequest(membershipId),
      successMessage: 'Join request rejected.',
    );
  }

  Future<void> _process(
    String membershipId,
    Future<Membership> Function() action, {
    required String successMessage,
  }) async {
    processingIds = {...processingIds, membershipId};
    actionMessage = null;
    errorMessage = null;
    state = state.copyWith();

    try {
      await action();
      final updated = items.where((r) => r.id != membershipId).toList();
      processingIds = {...processingIds}..remove(membershipId);
      actionMessage = successMessage;
      if (totalCount != null && totalCount! > 0) {
        totalCount = totalCount! - 1;
      }
      if (updated.isEmpty) {
        state = const ApiState.empty();
      } else {
        state = ApiState.success(
          updated,
          hasMore: state.hasMore,
          isLoadingMore: false,
        );
      }
    } on AppException catch (error) {
      processingIds = {...processingIds}..remove(membershipId);
      errorMessage = error.message;
      state = state.copyWith();
    } catch (_) {
      processingIds = {...processingIds}..remove(membershipId);
      errorMessage = 'Action failed. Please try again.';
      state = state.copyWith();
    }
  }
}
