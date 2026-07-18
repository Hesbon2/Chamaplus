import '../entities/contribution.dart';

/// Contract for contribution cycles and payments.
abstract class ContributionRepository {
  Future<List<ContributionCycle>> listCycles({
    required String chamaId,
    String? search,
    CycleStatus? status,
  });

  Future<ContributionCycle> getCycle({
    required String chamaId,
    required String cycleId,
  });

  Future<ContributionCycle> createCycle({
    required String chamaId,
    required CreateCycleInput input,
  });

  Future<ContributionCycle> closeCycle({
    required String chamaId,
    required String cycleId,
  });

  Future<PagedResult<Contribution>> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Contribution> getContribution({
    required String chamaId,
    required String contributionId,
  });

  Future<Contribution> recordContribution({
    required String chamaId,
    required RecordContributionInput input,
  });

  Future<ContributionSummary> getContributionSummary({
    required String chamaId,
    String? cycleId,
  });

  Future<ContributionDashboard> getDashboard({
    required String chamaId,
  });

  Future<MemberContributionSummary> getMemberSummary({
    required String chamaId,
    required String memberId,
  });
}
