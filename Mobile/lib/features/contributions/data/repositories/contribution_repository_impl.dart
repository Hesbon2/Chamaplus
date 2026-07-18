import 'package:intl/intl.dart';

import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_api.dart';
import '../dtos/contribution_dtos.dart';

/// Maps contribution APIs into domain models.
class ContributionRepositoryImpl implements ContributionRepository {
  ContributionRepositoryImpl(this._api);

  final ContributionRemoteDataSource _api;
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<ContributionCycle>> listCycles({
    required String chamaId,
    String? search,
    CycleStatus? status,
  }) async {
    final dtos = await _api.listCycles(
      chamaId: chamaId,
      search: search,
      status: status?.apiValue,
    );
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ContributionCycle> getCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    final dto = await _api.getCycle(chamaId: chamaId, cycleId: cycleId);
    return dto.toEntity();
  }

  @override
  Future<ContributionCycle> createCycle({
    required String chamaId,
    required CreateCycleInput input,
  }) async {
    final dto = await _api.createCycle(
      chamaId: chamaId,
      body: {
        'name': input.name.trim(),
        'frequency': input.frequency.apiValue,
        'contribution_amount': input.contributionAmount,
        'start_date': _dateFormat.format(input.startDate),
        'end_date': _dateFormat.format(input.endDate),
        'due_day': input.dueDay,
        'penalty_amount': input.penaltyAmount,
      },
    );
    return dto.toEntity();
  }

  @override
  Future<ContributionCycle> closeCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    final dto = await _api.closeCycle(chamaId: chamaId, cycleId: cycleId);
    return dto.toEntity();
  }

  @override
  Future<PagedResult<Contribution>> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await _api.listContributions(
      chamaId: chamaId,
      search: search,
      cycleId: cycleId,
      memberId: memberId,
      page: page,
      pageSize: pageSize,
    );
    return PagedResult(
      items: dto.results.map((e) => e.toEntity()).toList(),
      count: dto.count,
      hasMore: dto.next != null && dto.next!.isNotEmpty,
      nextPage: dto.next != null ? page + 1 : null,
    );
  }

  @override
  Future<Contribution> getContribution({
    required String chamaId,
    required String contributionId,
  }) async {
    final dto = await _api.getContribution(
      chamaId: chamaId,
      contributionId: contributionId,
    );
    return dto.toEntity();
  }

  @override
  Future<Contribution> recordContribution({
    required String chamaId,
    required RecordContributionInput input,
  }) async {
    final dto = await _api.recordContribution(
      chamaId: chamaId,
      body: {
        'cycle_id': input.cycleId,
        'member_id': input.memberId,
        'amount': input.amount,
        'payment_method': input.paymentMethod.apiValue,
        'reference': input.reference.trim(),
        if (input.recordedAt != null)
          'recorded_at': input.recordedAt!.toUtc().toIso8601String(),
        if (input.idempotencyKey != null && input.idempotencyKey!.isNotEmpty)
          'idempotency_key': input.idempotencyKey,
      },
    );
    return dto.toEntity();
  }

  @override
  Future<ContributionSummary> getContributionSummary({
    required String chamaId,
    String? cycleId,
  }) async {
    final dto = await _api.getContributionSummary(
      chamaId: chamaId,
      cycleId: cycleId,
    );
    return dto.toEntity();
  }

  @override
  Future<ContributionDashboard> getDashboard({
    required String chamaId,
  }) async {
    final cyclesFuture = _api.listCycles(
      chamaId: chamaId,
      status: CycleStatus.open.apiValue,
    );
    final recentFuture =
        _api.listContributions(chamaId: chamaId, page: 1, pageSize: 5);

    ContributionSummaryDto summaryDto;
    try {
      summaryDto = await _api.getContributionSummary(chamaId: chamaId);
    } catch (_) {
      final page =
          await _api.listContributions(chamaId: chamaId, page: 1, pageSize: 1);
      final currency = page.results.isNotEmpty
          ? page.results.first.currency
          : 'KES';
      summaryDto = ContributionSummaryDto(
        totalAmount: '—',
        totalCount: page.count,
        currency: currency,
      );
    }

    final cycles = await cyclesFuture;
    final recent = await recentFuture;

    return ContributionDashboard(
      summary: summaryDto.toEntity(),
      openCycles: cycles.map((e) => e.toEntity()).toList(),
      recentContributions: recent.results.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<MemberContributionSummary> getMemberSummary({
    required String chamaId,
    required String memberId,
  }) async {
    final dto = await _api.getMemberSummary(
      chamaId: chamaId,
      memberId: memberId,
    );
    return dto.toEntity();
  }
}
