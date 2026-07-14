import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard.dart';
import '../utils/dashboard_formatters.dart';
import 'dashboard_stat_card.dart';
import 'monthly_charts_section.dart';
import 'quick_actions_grid.dart';
import 'recent_activities_list.dart';
import 'welcome_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.dashboard,
  });

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = dashboard.contributionSummary.currency;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: ListView(
        key: ValueKey(dashboard.chamaId),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          WelcomeCard(
            name: dashboard.welcomeName,
            chamaName: dashboard.chamaName,
            role: dashboard.userRole,
            memberCount: dashboard.memberCount,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final statCards = [
                DashboardStatCard(
                  title: 'Contributions',
                  value: DashboardFormatters.currency(
                    dashboard.contributionSummary.paidByUser,
                    currencyCode: currency,
                  ),
                  subtitle: dashboard.contributionSummary.activeCycleName ??
                      'Your total paid',
                  icon: Icons.savings_outlined,
                ),
                DashboardStatCard(
                  title: 'Outstanding Loans',
                  value: DashboardFormatters.currency(
                    dashboard.loanSummary.outstandingBalance,
                    currencyCode: currency,
                  ),
                  subtitle:
                      '${dashboard.loanSummary.activeLoansCount} active loan(s)',
                  icon: Icons.account_balance_outlined,
                  accentColor: theme.colorScheme.secondary,
                ),
                DashboardStatCard(
                  title: 'Credit Score',
                  value: DashboardFormatters.creditScore(dashboard.creditScore),
                  subtitle: 'Chama performance rating',
                  icon: Icons.verified_outlined,
                  accentColor: theme.colorScheme.tertiary,
                ),
                DashboardStatCard(
                  title: 'Notifications',
                  value: '${dashboard.unreadNotifications}',
                  subtitle: 'Unread messages',
                  icon: Icons.notifications_outlined,
                  accentColor: theme.colorScheme.error,
                ),
              ];

              if (isWide) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.8,
                  children: statCards,
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: statCards[0]),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: statCards[1]),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: statCards[2]),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: statCards[3]),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Upcoming Meeting',
            child: dashboard.upcomingMeeting == null
                ? Text(
                    'No meetings scheduled.',
                    style: theme.textTheme.bodyMedium,
                  )
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.event,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(dashboard.upcomingMeeting!.title),
                    subtitle: Text(
                      DashboardFormatters.meetingDate(
                        dashboard.upcomingMeeting!.meetingDate,
                        startTime: dashboard.upcomingMeeting!.startTime,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Cycle Summary',
            child: Text(
              '${dashboard.contributionSummary.activeCycleName ?? 'Current cycle'}: '
              '${DashboardFormatters.currency(dashboard.contributionSummary.cycleTotal, currencyCode: currency)} collected',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MonthlyChartsSection(
            contributions: dashboard.monthlyContributions,
            loanBalances: dashboard.monthlyLoanBalances,
            currency: currency,
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Recent Activity',
            child: RecentActivitiesList(
              activities: dashboard.recentActivities,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Quick Actions',
            child: const QuickActionsGrid(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
