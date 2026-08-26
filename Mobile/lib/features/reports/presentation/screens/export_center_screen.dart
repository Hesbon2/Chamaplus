import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/reports/reports.dart';
import '../providers/report_providers.dart';
import '../utils/report_formatters.dart';

/// Central place to export monthly / financial / member reports.
class ExportCenterScreen extends ConsumerWidget {
  const ExportCenterScreen({super.key, required this.chamaId});

  final String chamaId;

  Future<void> _exportMonthly(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    try {
      final report = await ref.read(reportRepositoryProvider).getMonthlyReport(
            chamaId: chamaId,
            year: now.year,
            month: now.month,
          );
      if (!context.mounted) return;
      await runReportExportFlow(
        context,
        ref,
        buildRequest: (format) => ReportExportRequest(
          title: 'Monthly report — ${report.periodLabel}',
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
    } catch (error) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not load monthly report: $error');
      }
    }
  }

  Future<void> _exportFinancial(BuildContext context, WidgetRef ref) async {
    try {
      final report =
          await ref.read(reportRepositoryProvider).getFinancialReport(
                chamaId: chamaId,
              );
      if (!context.mounted) return;
      await runReportExportFlow(
        context,
        ref,
        buildRequest: (format) => ReportExportRequest(
          title: 'Financial report',
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
    } catch (error) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not load financial report: $error');
      }
    }
  }

  Future<void> _exportMember(BuildContext context, WidgetRef ref) async {
    final memberId = ref.read(currentUserIdProvider);
    if (memberId == null) {
      AppSnackbar.error(context, 'Sign in to export your statement');
      return;
    }
    try {
      final statement =
          await ref.read(reportRepositoryProvider).getMemberStatement(
                chamaId: chamaId,
                memberId: memberId,
              );
      if (!context.mounted) return;
      await runReportExportFlow(
        context,
        ref,
        buildRequest: (format) => ReportExportRequest(
          title: 'Member statement',
          fileName: 'member_statement_$memberId',
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
    } catch (error) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not load statement: $error');
      }
    }
  }

  Future<void> _exportDefaulters(BuildContext context, WidgetRef ref) async {
    try {
      final report =
          await ref.read(reportRepositoryProvider).getDefaultersReport(
                chamaId: chamaId,
              );
      if (!context.mounted) return;
      await runReportExportFlow(
        context,
        ref,
        buildRequest: (format) => ReportExportRequest(
          title: 'Defaulters report',
          fileName: 'defaulters_report',
          format: format,
          summary: ReportExportBuilders.defaultersSummary(report),
          columns: const [
            ReportColumn(key: 'name', label: 'Name'),
            ReportColumn(key: 'phone', label: 'Phone'),
            ReportColumn(key: 'role', label: 'Role'),
            ReportColumn(key: 'type', label: 'Type'),
            ReportColumn(key: 'detail', label: 'Detail'),
          ],
          rows: ReportExportBuilders.defaultersRows(report),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not load defaulters: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export center')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Generate PDF or CSV, then share or save to device storage.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ReportCard(
            title: 'Monthly report',
            subtitle: 'Current calendar month',
            icon: Icons.calendar_month_outlined,
            badgeLabel: 'PDF · CSV',
            trailing: ExportButton(
              expand: false,
              label: 'Export',
              onPressed: () => _exportMonthly(context, ref),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReportCard(
            title: 'Financial report',
            subtitle: 'Full chama overview',
            icon: Icons.account_balance_outlined,
            badgeLabel: 'PDF · CSV',
            trailing: ExportButton(
              expand: false,
              label: 'Export',
              onPressed: () => _exportFinancial(context, ref),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReportCard(
            title: 'Defaulters report',
            subtitle: 'Missed contributions & overdue loans',
            icon: Icons.warning_amber_outlined,
            badgeLabel: 'PDF · CSV',
            trailing: ExportButton(
              expand: false,
              label: 'Export',
              onPressed: () => _exportDefaulters(context, ref),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReportCard(
            title: 'My member statement',
            subtitle: 'Contributions, loans & credit',
            icon: Icons.receipt_long_outlined,
            badgeLabel: 'PDF · CSV',
            trailing: ExportButton(
              expand: false,
              label: 'Export',
              onPressed: () => _exportMember(context, ref),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const InfoTile(
            title: 'Tip',
            subtitle:
                'Exports use the shared ReportExportService — the same pipeline every report screen uses.',
            dense: true,
          ),
        ],
      ),
    );
  }
}
