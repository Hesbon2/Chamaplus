import '../../../../shared/api_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Loads the current user profile for the Profile screen.
class ProfileController extends RefreshController<User> {
  ProfileController(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> fetchData({bool forceRefresh = false}) {
    return _repository.getCurrentUser();
  }
}
