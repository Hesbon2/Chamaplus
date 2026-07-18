import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/contributions/data/datasources/contribution_api.dart';
import 'package:chamaplus_mobile/features/contributions/data/dtos/contribution_dtos.dart';
import 'package:chamaplus_mobile/features/contributions/data/repositories/contribution_repository_impl.dart';
import 'package:chamaplus_mobile/features/contributions/domain/entities/contribution.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContributionApi implements ContributionRemoteDataSource {
  List<ContributionCycleDto> cycles = [];
  ContributionsPageDto contributionsPage = const ContributionsPageDto(
    count: 0,
    results: [],
  );
  ContributionSummaryDto summary = const ContributionSummaryDto(
    totalAmount: '1000.00',
    totalCount: 2,
    currency: 'KES',
  );
  MemberContributionSummaryDto? memberSummary;
  ContributionDto? recorded;
  ContributionCycleDto? created;
  Object? error;
  Object? summaryError;
  Object? listError;

  @override
  Future<ContributionCycleDto> closeCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    if (error != null) throw error!;
    final cycle = cycles.firstWhere((c) => c.id == cycleId);
    final closed = ContributionCycleDto(
      id: cycle.id,
      chamaId: cycle.chamaId,
      name: cycle.name,
      frequency: cycle.frequency,
      contributionAmount: cycle.contributionAmount,
      startDate: cycle.startDate,
      endDate: cycle.endDate,
      dueDay: cycle.dueDay,
      penaltyAmount: cycle.penaltyAmount,
      status: 'closed',
    );
    cycles = cycles.map((c) => c.id == cycleId ? closed : c).toList();
    return closed;
  }

  @override
  Future<ContributionCycleDto> createCycle({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    if (error != null) throw error!;
    created = ContributionCycleDto(
      id: 'cycle-new',
      chamaId: chamaId,
      name: body['name'] as String,
      frequency: body['frequency'] as String,
      contributionAmount: '${body['contribution_amount']}',
      startDate: body['start_date'] as String,
      endDate: body['end_date'] as String,
      dueDay: body['due_day'] as int,
      penaltyAmount: '${body['penalty_amount'] ?? '0.00'}',
      status: 'open',
    );
    cycles = [...cycles, created!];
    return created!;
  }

  @override
  Future<ContributionDto> getContribution({
    required String chamaId,
    required String contributionId,
  }) async {
    final matches = contributionsPage.results
        .where((c) => c.id == contributionId)
        .toList();
    if (matches.isEmpty) {
      throw const ServerException(message: 'Not found');
    }
    return matches.first;
  }

  @override
  Future<ContributionSummaryDto> getContributionSummary({
    required String chamaId,
    String? cycleId,
  }) async {
    if (summaryError != null) throw summaryError!;
    return summary;
  }

  @override
  Future<ContributionCycleDto> getCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    return cycles.firstWhere((c) => c.id == cycleId);
  }

  @override
  Future<MemberContributionSummaryDto> getMemberSummary({
    required String chamaId,
    required String memberId,
  }) async {
    return memberSummary ??
        MemberContributionSummaryDto(
          memberId: memberId,
          contributionsTotal: '500.00',
          contributionsCount: 1,
        );
  }

  @override
  Future<ContributionsPageDto> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) async {
    var results = contributionsPage.results;
    if (cycleId != null) {
      results = results.where((c) => c.cycleId == cycleId).toList();
    }
    if (search != null && search.isNotEmpty) {
      results = results
          .where((c) =>
              c.reference.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return ContributionsPageDto(
      count: results.length,
      results: results,
      next: null,
    );
  }

  @override
  Future<List<ContributionCycleDto>> listCycles({
    required String chamaId,
    String? search,
    String? status,
  }) async {
    if (listError != null) throw listError!;
    var result = cycles;
    if (status != null) {
      result = result.where((c) => c.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      result = result
          .where((c) => c.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  Future<ContributionDto> recordContribution({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    if (error != null) throw error!;
    recorded = ContributionDto(
      id: 'contrib-1',
      memberId: body['member_id'] as String,
      cycleId: body['cycle_id'] as String,
      amount: '${body['amount']}',
      currency: 'KES',
      paymentMethod: body['payment_method'] as String,
      reference: body['reference'] as String,
      recordedBy: 'user-1',
      recordedAt: DateTime.now().toIso8601String(),
    );
    return recorded!;
  }
}

ContributionCycleDto sampleCycle({
  String id = 'cycle-1',
  String status = 'open',
  String name = 'July Cycle',
}) {
  return ContributionCycleDto(
    id: id,
    chamaId: 'chama-1',
    name: name,
    frequency: 'monthly',
    contributionAmount: '5000.00',
    startDate: '2026-07-01',
    endDate: '2026-07-31',
    dueDay: 15,
    penaltyAmount: '200.00',
    status: status,
  );
}

ContributionDto sampleContribution({
  String id = 'c1',
  String reference = 'CASH-001',
}) {
  return ContributionDto(
    id: id,
    memberId: 'member-1',
    cycleId: 'cycle-1',
    amount: '5000.00',
    currency: 'KES',
    paymentMethod: 'cash',
    reference: reference,
    recordedBy: 'user-1',
    recordedAt: '2026-07-10T10:00:00Z',
  );
}

void main() {
  late FakeContributionApi api;
  late ContributionRepositoryImpl repository;

  setUp(() {
    api = FakeContributionApi()
      ..cycles = [sampleCycle()]
      ..contributionsPage = ContributionsPageDto(
        count: 1,
        results: [sampleContribution()],
      );
    repository = ContributionRepositoryImpl(api);
  });

  group('ContributionRepositoryImpl', () {
    test('listCycles maps entities and filters', () async {
      api.cycles = [
        sampleCycle(),
        sampleCycle(id: 'cycle-2', status: 'closed', name: 'June'),
      ];
      final open = await repository.listCycles(
        chamaId: 'chama-1',
        status: CycleStatus.open,
      );
      expect(open, hasLength(1));
      expect(open.first.name, 'July Cycle');
      expect(open.first.isOpen, isTrue);
    });

    test('createCycle posts payload and maps entity', () async {
      final cycle = await repository.createCycle(
        chamaId: 'chama-1',
        input: CreateCycleInput(
          name: 'August Cycle',
          frequency: CycleFrequency.monthly,
          contributionAmount: '6000.00',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 31),
          dueDay: 10,
          penaltyAmount: '100.00',
        ),
      );
      expect(cycle.name, 'August Cycle');
      expect(api.created?.frequency, 'monthly');
    });

    test('listContributions returns paged result', () async {
      final page = await repository.listContributions(chamaId: 'chama-1');
      expect(page.count, 1);
      expect(page.items.first.reference, 'CASH-001');
      expect(page.items.first.paymentMethod, PaymentMethod.cash);
    });

    test('recordContribution maps request body', () async {
      final contribution = await repository.recordContribution(
        chamaId: 'chama-1',
        input: const RecordContributionInput(
          cycleId: 'cycle-1',
          memberId: 'member-1',
          amount: '5000.00',
          paymentMethod: PaymentMethod.mpesa,
          reference: 'MPESA-9',
        ),
      );
      expect(contribution.id, 'contrib-1');
      expect(api.recorded?.paymentMethod, 'mpesa');
    });

    test('getDashboard falls back when summary report fails', () async {
      api.summaryError = const ServerException(message: 'Forbidden');
      final dashboard = await repository.getDashboard(chamaId: 'chama-1');
      expect(dashboard.summary.totalCount, 1);
      expect(dashboard.openCycles, hasLength(1));
      expect(dashboard.recentContributions, hasLength(1));
    });

    test('closeCycle updates status', () async {
      final closed = await repository.closeCycle(
        chamaId: 'chama-1',
        cycleId: 'cycle-1',
      );
      expect(closed.status, CycleStatus.closed);
    });
  });
}
