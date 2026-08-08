import '../../../../shared/api_state.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Lists pending Chama invitations for the authenticated user.
class PendingInvitationsController
    extends RefreshController<List<Membership>> {
  PendingInvitationsController(this._repository);

  final ChamaRepository _repository;

  @override
  Future<List<Membership>> fetchData({bool forceRefresh = false}) {
    return _repository.listPendingInvitations();
  }

  @override
  bool isEmptyData(List<Membership> data) => data.isEmpty;

  Future<Membership?> accept(String membershipId) async {
    final membership = await _repository.acceptInvitation(membershipId);
    await load(forceRefresh: true);
    return membership;
  }

  Future<Membership?> decline(String membershipId) async {
    final membership = await _repository.declineInvitation(membershipId);
    await load(forceRefresh: true);
    return membership;
  }
}
