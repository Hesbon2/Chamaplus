import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/features/loans/domain/entities/loan.dart';
import 'package:chamaplus_mobile/features/loans/domain/repositories/loan_repository.dart';
import 'package:chamaplus_mobile/features/loans/presentation/controllers/loan_controllers.dart';
import 'package:chamaplus_mobile/features/loans/presentation/providers/loan_providers.dart';
import 'package:chamaplus_mobile/features/loans/presentation/screens/create_loan_product_screen.dart';
import 'package:chamaplus_mobile/features/loans/presentation/screens/loan_product_details_screen.dart';
import 'package:chamaplus_mobile/features/loans/presentation/screens/loan_products_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:chamaplus_mobile/shared/components/components.dart';
import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _sampleProduct = LoanProduct(
  id: 'p1',
  chamaId: 'c1',
  name: 'Emergency',
  description: 'Short term support',
  interestRate: 12,
  minimumAmount: 1000,
  maximumAmount: 50000,
  maximumDuration: 12,
  gracePeriodDays: 7,
  processingFee: 100,
  isActive: true,
);

class _FakeLoanRepository implements LoanRepository {
  _FakeLoanRepository({this.products = const [], this.error});

  List<LoanProduct> products;
  Object? error;
  int createCalls = 0;
  int deleteCalls = 0;

