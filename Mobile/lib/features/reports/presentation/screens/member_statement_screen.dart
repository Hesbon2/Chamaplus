import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/charts/charts.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/reports/reports.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../utils/report_formatters.dart';

/// Member financial statement (snapshot + contribution lines).
class MemberStatementScreen extends ConsumerWidget {
  const MemberStatementScreen({
    super.key,
    required this.chamaId,
    this.memberId,
  });

  final String chamaId;
  final String? memberId;

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    MemberStatement statement,
  ) async {
    await runReportExportFlow(
      context,
      ref,
      buildRequest: (format) => ReportExportRequest(
        title: 'Member statement',
        subtitle: statement.memberId,
        fileName: 'member_statement_${statement.memberId}',
        format: format,
        summary: ReportExportBuilders.memberSummary(statement),
        columns: const [
          ReportColumn(key: 'date', label: 'Date'),
          ReportColumn(key: 'label', label: 'Description'),
          ReportColumn(key: 'category', label: 'Category'),
          ReportColumn(key: 'amount', label: 'Amount'),
        ],
        rows: ReportExportBuilders.memberLines(statement),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedId = memberId ?? ref.watch(currentUserIdProvider);
    if (resolvedId == null || resolvedId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member statement')),
        body: const EmptyState(
          title: 'Sign in required',
          message: 'Your member profile could not be resolved.',
          icon: Icons.person_off_outlined,
        ),
      );
    }

    final args = (chamaId: chamaId, memberId: resolvedId);
    final state = ref.watch(memberStatementProvider(args));
    final controller = ref.read(memberStatementProvider(args).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Member statement')),
      body: ApiStateBuilder<MemberStatement>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, statement) {
          final credit = statement.creditScore;
          final creditPoints = credit == null
              ? <ChartPoint>[]
              : [
                  ChartPoint(
                    label: 'Score',
                    value: credit.toDouble(),
                    color: theme.colorScheme.primary,
                  ),
                  ChartPoint(
                    label: 'Remaining',
                    value: (100 - credit).clamp(0, 100).toDouble(),
                    color: theme.colorScheme.outlineVariant,
                  ),
                ];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              SummaryMetricTile(
                title: 'Contributions paid',
                value: ReportFormatters.money(
                  statement.contributionsTotal,
                  currency: statement.currency,
                ),
                icon: Icons.payments_outlined,
                subtitle: '${statement.contributionsCount} records',
              ),
              const SizedBox(height: AppSpacing.sm),
              SummaryMetricTile(
                title: 'Active loans',
                value: '${statement.activeLoans}',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              SummaryMetricTile(
                title: 'Repayments',
                value: ReportFormatters.money(
                  statement.repaymentsTotal,
                  currency: statement.currency,
                ),
                icon: Icons.savings_outlined,
              ),
              if (credit != null) ...[
                const SizedBox(height: AppSpacing.sm),
                SummaryMetricTile(
                  title: 'Credit score',
                  value: '$credit',
                  icon: Icons.verified_outlined,
                  subtitle: statement.creditRiskLevel,
                  trend: credit >= 70
                      ? MetricTrend.up
                      : credit >= 40
                          ? MetricTrend.flat
                          : MetricTrend.down,
                ),
                const SizedBox(height: AppSpacing.md),
                ChartCard(
                  title: 'Credit score',
                  subtitle: statement.creditRiskLevel ?? 'Risk profile',
                  child: AppPieChart(
                    points: creditPoints,
                    showPercentLabels: false,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Recent activity'),
              const SizedBox(height: AppSpacing.sm),
              if (statement.lineItems.isEmpty)
                const AppCard(
                  child: Text('No contribution lines available yet.'),
                )
              else
                ...statement.lineItems.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.label,
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  '${line.category} · ${DateFormat.yMMMd().format(line.date.toLocal())}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            ReportFormatters.money(
                              line.amount,
                              currency: statement.currency,
                            ),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              ExportButton(
                expand: true,
                onPressed: () => _export(context, ref, statement),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
