import 'package:chamaplus_mobile/core/models/paged_result.dart';
import 'package:chamaplus_mobile/features/contributions/domain/entities/contribution.dart';
import 'package:chamaplus_mobile/features/contributions/domain/repositories/contribution_repository.dart';
import 'package:chamaplus_mobile/features/contributions/presentation/providers/contribution_providers.dart';
import 'package:chamaplus_mobile/features/contributions/presentation/screens/contribution_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeContributionRepo implements ContributionRepository {
  @override
  Future<ContributionCycle> closeCycle({
    required String chamaId,
    required String cycleId,
  }) =>
      throw UnimplementedError();

  @override
  Future<ContributionCycle> createCycle({
    required String chamaId,
    required CreateCycleInput input,
  }) =>
      throw UnimplementedError();

  @override
  Future<Contribution> getContribution({
    required String chamaId,
    required String contributionId,
  }) =>
      throw UnimplementedError();

  @override
  Future<ContributionSummary> getContributionSummary({
    required String chamaId,
    String? cycleId,
  }) =>
      throw UnimplementedError();

  @override
  Future<ContributionCycle> getCycle({
    required String chamaId,
    required String cycleId,
  }) =>
      throw UnimplementedError();

  @override
  Future<ContributionDashboard> getDashboard({required String chamaId}) async {
    return ContributionDashboard(
      summary: const ContributionSummary(
        totalAmount: '15000.00',
        totalCount: 3,
        currency: 'KES',
      ),
      openCycles: [
        ContributionCycle(
          id: 'cycle-1',
          chamaId: 'chama-1',
          name: 'July Cycle',
          frequency: CycleFrequency.monthly,
          contributionAmount: '5000.00',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 31),
          dueDay: 15,
          penaltyAmount: '0.00',
          status: CycleStatus.open,
        ),
      ],
      recentContributions: [
        Contribution(
          id: 'c1',
          memberId: 'm1',
          cycleId: 'cycle-1',
          amount: '5000.00',
          currency: 'KES',
          paymentMethod: PaymentMethod.cash,
          reference: 'CASH-001',
          recordedBy: 'u1',
          recordedAt: DateTime(2026, 7, 10),
        ),
      ],
    );
  }

  @override
  Future<MemberContributionSummary> getMemberSummary({
    required String chamaId,
    required String memberId,
  }) =>
      throw UnimplementedError();

  @override
  Future<PagedResult<Contribution>> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<ContributionCycle>> listCycles({
    required String chamaId,
    String? search,
    CycleStatus? status,
  }) =>
      throw UnimplementedError();

  @override
  Future<Contribution> recordContribution({
    required String chamaId,
    required RecordContributionInput input,
  }) =>
      throw UnimplementedError();
}

void main() {
  testWidgets('ContributionDashboardScreen shows summary and cycle',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributionRepositoryProvider.overrideWithValue(
            _FakeContributionRepo(),
          ),
        ],
        child: const MaterialApp(
          home: ContributionDashboardScreen(chamaId: 'chama-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Contributions'), findsWidgets);
    expect(find.textContaining('15000'), findsOneWidget);
    expect(find.text('July Cycle'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('CASH-001'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CASH-001'), findsOneWidget);
  });
}
