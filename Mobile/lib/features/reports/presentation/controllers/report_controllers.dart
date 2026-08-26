import '../../../../shared/api_state.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

class ReportsHomeController extends RefreshController<ReportsHomeData> {
  ReportsHomeController({
    required ReportRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ReportRepository _repository;
  final String _chamaId;

  @override
  Future<ReportsHomeData> fetchData({bool forceRefresh = false}) {
    return _repository.getReportsHome(chamaId: _chamaId);
  }
}

class MonthlyReportController extends RefreshController<MonthlyReport> {
  MonthlyReportController({
    required ReportRepository repository,
    required String chamaId,
    int? year,
    int? month,
  })  : _repository = repository,
        _chamaId = chamaId,
        year = year ?? DateTime.now().year,
        month = month ?? DateTime.now().month;

  final ReportRepository _repository;
  final String _chamaId;
  int year;
  int month;

  @override
  Future<MonthlyReport> fetchData({bool forceRefresh = false}) {
    return _repository.getMonthlyReport(
      chamaId: _chamaId,
      year: year,
      month: month,
    );
  }

  Future<void> setPeriod({required int year, required int month}) async {
    this.year = year;
    this.month = month;
    await load(forceRefresh: true);
  }
}

class FinancialReportController extends RefreshController<FinancialReport> {
  FinancialReportController({
    required ReportRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ReportRepository _repository;
  final String _chamaId;

  @override
  Future<FinancialReport> fetchData({bool forceRefresh = false}) {
    return _repository.getFinancialReport(chamaId: _chamaId);
  }
}

class MemberStatementController extends RefreshController<MemberStatement> {
  MemberStatementController({
    required ReportRepository repository,
    required String chamaId,
    required String memberId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _memberId = memberId;

  final ReportRepository _repository;
  final String _chamaId;
  final String _memberId;

  @override
  Future<MemberStatement> fetchData({bool forceRefresh = false}) {
    return _repository.getMemberStatement(
      chamaId: _chamaId,
      memberId: _memberId,
    );
  }
}

class DefaultersReportController extends RefreshController<DefaultersReport> {
  DefaultersReportController({
    required ReportRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ReportRepository _repository;
  final String _chamaId;
  String type = 'all';
  String? cycleId;

  @override
  Future<DefaultersReport> fetchData({bool forceRefresh = false}) {
    return _repository.getDefaultersReport(
      chamaId: _chamaId,
      cycleId: cycleId,
      type: type,
    );
  }

  Future<void> setType(String value) async {
    type = value;
    await load(forceRefresh: true);
  }

  @override
  bool isEmptyData(DefaultersReport data) => false;
}

class MonthlyTrendController extends RefreshController<List<MonthlyReport>> {
  MonthlyTrendController({
    required ReportRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final ReportRepository _repository;
  final String _chamaId;

  @override
  Future<List<MonthlyReport>> fetchData({bool forceRefresh = false}) {
    return _repository.getMonthlyTrend(chamaId: _chamaId);
  }

  @override
  bool isEmptyData(List<MonthlyReport> data) => data.isEmpty;
}
