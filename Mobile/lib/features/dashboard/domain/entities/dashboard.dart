import 'package:intl/intl.dart';

/// A single month data point for dashboard charts.
class MonthlyChartPoint {
  const MonthlyChartPoint({
    required this.month,
    required this.value,
  });

  final DateTime month;
  final double value;

  String get label => DateFormat('MMM').format(month);
}

/// Contribution metrics for the dashboard.
class ContributionSummary {
  const ContributionSummary({
    required this.paidByUser,
    required this.cycleTotal,
    this.activeCycleName,
    required this.currency,
  });

  final double paidByUser;
  final double cycleTotal;
  final String? activeCycleName;
  final String currency;
}

/// Loan metrics for the dashboard.
class LoanSummary {
  const LoanSummary({
    required this.outstandingBalance,
    required this.activeLoansCount,
    required this.pendingApplications,
    required this.currency,
  });

  final double outstandingBalance;
  final int activeLoansCount;
  final int pendingApplications;
  final String currency;
}

/// Upcoming meeting summary.
class DashboardMeeting {
  const DashboardMeeting({
    required this.id,
    required this.title,
    required this.meetingDate,
    this.startTime,
  });

  final String id;
  final String title;
  final DateTime meetingDate;
  final String? startTime;
}

/// Recent activity item (sourced from notifications).
class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
}

/// Aggregated dashboard model for the UI layer.
class Dashboard {
  const Dashboard({
    required this.chamaId,
    required this.chamaName,
    required this.welcomeName,
    this.userRole,
    required this.memberCount,
    required this.contributionSummary,
    required this.loanSummary,
    this.creditScore,
    this.upcomingMeeting,
    required this.unreadNotifications,
    required this.recentActivities,
    required this.monthlyContributions,
    required this.monthlyLoanBalances,
    required this.completedMeetings,
  });

  final String chamaId;
  final String chamaName;
  final String welcomeName;
  final String? userRole;
  final int memberCount;
  final ContributionSummary contributionSummary;
  final LoanSummary loanSummary;
  final int? creditScore;
  final DashboardMeeting? upcomingMeeting;
  final int unreadNotifications;
  final List<RecentActivity> recentActivities;
  final List<MonthlyChartPoint> monthlyContributions;
  final List<MonthlyChartPoint> monthlyLoanBalances;
  final int completedMeetings;

  bool get hasChama => chamaId.isNotEmpty;
}
