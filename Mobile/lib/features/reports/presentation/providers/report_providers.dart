import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../contributions/presentation/providers/contribution_providers.dart';
import '../../../meetings/domain/entities/meeting.dart';
import '../../../meetings/presentation/providers/meeting_providers.dart';
import '../../data/datasources/report_api.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../controllers/report_controllers.dart';

final reportApiProvider = Provider<ReportApi>((ref) {
  return ReportApi(ref.watch(apiClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final meetings = ref.watch(meetingRepositoryProvider);
  final contributions = ref.watch(contributionRepositoryProvider);
  final api = ref.watch(reportApiProvider);

  return ReportRepositoryImpl(
    api,
    attendanceLoader: (chamaId) async {
      final list = await meetings.listMeetings(chamaId: chamaId);
      final counts = <String, int>{
        for (final status in MeetingStatus.values)
          if (status != MeetingStatus.unknown) status.label: 0,
      };
      for (final m in list) {
        if (m.status == MeetingStatus.unknown) continue;
        counts[m.status.label] = (counts[m.status.label] ?? 0) + 1;
      }
      return counts;
    },
    statementLinesLoader: (chamaId, memberId) async {
      final page = await contributions.listContributions(
        chamaId: chamaId,
        memberId: memberId,
        page: 1,
        pageSize: 50,
      );
      return page.items
          .map(
            (c) => MemberStatementLine(
              date: c.recordedAt,
              label: c.reference.isNotEmpty
                  ? c.reference
                  : 'Contribution',
              amount: double.tryParse(c.amount) ?? 0,
              category: 'Contribution',
            ),
          )
          .toList();
    },
    creditScoreLoader: (chamaId) async {
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null || userId.isEmpty) return null;
      try {
        final dto = await api.getMemberFinancialReport(
          chamaId: chamaId,
          memberId: userId,
        );
        return dto.toEntity().creditScore;
      } catch (_) {
        return null;
      }
    },
  );
});

final reportsHomeProvider = StateNotifierProvider.autoDispose
    .family<ReportsHomeController, ApiState<ReportsHomeData>, String>(
        (ref, chamaId) {
  final controller = ReportsHomeController(
    repository: ref.watch(reportRepositoryProvider),
    chamaId: chamaId,
  );
  Future.microtask(controller.load);
  return controller;
});

final monthlyReportProvider = StateNotifierProvider.autoDispose.family<
    MonthlyReportController,
    ApiState<MonthlyReport>,
    ({String chamaId, int year, int month})>((ref, args) {
  final controller = MonthlyReportController(
    repository: ref.watch(reportRepositoryProvider),
    chamaId: args.chamaId,
    year: args.year,
    month: args.month,
  );
  Future.microtask(controller.load);
  return controller;
});

final financialReportProvider = StateNotifierProvider.autoDispose
    .family<FinancialReportController, ApiState<FinancialReport>, String>(
        (ref, chamaId) {
  final controller = FinancialReportController(
    repository: ref.watch(reportRepositoryProvider),
    chamaId: chamaId,
  );
  Future.microtask(controller.load);
  return controller;
});

final memberStatementProvider = StateNotifierProvider.autoDispose.family<
    MemberStatementController,
    ApiState<MemberStatement>,
    ({String chamaId, String memberId})>((ref, args) {
  final controller = MemberStatementController(
    repository: ref.watch(reportRepositoryProvider),
    chamaId: args.chamaId,
    memberId: args.memberId,
  );
  Future.microtask(controller.load);
  return controller;
});

final defaultersReportProvider = StateNotifierProvider.autoDispose
    .family<DefaultersReportController, ApiState<DefaultersReport>, String>(
        (ref, chamaId) {
  final controller = DefaultersReportController(
    repository: ref.watch(reportRepositoryProvider),
    chamaId: chamaId,
  );
  Future.microtask(controller.load);
  return controller;
});

/// Resolves current user id for "my statement" when memberId is omitted.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).user?.id;
});