  @override
  Future<LoanApplication> apply({
    required String chamaId,
    required ApplyLoanInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> approveApplication({
    required String chamaId,
    required String applicationId,
    double? approvedAmount,
    String? remarks,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> cancelApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({CommitteeVote vote, LoanApplication application})> castVote({
    required String chamaId,
    required String applicationId,
    required CastVoteInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanProduct> createProduct({
    required String chamaId,
    required LoanProductInput input,
  }) async {
    createCalls++;
    if (error != null) throw error!;
    final product = LoanProduct(
      id: 'p-new',
      chamaId: chamaId,
      name: input.name,
      description: input.description,
      interestRate: input.interestRate,
      minimumAmount: input.minimumAmount,
      maximumAmount: input.maximumAmount,
      maximumDuration: input.maximumDuration,
      gracePeriodDays: input.gracePeriodDays,
      processingFee: input.processingFee,
      isActive: input.isActive,
    );
    products = [...products, product];
    return product;
  }

  @override
  Future<void> deleteProduct({
    required String chamaId,
    required String productId,
  }) async {
    deleteCalls++;
    if (error != null) throw error!;
    products = products.where((p) => p.id != productId).toList();
  }

  @override
  Future<LoanApplication> disburseApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> getApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MemberCreditScore?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  }) async =>
      null;

  @override
  Future<LoanDashboard> getDashboard({
    required String chamaId,
    required String memberId,
    String currency = 'KES',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanProduct> getProduct({
    required String chamaId,
    required String productId,
  }) async {
    if (error != null) throw error!;
    return products.firstWhere((p) => p.id == productId);
  }

  @override
  Future<LoanRepayment> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PagedResult<LoanApplication>> listApplications({
    required String chamaId,
    String? search,
    LoanApplicationStatus? status,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedResult(items: [], count: 0);
  }

  @override
  Future<List<LoanProduct>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async {
    if (error != null) throw error!;
    var list = products;
    if (isActive != null) {
      list = list.where((p) => p.isActive == isActive).toList();
    }
    return list;
  }

  @override
  Future<PagedResult<LoanRepayment>> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedResult(items: [], count: 0);
  }

  @override
  Future<List<CommitteeVote>> listVotes({
    required String chamaId,
    required String applicationId,
  }) async =>
      [];

  @override
  Future<({LoanRepayment repayment, LoanApplication application})>
      recordRepayment({
    required String chamaId,
    required String applicationId,
    required RecordRepaymentInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> rejectApplication({
    required String chamaId,
    required String applicationId,
    String? remarks,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> submitApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanProduct> updateProduct({
    required String chamaId,
    required String productId,
    required LoanProductInput input,
  }) async {
    if (error != null) throw error!;
    final updated = LoanProduct(
      id: productId,
      chamaId: chamaId,
      name: input.name,
      description: input.description,
      interestRate: input.interestRate,
      minimumAmount: input.minimumAmount,
      maximumAmount: input.maximumAmount,
      maximumDuration: input.maximumDuration,
      gracePeriodDays: input.gracePeriodDays,
      processingFee: input.processingFee,
      isActive: input.isActive,
    );
    products = [
      for (final p in products)
        if (p.id == productId) updated else p,
    ];
    return updated;
  }
}

class _SeededProductsController extends LoanProductsController {
  _SeededProductsController(
    LoanRepository repository, {
    required List<LoanProduct> products,
  }) : super(repository: repository, chamaId: 'c1') {
    state = products.isEmpty
        ? const ApiState.empty()
        : ApiState.success(products);
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

class _SeededDetailsController extends LoanProductDetailsController {
  _SeededDetailsController(LoanProduct product)
      : super(
          repository: _FakeLoanRepository(products: [product]),
          chamaId: product.chamaId,
          productId: product.id,
        ) {
    state = ApiState.success(product);
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

List<Override> _baseOverrides({
  required AppMemberRole role,
  required LoanRepository repo,
  List<Override> extra = const [],
}) {
  return [
    loanRepositoryProvider.overrideWithValue(repo),
    currentMemberRoleProvider.overrideWith((ref) => role),
    ...extra,
  ];
}

Future<void> _fillCreateForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(8));
  await tester.enterText(fields.at(0), 'Emergency');
  await tester.enterText(fields.at(1), 'Help members');
  await tester.enterText(fields.at(2), '1000');
  await tester.enterText(fields.at(3), '20000');
  await tester.enterText(fields.at(4), '10');
  await tester.enterText(fields.at(5), '50');
  await tester.enterText(fields.at(6), '6');
  await tester.enterText(fields.at(7), '0');
}

void main() {
  testWidgets('chairperson sees create on empty products list', (tester) async {
    final repo = _FakeLoanRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.chairperson,
          repo: repo,
          extra: [
            loanProductsControllerProvider.overrideWith(
              (ref, chamaId) => _SeededProductsController(
                repo,
                products: const [],
              ),
            ),
          ],
        ),
        child: const MaterialApp(home: LoanProductsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No loan products yet'), findsOneWidget);
    expect(find.text('Create Loan Product'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('treasurer sees create on empty products list', (tester) async {
    final repo = _FakeLoanRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.treasurer,
          repo: repo,
          extra: [
            loanProductsControllerProvider.overrideWith(
              (ref, chamaId) => _SeededProductsController(
                repo,
                products: const [],
              ),
            ),
          ],
        ),
        child: const MaterialApp(home: LoanProductsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No loan products yet'), findsOneWidget);
    expect(find.text('Create Loan Product'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('member empty state has no create action', (tester) async {
    final repo = _FakeLoanRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.member,
          repo: repo,
          extra: [
            loanProductsControllerProvider.overrideWith(
              (ref, chamaId) => _SeededProductsController(
                repo,
                products: const [],
              ),
            ),
          ],
        ),
        child: const MaterialApp(home: LoanProductsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No loan products available'), findsOneWidget);
    expect(
      find.text('Your Chama has not created any loan products yet.'),
      findsOneWidget,
    );
    expect(find.text('Create Loan Product'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('chairperson sees edit and delete on product details',
      (tester) async {
    final repo = _FakeLoanRepository(products: [_sampleProduct]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.chairperson,
          repo: repo,
          extra: [
            loanProductDetailsProvider.overrideWith(
              (ref, args) => _SeededDetailsController(_sampleProduct),
            ),
          ],
        ),
        child: const MaterialApp(
          home: LoanProductDetailsScreen(chamaId: 'c1', productId: 'p1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Delete product'), findsOneWidget);
    expect(find.text('Apply for Loan'), findsOneWidget);
  });

  testWidgets('treasurer cannot edit or delete products', (tester) async {
    final repo = _FakeLoanRepository(products: [_sampleProduct]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.treasurer,
          repo: repo,
          extra: [
            loanProductDetailsProvider.overrideWith(
              (ref, args) => _SeededDetailsController(_sampleProduct),
            ),
          ],
        ),
        child: const MaterialApp(
          home: LoanProductDetailsScreen(chamaId: 'c1', productId: 'p1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit product'), findsNothing);
    expect(find.text('Delete product'), findsNothing);
    expect(find.text('Apply for Loan'), findsOneWidget);
  });

  testWidgets('member cannot see management actions', (tester) async {
    final repo = _FakeLoanRepository(products: [_sampleProduct]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.member,
          repo: repo,
          extra: [
            loanProductDetailsProvider.overrideWith(
              (ref, args) => _SeededDetailsController(_sampleProduct),
            ),
          ],
        ),
        child: const MaterialApp(
          home: LoanProductDetailsScreen(chamaId: 'c1', productId: 'p1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit product'), findsNothing);
    expect(find.text('Delete product'), findsNothing);
    expect(find.text('Management'), findsNothing);
  });

  testWidgets('create product validates required fields', (tester) async {
    final repo = _FakeLoanRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: CreateLoanProductScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create product'));
    await tester.tap(find.text('Create product'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(repo.createCalls, 0);
  });

  testWidgets('create product success calls repository and returns to list',
      (tester) async {
    final repo = _FakeLoanRepository();
    final router = GoRouter(
      initialLocation: RoutePaths.createLoanProduct('c1'),
      routes: [
        GoRoute(
          path: '/chamas/:chamaId/loans/products/create',
          builder: (_, __) => const CreateLoanProductScreen(chamaId: 'c1'),
        ),
        GoRoute(
          path: '/chamas/:chamaId/loans/products',
          builder: (_, __) => const Scaffold(body: Text('Products list')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await _fillCreateForm(tester);
    await tester.ensureVisible(find.text('Create product'));
    await tester.tap(find.text('Create product'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(repo.products.first.name, 'Emergency');
    expect(find.text('Products list'), findsOneWidget);
  });

  testWidgets('create product surfaces API errors', (tester) async {
    final repo = _FakeLoanRepository(
      error: const ServerException(message: 'Not allowed'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: CreateLoanProductScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();

    await _fillCreateForm(tester);
    await tester.ensureVisible(find.text('Create product'));
    await tester.tap(find.text('Create product'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(find.textContaining('Not allowed'), findsWidgets);
  });

  testWidgets('delete product confirmation removes product', (tester) async {
    final repo = _FakeLoanRepository(products: [_sampleProduct]);
    final router = GoRouter(
      initialLocation: RoutePaths.loanProductDetails('c1', 'p1'),
      routes: [
        GoRoute(
          path: '/chamas/:chamaId/loans/products/:productId',
          builder: (_, __) => const LoanProductDetailsScreen(
            chamaId: 'c1',
            productId: 'p1',
          ),
        ),
        GoRoute(
          path: '/chamas/:chamaId/loans/products',
          builder: (_, __) => const Scaffold(body: Text('Products list')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          role: AppMemberRole.chairperson,
          repo: repo,
          extra: [
            loanProductDetailsProvider.overrideWith(
              (ref, args) => _SeededDetailsController(_sampleProduct),
            ),
          ],
        ),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete product'));
    await tester.tap(find.text('Delete product'));
    await tester.pumpAndSettle();

    expect(find.text('Delete loan product?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.deleteCalls, 1);
    expect(repo.products, isEmpty);
    expect(find.text('Products list'), findsOneWidget);
  });

  test('AppMemberRole loan product permissions', () {
    expect(AppMemberRole.chairperson.canCreateLoanProduct, isTrue);
    expect(AppMemberRole.chairperson.canManageLoanProducts, isTrue);
    expect(AppMemberRole.treasurer.canCreateLoanProduct, isTrue);
    expect(AppMemberRole.treasurer.canManageLoanProducts, isFalse);
    expect(AppMemberRole.member.canCreateLoanProduct, isFalse);
    expect(AppMemberRole.member.canManageLoanProducts, isFalse);
  });
}
