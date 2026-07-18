import '../../../../shared/api_state.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Loads a single contribution cycle.
class CycleDetailsController extends RefreshController<ContributionCycle> {
  CycleDetailsController({
    required ContributionRepository repository,
    required String chamaId,
    required String cycleId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _cycleId = cycleId;

  final ContributionRepository _repository;
  final String _chamaId;
  final String _cycleId;

  bool isClosing = false;
  String? actionError;

  @override
  Future<ContributionCycle> fetchData({bool forceRefresh = false}) {
    return _repository.getCycle(chamaId: _chamaId, cycleId: _cycleId);
  }

  Future<bool> closeCycle() async {
    if (isClosing) return false;
    isClosing = true;
    actionError = null;
    state = state.copyWith();
    try {
      final updated = await _repository.closeCycle(
        chamaId: _chamaId,
        cycleId: _cycleId,
      );
      state = ApiState.success(updated);
      return true;
    } catch (error) {
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isClosing = false;
      state = state.copyWith();
    }
  }
}
