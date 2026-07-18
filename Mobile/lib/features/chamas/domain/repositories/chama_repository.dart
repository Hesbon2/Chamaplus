import '../../../../core/models/paged_result.dart';
import '../entities/chama.dart';

export '../../../../core/models/paged_result.dart';

/// Contract for Chama management operations.
abstract class ChamaRepository {
  Future<List<Chama>> listChamas({String? search});

  Future<Chama> getChama(String chamaId);

  Future<ChamaDetails> getChamaDetails(String chamaId);

  Future<PagedResult<Membership>> listMembers({
    required String chamaId,
    String? search,
    MembershipStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<Membership?> getMember({
    required String chamaId,
    required String membershipId,
  });

  Future<List<Membership>> listCommitteeMembers(String chamaId);

  Future<PagedResult<Membership>> listJoinRequests({
    required String chamaId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Membership> approveJoinRequest(String membershipId);

  Future<Membership> rejectJoinRequest(String membershipId);
}
