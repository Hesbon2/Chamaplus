import 'package:intl/intl.dart';

import '../../domain/entities/report.dart';

class ReportFormatters {
  ReportFormatters._();

  static String money(double value, {String currency = 'KES'}) {
    final formatted = NumberFormat('#,##0.00').format(value);
    return '$currency $formatted';
  }

  static String monthYear(int year, int month) {
    return DateFormat.yMMMM().format(DateTime(year, month));
  }
}

/// Builds [ReportExportRequest]-ready maps from report entities.
class ReportExportBuilders {
  ReportExportBuilders._();

  static Map<String, String> monthlySummary(MonthlyReport report) => {
        'Period': report.periodLabel,
        'Contributions': ReportFormatters.money(
          report.contributions.totalAmount,
          currency: report.contributions.currency,
        ),
        'Contribution count': '${report.contributions.totalCount}',
        'Loan applications': '${report.loans.totalApplications}',
        'Outstanding loans': ReportFormatters.money(
          report.loans.outstandingBalance,
        ),
        'Repayments': ReportFormatters.money(
          report.repayments.totalAmount,
          currency: report.repayments.currency,
        ),
      };

  static Map<String, String> financialSummary(FinancialReport report) => {
        'Members': '${report.memberCount}',
        'Active cycles': '${report.activeCycles}',
        'Contributions': ReportFormatters.money(
          report.contributions.totalAmount,
          currency: report.contributions.currency,
        ),
        'Outstanding loans': ReportFormatters.money(
          report.loans.outstandingBalance,
        ),
        'Repayments': ReportFormatters.money(
          report.repayments.totalAmount,
          currency: report.repayments.currency,
        ),
      };

  static Map<String, String> memberSummary(MemberStatement statement) => {
        'Member': statement.memberId,
        'Contributions': ReportFormatters.money(
          statement.contributionsTotal,
          currency: statement.currency,
        ),
        'Contribution count': '${statement.contributionsCount}',
        'Active loans': '${statement.activeLoans}',
        'Repayments': ReportFormatters.money(
          statement.repaymentsTotal,
          currency: statement.currency,
        ),
        if (statement.creditScore != null)
          'Credit score': '${statement.creditScore}',
        if (statement.creditRiskLevel != null)
          'Risk level': statement.creditRiskLevel!,
      };

  static List<Map<String, String>> memberLines(MemberStatement statement) {
    return statement.lineItems
        .map(
          (line) => {
            'date': DateFormat.yMMMd().format(line.date.toLocal()),
            'label': line.label,
            'category': line.category,
            'amount': ReportFormatters.money(
              line.amount,
              currency: statement.currency,
            ),
          },
        )
        .toList();
  }

  static Map<String, String> defaultersSummary(DefaultersReport report) => {
        'Currency': report.currency,
        'Contribution defaulters': '${report.contributionDefaultersCount}',
        'Loan defaulters': '${report.loanDefaultersCount}',
        'Total': '${report.totalCount}',
      };

  static List<Map<String, String>> defaultersRows(DefaultersReport report) {
    return report.defaulters
        .map(
          (row) => {
            'name': row.fullName,
            'phone': row.phoneNumber,
            'role': row.role ?? '',
            'type': row.type.label,
            'detail': row.type == DefaulterType.contribution
                ? '${row.cycleName ?? 'Cycle'} · '
                    '${ReportFormatters.money(
                      row.expectedAmount ?? 0,
                      currency: report.currency,
                    )}'
                : 'Outstanding ${ReportFormatters.money(
                      row.outstandingBalance ?? 0,
                      currency: report.currency,
                    )}'
                    '${row.dueDate != null ? ' · due ${DateFormat.yMMMd().format(row.dueDate!.toLocal())}' : ''}',
          },
        )
        .toList();
  }
}
