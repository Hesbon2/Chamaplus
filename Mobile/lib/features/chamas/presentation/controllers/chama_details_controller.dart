import '../../../../shared/api_state.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Loads a single chama overview with pull-to-refresh.
class ChamaDetailsController extends RefreshController<ChamaDetails> {
  ChamaDetailsController({
    required ChamaRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ChamaRepository _repository;
  final String _chamaId;

  @override
  Future<ChamaDetails> fetchData({bool forceRefresh = false}) {
    return _repository.getChamaDetails(_chamaId);
  }
}
