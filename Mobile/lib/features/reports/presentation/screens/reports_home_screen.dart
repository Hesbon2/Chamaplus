import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/charts/charts.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/reports/reports.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../utils/report_formatters.dart';

/// Reports home: KPIs, chart suite, and navigation to detail reports.
class ReportsHomeScreen extends ConsumerWidget {
  const ReportsHomeScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsHomeProvider(chamaId));
    final controller = ref.read(reportsHomeProvider(chamaId).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & analytics'),
        actions: [
          IconButton(
            tooltip: 'Export center',
            onPressed: () =>
                context.push(RoutePaths.exportCenter(chamaId)),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ApiStateBuilder<ReportsHomeData>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 6,
        builder: (context, data) {
          final financial = data.financial;
          final monthly = data.analytics.monthly;
          final contribPoints = monthly
              .map(
                (m) => ChartPoint(
                  label: m.periodLabel.split(' ').first,
                  value: m.contributions.totalAmount,
                ),
              )
              .toList();
          final loanPoints = monthly
              .map(
                (m) => ChartPoint(
                  label: m.periodLabel.split(' ').first,
                  value: m.loans.outstandingBalance,
                ),
              )
              .toList();
          final repaymentPoints = monthly
              .map(
                (m) => ChartPoint(
                  label: m.periodLabel.split(' ').first,
                  value: m.repayments.totalAmount,
                ),
              )
              .toList();
          final loanPie = [
            ChartPoint(
              label: 'Pending',
              value: financial.loans.pending.toDouble(),
              color: theme.colorScheme.secondary,
            ),
            ChartPoint(
              label: 'Approved',
              value: financial.loans.approved.toDouble(),
              color: theme.colorScheme.tertiary,
            ),
            ChartPoint(
              label: 'Disbursed',
              value: financial.loans.disbursed.toDouble(),
              color: theme.colorScheme.primary,
            ),
            ChartPoint(
              label: 'Repaid',
              value: financial.loans.repaid.toDouble(),
              color: theme.colorScheme.outline,
            ),
          ].where((p) => p.value > 0).toList();
          final attendancePoints = data.analytics.attendanceByStatus.entries
              .map(
                (e) => ChartPoint(
                  label: e.key,
                  value: e.value.toDouble(),
                ),
              )
              .where((p) => p.value > 0)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final tiles = [
                    SummaryMetricTile(
                      title: 'Contributions',
                      value: ReportFormatters.money(
                        financial.contributions.totalAmount,
                        currency: financial.contributions.currency,
                      ),
                      icon: Icons.payments_outlined,
                      subtitle:
                          '${financial.contributions.totalCount} payments',
                      onTap: () => context.push(
                        RoutePaths.financialReport(chamaId),
                      ),
                    ),
                    SummaryMetricTile(
                      title: 'Outstanding loans',
                      value: ReportFormatters.money(
                        financial.loans.outstandingBalance,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: theme.colorScheme.secondary,
                      subtitle:
                          '${financial.loans.disbursed} disbursed',
                    ),
                    SummaryMetricTile(
                      title: 'Members',
                      value: '${financial.memberCount}',
                      icon: Icons.groups_outlined,
                      subtitle:
                          '${financial.activeCycles} active cycle(s)',
                    ),
                    SummaryMetricTile(
                      title: 'Repayments',
                      value: ReportFormatters.money(
                        financial.repayments.totalAmount,
                        currency: financial.repayments.currency,
                      ),
                      icon: Icons.savings_outlined,
                      subtitle:
                          '${financial.repayments.totalCount} recorded',
                    ),
                  ];
                  if (constraints.maxWidth > 700) {
                    return Row(
                      children: [
                        for (var i = 0; i < tiles.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(child: tiles[i]),
                        ],
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < tiles.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm),
                        tiles[i],
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Report library'),
              const SizedBox(height: AppSpacing.sm),
              ReportCard(
                title: 'Monthly report',
                subtitle: 'Contributions, loans & repayments by month',
                icon: Icons.calendar_month_outlined,
                onTap: () =>
                    context.push(RoutePaths.monthlyReport(chamaId)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ReportCard(
                title: 'Financial report',
                subtitle: 'Full chama financial overview',
                icon: Icons.account_balance_outlined,
                onTap: () =>
                    context.push(RoutePaths.financialReport(chamaId)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ReportCard(
                title: 'Defaulters report',
                subtitle: 'Missed contributions & overdue loans',
                icon: Icons.warning_amber_outlined,
                onTap: () =>
                    context.push(RoutePaths.defaultersReport(chamaId)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ReportCard(
                title: 'Member statement',
                subtitle: 'Personal contributions, loans & credit',
                icon: Icons.receipt_long_outlined,
                onTap: () =>
                    context.push(RoutePaths.memberStatement(chamaId)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ReportCard(
                title: 'Export center',
                subtitle: 'PDF / CSV share & download',
                icon: Icons.share_outlined,
                badgeLabel: 'PDF · CSV',
                onTap: () =>
                    context.push(RoutePaths.exportCenter(chamaId)),
              ),
              const SizedBox(height: AppSpacing.lg),
              ChartCard(
                title: 'Monthly contributions',
                subtitle: 'Last 6 months',
                isEmpty: contribPoints.every((p) => p.value <= 0),
                legend: [
                  ChartLegendItem(
                    label: 'Contributions',
                    color: theme.colorScheme.primary,
                  ),
                ],
                child: AppBarChart(
                  points: contribPoints,
                  valueFormatter: (v) => ReportFormatters.money(v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Loan outstanding',
                subtitle: 'Monthly trend',
                isEmpty: loanPoints.every((p) => p.value <= 0),
                legend: [
                  ChartLegendItem(
                    label: 'Outstanding',
                    color: theme.colorScheme.secondary,
                  ),
                ],
                child: AppAreaChart(
                  points: loanPoints,
                  lineColor: theme.colorScheme.secondary,
                  valueFormatter: (v) => ReportFormatters.money(v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Repayments',
                subtitle: 'Monthly collections',
                isEmpty: repaymentPoints.every((p) => p.value <= 0),
                child: AppLineChart(
                  points: repaymentPoints,
                  lineColor: theme.colorScheme.tertiary,
                  valueFormatter: (v) => ReportFormatters.money(v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Loan portfolio mix',
                subtitle: 'By application status',
                isEmpty: loanPie.isEmpty,
                legend: loanPie
                    .map(
                      (p) => ChartLegendItem(
                        label: p.label,
                        color: p.color ?? theme.colorScheme.primary,
                        valueLabel: '${p.value.toInt()}',
                      ),
                    )
                    .toList(),
                child: AppPieChart(points: loanPie),
              ),
              const SizedBox(height: AppSpacing.md),
              ChartCard(
                title: 'Meeting attendance pulse',
                subtitle: 'Meetings by status',
                isEmpty: attendancePoints.isEmpty,
                emptyMessage: 'Schedule meetings to see attendance analytics.',
                legend: attendancePoints
                    .asMap()
                    .entries
                    .map(
                      (e) => ChartLegendItem(
                        label: e.value.label,
                        color: ChartTheme.of(context).colorAt(e.key),
                        valueLabel: '${e.value.value.toInt()}',
                      ),
                    )
                    .toList(),
                child: AppPieChart(points: attendancePoints),
              ),
              if (data.analytics.creditScore != null) ...[
                const SizedBox(height: AppSpacing.md),
                ChartCard(
                  title: 'Your credit score',
                  subtitle: 'Personal risk profile',
                  legend: [
                    ChartLegendItem(
                      label: 'Score',
                      color: theme.colorScheme.primary,
                      valueLabel: '${data.analytics.creditScore}',
                    ),
                  ],
                  child: AppBarChart(
                    points: [
                      ChartPoint(
                        label: 'Credit',
                        value: data.analytics.creditScore!.toDouble(),
                      ),
                    ],
                    valueFormatter: (v) => v.toStringAsFixed(0),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
