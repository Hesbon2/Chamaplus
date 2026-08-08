import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/loans/data/datasources/loan_api.dart';
import 'package:chamaplus_mobile/features/loans/data/dtos/loan_dtos.dart';
import 'package:chamaplus_mobile/features/loans/data/repositories/loan_repository_impl.dart';
import 'package:chamaplus_mobile/features/loans/domain/entities/loan.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLoanApi implements LoanRemoteDataSource {
  List<LoanProductDto> products = [];
  LoanApplicationsPageDto applicationsPage = const LoanApplicationsPageDto(
    count: 0,
    results: [],
  );
  Object? error;

  @override
  Future<LoanApplicationDto> apply({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    if (error != null) throw error!;
    return LoanApplicationDto(
      id: 'app-1',
      applicantId: 'user-1',
      chamaId: chamaId,
      loanProductId: '${body['loan_product_id']}',
      requestedAmount: '${body['requested_amount']}',
      requestedDuration: body['requested_duration'] as int,
      purpose: body['purpose'] as String,
      status: body['submit'] == true ? 'pending' : 'draft',
    );
  }

  @override
  Future<LoanApplicationDto> approveApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationDto> cancelApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> castVote({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationDto> disburseApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationDto> getApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final matches =
        applicationsPage.results.where((a) => a.id == applicationId).toList();
    if (matches.isEmpty) {
      throw const ServerException(message: 'Not found');
    }
    return matches.first;
  }

  @override
  Future<CreditScoreDto?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  }) async =>
      null;

  @override
  Future<LoanProductDto> getProduct({
    required String chamaId,
    required String productId,
  }) async {
    return products.firstWhere((p) => p.id == productId);
  }

  Map<String, dynamic>? lastProductBody;

  @override
  Future<LoanProductDto> createProduct({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    if (error != null) throw error!;
    lastProductBody = body;
    final dto = LoanProductDto(
      id: 'p-created',
      chamaId: chamaId,
      name: body['name'] as String,
      description: body['description'] as String?,
      interestRate: '${body['interest_rate']}',
      minimumAmount: '${body['minimum_amount']}',
      maximumAmount: '${body['maximum_amount']}',
      maximumDuration: body['maximum_duration'] as int,
      gracePeriodDays: body['grace_period_days'] as int? ?? 0,
      processingFee: '${body['processing_fee'] ?? '0'}',
      isActive: body['is_active'] as bool? ?? true,
    );
    products = [...products, dto];
    return dto;
  }

  @override
  Future<LoanProductDto> updateProduct({
    required String chamaId,
    required String productId,
    required Map<String, dynamic> body,
  }) async {
    if (error != null) throw error!;
    lastProductBody = body;
    final existing = products.firstWhere((p) => p.id == productId);
    final dto = LoanProductDto(
      id: productId,
      chamaId: chamaId,
      name: body['name'] as String? ?? existing.name,
      description: body['description'] as String? ?? existing.description,
      interestRate: '${body['interest_rate'] ?? existing.interestRate}',
      minimumAmount: '${body['minimum_amount'] ?? existing.minimumAmount}',
      maximumAmount: '${body['maximum_amount'] ?? existing.maximumAmount}',
      maximumDuration:
          body['maximum_duration'] as int? ?? existing.maximumDuration,
      gracePeriodDays:
          body['grace_period_days'] as int? ?? existing.gracePeriodDays,
      processingFee: '${body['processing_fee'] ?? existing.processingFee}',
      isActive: body['is_active'] as bool? ?? existing.isActive,
    );
    products = [
      for (final p in products)
        if (p.id == productId) dto else p,
    ];
    return dto;
  }

  @override
  Future<void> deleteProduct({
    required String chamaId,
    required String productId,
  }) async {
    if (error != null) throw error!;
    products = products.where((p) => p.id != productId).toList();
  }

  @override
  Future<LoanRepaymentDto> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationsPageDto> listApplications({
    required String chamaId,
    String? search,
    String? status,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (error != null) throw error!;
    return applicationsPage;
  }

  @override
  Future<List<LoanProductDto>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async {
    if (error != null) throw error!;
    var list = products;
    if (isActive != null) {
      list = list.where((p) => p.isActive == isActive).toList();
    }
    if (search != null && search.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Future<LoanRepaymentsPageDto> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const LoanRepaymentsPageDto(count: 0, results: []);
  }

  @override
  Future<List<CommitteeVoteDto>> listVotes({
    required String chamaId,
    required String applicationId,
  }) async =>
      [];

  @override
  Future<Map<String, dynamic>> recordRepayment({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationDto> rejectApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplicationDto> submitApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeLoanApi api;
  late LoanRepositoryImpl repository;

  setUp(() {
    api = FakeLoanApi();
    repository = LoanRepositoryImpl(api);
  });

  test('listProducts maps DTOs to entities', () async {
    api.products = [
      const LoanProductDto(
        id: 'p1',
        chamaId: 'c1',
        name: 'Emergency',
        interestRate: '12.00',
        minimumAmount: '1000',
        maximumAmount: '50000',
        maximumDuration: 12,
        gracePeriodDays: 7,
        processingFee: '100',
        isActive: true,
      ),
    ];

    final products = await repository.listProducts(chamaId: 'c1');
    expect(products, hasLength(1));
    expect(products.first.name, 'Emergency');
    expect(products.first.interestRate, 12);
    expect(products.first.maximumAmount, 50000);
  });

  test('createProduct posts snake_case body', () async {
    final product = await repository.createProduct(
      chamaId: 'c1',
      input: const LoanProductInput(
        name: 'Emergency',
        description: 'Short term',
        interestRate: 12,
        minimumAmount: 1000,
        maximumAmount: 50000,
        maximumDuration: 12,
        gracePeriodDays: 7,
        processingFee: 100,
        isActive: true,
      ),
    );

    expect(product.id, 'p-created');
    expect(product.name, 'Emergency');
    expect(api.lastProductBody?['interest_rate'], '12.00');
    expect(api.lastProductBody?['minimum_amount'], '1000.00');
    expect(api.lastProductBody?['is_active'], isTrue);
  });

  test('updateProduct patches product fields', () async {
    api.products = [
      const LoanProductDto(
        id: 'p1',
        chamaId: 'c1',
        name: 'Emergency',
        interestRate: '12.00',
        minimumAmount: '1000',
        maximumAmount: '50000',
        maximumDuration: 12,
        gracePeriodDays: 7,
        processingFee: '100',
        isActive: true,
      ),
    ];

    final product = await repository.updateProduct(
      chamaId: 'c1',
      productId: 'p1',
      input: const LoanProductInput(
        name: 'Emergency Plus',
        interestRate: 14,
        minimumAmount: 2000,
        maximumAmount: 60000,
        maximumDuration: 18,
        isActive: false,
      ),
    );

    expect(product.name, 'Emergency Plus');
    expect(product.isActive, isFalse);
    expect(api.lastProductBody?['name'], 'Emergency Plus');
  });

  test('deleteProduct removes product', () async {
    api.products = [
      const LoanProductDto(
        id: 'p1',
        chamaId: 'c1',
        name: 'Emergency',
        interestRate: '12.00',
        minimumAmount: '1000',
        maximumAmount: '50000',
        maximumDuration: 12,
        gracePeriodDays: 0,
        processingFee: '0',
        isActive: true,
      ),
    ];

    await repository.deleteProduct(chamaId: 'c1', productId: 'p1');
    expect(api.products, isEmpty);
  });

  test('apply submits snake_case body and returns pending app', () async {
    final app = await repository.apply(
      chamaId: 'c1',
      input: const ApplyLoanInput(
        loanProductId: 'p1',
        requestedAmount: 10000,
        requestedDuration: 6,
        purpose: 'School fees',
        submit: true,
      ),
    );

    expect(app.status, LoanApplicationStatus.pending);
    expect(app.requestedAmount, 10000);
    expect(app.purpose, 'School fees');
  });

  test('getDashboard picks active loan and loan limit', () async {
    api.products = [
      const LoanProductDto(
        id: 'p1',
        chamaId: 'c1',
        name: 'Emergency',
        interestRate: '10.00',
        minimumAmount: '1000',
        maximumAmount: '40000',
        maximumDuration: 6,
        gracePeriodDays: 0,
        processingFee: '0',
        isActive: true,
      ),
    ];
    api.applicationsPage = LoanApplicationsPageDto(
      count: 1,
      results: [
        const LoanApplicationDto(
          id: 'a1',
          applicantId: 'u1',
          chamaId: 'c1',
          loanProductId: 'p1',
          requestedAmount: '20000',
          requestedDuration: 6,
          purpose: 'Business',
          status: 'disbursed',
          approvedAmount: '20000',
          outstandingBalance: '12000',
        ),
      ],
    );

    final dashboard = await repository.getDashboard(
      chamaId: 'c1',
      memberId: 'u1',
    );

    expect(dashboard.activeLoan?.id, 'a1');
    expect(dashboard.loanLimit, 40000);
    expect(dashboard.outstandingBalance, 12000);
    expect(dashboard.nextInstallmentEstimate, isNotNull);
  });

  test('LoanCalculation.flat computes monthly repayment', () {
    final calc = LoanCalculation.flat(
      principal: 12000,
      durationMonths: 12,
      annualInterestRate: 10,
    );
    expect(calc.totalInterest, 1200);
    expect(calc.totalRepayment, 13200);
    expect(calc.monthlyRepayment, 1100);
  });
}
