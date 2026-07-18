import 'package:chamaplus_mobile/core/models/paged_result.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/screens/my_chamas_screen.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ChamaRepository {
  @override
  Future<Membership> approveJoinRequest(String membershipId) {
    throw UnimplementedError();
  }

  @override
  Future<Chama> getChama(String chamaId) {
    throw UnimplementedError();
  }

  @override
  Future<ChamaDetails> getChamaDetails(String chamaId) {
    throw UnimplementedError();
  }

  @override
  Future<Membership?> getMember({
    required String chamaId,
    required String membershipId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Chama>> listChamas({String? search}) async {
    return const [
      Chama(
        id: 'c1',
        name: 'Unity Chama',
        location: 'Nairobi',
        currency: 'KES',
        isActive: true,
      ),
    ];
  }

  @override
  Future<List<Membership>> listCommitteeMembers(String chamaId) {
    throw UnimplementedError();
  }

  @override
  Future<PagedResult<Membership>> listJoinRequests({
    required String chamaId,
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PagedResult<Membership>> listMembers({
    required String chamaId,
    String? search,
    MembershipStatus? status,
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Membership> rejectJoinRequest(String membershipId) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('MyChamasScreen shows chama cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: const MaterialApp(home: MyChamasScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('My Chamas'), findsOneWidget);
    expect(find.text('Unity Chama'), findsOneWidget);
    expect(find.text('Nairobi'), findsOneWidget);
  });
}
