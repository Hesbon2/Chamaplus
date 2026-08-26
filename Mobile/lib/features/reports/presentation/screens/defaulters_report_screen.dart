import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/navigation/navigation.dart';
import '../../../../shared/reports/reports.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../utils/report_formatters.dart';

/// Contribution and loan defaulters with PDF/CSV export.
class DefaultersReportScreen extends ConsumerWidget {
  const DefaultersReportScreen({super.key, required this.chamaId});

  final String chamaId;

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    DefaultersReport report,
  ) async {
    await runReportExportFlow(
      context,
      ref,
      buildRequest: (format) => ReportExportRequest(
        title: 'Defaulters report',
        subtitle: 'Missed contributions & overdue loans',
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentMemberRoleProvider);
    final state = ref.watch(defaultersReportProvider(chamaId));
    final controller = ref.read(defaultersReportProvider(chamaId).notifier);
    final theme = Theme.of(context);

    if (!role.canManageMoney) {
      return Scaffold(
        appBar: AppBar(title: const Text('Defaulters')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: InfoTile(
              title: 'Officials only',
              subtitle:
                  'Only the treasurer or chairperson can view and export the defaulters report.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Defaulters')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final option in const [
                    ('all', 'All'),
                    ('contribution', 'Contributions'),
                    ('loan', 'Loans'),
                  ]) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(option.$2),
                        selected: controller.type == option.$1,
                        onSelected: (_) => controller.setType(option.$1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ApiStateBuilder<DefaultersReport>(
              state: state,
              onRefresh: controller.refresh,
              onRetry: controller.retry,
              emptyTitle: 'No defaulters',
              emptyMessage:
                  'All members are up to date for the selected filter.',
              emptyIcon: Icons.verified_outlined,
              builder: (context, report) {
                if (report.defaulters.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      SummaryMetricTile(
                        title: 'Contribution defaulters',
                        value: '${report.contributionDefaultersCount}',
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SummaryMetricTile(
                        title: 'Loan defaulters',
                        value: '${report.loanDefaultersCount}',
                        icon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const InfoTile(
                        title: 'No defaulters',
                        subtitle:
                            'All members are up to date for the selected filter.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ExportButton(
                        expand: true,
                        onPressed: () => _export(context, ref, report),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: report.defaulters.length + 2,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          SummaryMetricTile(
                            title: 'Contribution defaulters',
                            value: '${report.contributionDefaultersCount}',
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SummaryMetricTile(
                            title: 'Loan defaulters',
                            value: '${report.loanDefaultersCount}',
                            icon: Icons.account_balance_outlined,
                            accentColor: theme.colorScheme.error,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ExportButton(
                            expand: true,
                            onPressed: () => _export(context, ref, report),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const SectionHeader(title: 'Defaulters'),
                        ],
                      );
                    }
                    if (index == report.defaulters.length + 1) {
                      return const SizedBox(height: AppSpacing.xl);
                    }

                    final row = report.defaulters[index - 1];
                    final detail = row.type == DefaulterType.contribution
                        ? '${row.cycleName ?? 'Open cycle'} · expected '
                            '${ReportFormatters.money(
                              row.expectedAmount ?? 0,
                              currency: report.currency,
                            )}'
                        : 'Outstanding ${ReportFormatters.money(
                              row.outstandingBalance ?? 0,
                              currency: report.currency,
                            )}'
                            '${row.dueDate != null ? ' · due ${DateFormat.yMMMd().format(row.dueDate!.toLocal())}' : ''}';

                    return AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarBadge(
                            initials: row.fullName.isNotEmpty
                                ? row.fullName
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .take(2)
                                    .map((p) => p[0].toUpperCase())
                                    .join()
                                : '?',
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.fullName,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  row.phoneNumber,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  detail,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: row.type.label,
                            tone: row.type == DefaulterType.loan
                                ? StatusChipTone.error
                                : StatusChipTone.warning,
                            compact: true,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
