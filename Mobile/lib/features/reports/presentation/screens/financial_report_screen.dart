import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/charts/charts.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/reports/reports.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../utils/report_formatters.dart';

/// Full chama financial overview.
class FinancialReportScreen extends ConsumerWidget {
  const FinancialReportScreen({super.key, required this.chamaId});

  final String chamaId;

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    FinancialReport report,
  ) async {
    await runReportExportFlow(
      context,
      ref,
      buildRequest: (format) => ReportExportRequest(
        title: 'Financial report',
        subtitle: 'Chama overview',
        fileName: 'financial_report',
        format: format,
        summary: ReportExportBuilders.financialSummary(report),
        columns: const [
          ReportColumn(key: 'metric', label: 'Metric'),
          ReportColumn(key: 'value', label: 'Value'),
        ],
        rows: ReportExportBuilders.financialSummary(report)
            .entries
            .map((e) => {'metric': e.key, 'value': e.value})
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financialReportProvider(chamaId));
    final controller = ref.read(financialReportProvider(chamaId).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial report')),
      body: ApiStateBuilder<FinancialReport>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, report) {
          final loanBars = [
            ChartPoint(
              label: 'Pend',
              value: report.loans.pending.toDouble(),
            ),
            ChartPoint(
              label: 'Appr',
              value: report.loans.approved.toDouble(),
            ),
            ChartPoint(
              label: 'Disb',
              value: report.loans.disbursed.toDouble(),
            ),
            ChartPoint(
              label: 'Repaid',
              value: report.loans.repaid.toDouble(),
            ),
          ];
          final cashflow = [
            ChartPoint(
              label: 'In',
              value: report.contributions.totalAmount +
                  report.repayments.totalAmount,
              color: theme.colorScheme.primary,
            ),
            ChartPoint(
              label: 'Out',
              value: report.loans.outstandingBalance,
              color: theme.colorScheme.error,
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final tiles = [
                    SummaryMetricTile(
                      title: 'Members',
                      value: '${report.memberCount}',
                      icon: Icons.groups_outlined,
                    ),
                    SummaryMetricTile(
                      title: 'Active cycles',
                      value: '${report.activeCycles}',
                      icon: Icons.loop,
                    ),
                    SummaryMetricTile(
                      title: 'Contributions',
                      value: ReportFormatters.money(
                        report.contributions.totalAmount,
                        currency: report.contributions.currency,
                      ),
                      icon: Icons.payments_outlined,
                    ),
                    SummaryMetricTile(
                      title: 'Credit / loans out',
                      value: ReportFormatters.money(
                        report.loans.outstandingBalance,
                      ),
                      icon: Icons.account_balance_outlined,
                      accentColor: theme.colorScheme.secondary,
                    ),
                  ];
                  if (constraints.maxWidth > 600) {
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: tiles
                          .map(
                            (t) => SizedBox(
                              width: (constraints.maxWidth - AppSpacing.sm) / 2,
                              child: t,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Column(
                    children: [
                      for (final t in tiles) ...[
                        t,
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Loan pipeline',
                subtitle: 'Applications by status',
                isEmpty: loanBars.every((p) => p.value <= 0),
                child: AppBarChart(points: loanBars),
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Cashflow snapshot',
                subtitle: 'Inflows vs outstanding credit',
                isEmpty: cashflow.every((p) => p.value <= 0),
                legend: [
                  ChartLegendItem(
                    label: 'Inflows',
                    color: theme.colorScheme.primary,
                  ),
                  ChartLegendItem(
                    label: 'Outstanding',
                    color: theme.colorScheme.error,
                  ),
                ],
                child: AppPieChart(points: cashflow),
              ),
              const SizedBox(height: AppSpacing.md),
              ExportButton(
                expand: true,
                onPressed: () => _export(context, ref, report),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
