import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/report_dtos.dart';

/// Remote chama reports API.
abstract class ReportRemoteDataSource {
  Future<MonthlyReportDto> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  });

  Future<ContributionTotalsDto> getContributionsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
    String? cycleId,
  });

  Future<LoanTotalsDto> getLoansReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  });

  Future<RepaymentTotalsDto> getRepaymentsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  });

  Future<FinancialReportDto> getFinancialReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  });

  Future<MemberStatementDto> getMemberFinancialReport({
    required String chamaId,
    required String memberId,
  });
}

class ReportApi implements ReportRemoteDataSource {
  ReportApi(this._apiClient);

  final ApiClient _apiClient;

  String? _date(DateTime? d) {
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Future<MonthlyReportDto> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMonthlyReport(chamaId),
      queryParameters: {'year': year, 'month': month},
    );
    return MonthlyReportDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionTotalsDto> getContributionsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
    String? cycleId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributionsReport(chamaId),
      queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (cycleId != null) 'cycle_id': cycleId,
      },
    );
    return ContributionTotalsDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanTotalsDto> getLoansReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaLoansReport(chamaId),
      queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    return LoanTotalsDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<RepaymentTotalsDto> getRepaymentsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaRepaymentsReport(chamaId),
      queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    return RepaymentTotalsDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<FinancialReportDto> getFinancialReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaFinancialReport(chamaId),
      queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    return FinancialReportDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MemberStatementDto> getMemberFinancialReport({
    required String chamaId,
    required String memberId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.memberFinancialReport(chamaId, memberId),
    );
    return MemberStatementDto.fromJson(_unwrapMap(response.data));
  }

  /// Helper for callers that already have DateTime filters.
  Map<String, String> dateQuery({DateTime? dateFrom, DateTime? dateTo}) => {
        if (_date(dateFrom) != null) 'date_from': _date(dateFrom)!,
        if (_date(dateTo) != null) 'date_to': _date(dateTo)!,
      };

  Map<String, dynamic> _unwrapMap(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!;
  }
}
