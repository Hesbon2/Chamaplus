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

/// Monthly contributions / loans / repayments report.
class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  ({String chamaId, int year, int month}) get _args =>
      (chamaId: widget.chamaId, year: _year, month: _month);

  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_year, _month, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select month',
    );
    if (picked == null) return;
    setState(() {
      _year = picked.year;
      _month = picked.month;
    });
  }

  Future<void> _export(MonthlyReport report) async {
    await runReportExportFlow(
      context,
      ref,
      buildRequest: (format) => ReportExportRequest(
        title: 'Monthly report — ${report.periodLabel}',
        subtitle: 'Chama analytics',
        fileName: 'monthly_${report.year}_${report.month}',
        format: format,
        summary: ReportExportBuilders.monthlySummary(report),
        columns: const [
          ReportColumn(key: 'metric', label: 'Metric'),
          ReportColumn(key: 'value', label: 'Value'),
        ],
        rows: ReportExportBuilders.monthlySummary(report)
            .entries
            .map((e) => {'metric': e.key, 'value': e.value})
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monthlyReportProvider(_args));
    final controller = ref.read(monthlyReportProvider(_args).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly report'),
        actions: [
          IconButton(
            tooltip: 'Change month',
            onPressed: _pickPeriod,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: ApiStateBuilder<MonthlyReport>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, report) {
          final mix = [
            ChartPoint(
              label: 'Contributions',
              value: report.contributions.totalAmount,
              color: theme.colorScheme.primary,
            ),
            ChartPoint(
              label: 'Repayments',
              value: report.repayments.totalAmount,
              color: theme.colorScheme.tertiary,
            ),
            ChartPoint(
              label: 'Outstanding',
              value: report.loans.outstandingBalance,
              color: theme.colorScheme.secondary,
            ),
          ].where((p) => p.value > 0).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                ReportFormatters.monthYear(report.year, report.month),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SummaryMetricTile(
                title: 'Contributions',
                value: ReportFormatters.money(
                  report.contributions.totalAmount,
                  currency: report.contributions.currency,
                ),
                icon: Icons.payments_outlined,
                subtitle: '${report.contributions.totalCount} payments',
              ),
              const SizedBox(height: AppSpacing.sm),
              SummaryMetricTile(
                title: 'Outstanding loans',
                value: ReportFormatters.money(report.loans.outstandingBalance),
                icon: Icons.account_balance_wallet_outlined,
                subtitle:
                    '${report.loans.totalApplications} applications this month',
              ),
              const SizedBox(height: AppSpacing.sm),
              SummaryMetricTile(
                title: 'Repayments',
                value: ReportFormatters.money(
                  report.repayments.totalAmount,
                  currency: report.repayments.currency,
                ),
                icon: Icons.savings_outlined,
                subtitle: '${report.repayments.totalCount} repayments',
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Month mix',
                isEmpty: mix.isEmpty,
                legend: mix
                    .map(
                      (p) => ChartLegendItem(
                        label: p.label,
                        color: p.color ?? theme.colorScheme.primary,
                      ),
                    )
                    .toList(),
                child: AppPieChart(points: mix),
              ),
              const SizedBox(height: AppSpacing.md),
              ExportButton(
                expand: true,
                onPressed: () => _export(report),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
