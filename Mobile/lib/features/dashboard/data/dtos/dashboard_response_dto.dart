class DashboardResponseDto {
  const DashboardResponseDto({
    required this.memberCount,
    this.activeCycle,
    required this.contributionsThisCycle,
    required this.outstandingLoans,
    required this.pendingLoanApplications,
    required this.completedMeetings,
    this.nextMeeting,
    required this.userSummary,
  });

  final int memberCount;
  final String? activeCycle;
  final String contributionsThisCycle;
  final String outstandingLoans;
  final int pendingLoanApplications;
  final int completedMeetings;
  final NextMeetingDto? nextMeeting;
  final UserSummaryDto userSummary;

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) {
    return DashboardResponseDto(
      memberCount: json['member_count'] as int? ?? 0,
      activeCycle: json['active_cycle'] as String?,
      contributionsThisCycle:
          json['contributions_this_cycle'] as String? ?? '0.00',
      outstandingLoans: json['outstanding_loans'] as String? ?? '0.00',
      pendingLoanApplications:
          json['pending_loan_applications'] as int? ?? 0,
      completedMeetings: json['completed_meetings'] as int? ?? 0,
      nextMeeting: json['next_meeting'] != null
          ? NextMeetingDto.fromJson(
              json['next_meeting'] as Map<String, dynamic>,
            )
          : null,
      userSummary: UserSummaryDto.fromJson(
        json['user_summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class UserSummaryDto {
  const UserSummaryDto({
    required this.contributionsPaid,
    required this.activeLoans,
    this.creditScore,
  });

  final String contributionsPaid;
  final int activeLoans;
  final int? creditScore;

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserSummaryDto(
      contributionsPaid: json['contributions_paid'] as String? ?? '0.00',
      activeLoans: json['active_loans'] as int? ?? 0,
      creditScore: json['credit_score'] as int?,
    );
  }
}

class NextMeetingDto {
  const NextMeetingDto({
    required this.id,
    required this.title,
    required this.meetingDate,
    this.startTime,
  });

  final String id;
  final String title;
  final String meetingDate;
  final String? startTime;

  factory NextMeetingDto.fromJson(Map<String, dynamic> json) {
    return NextMeetingDto(
      id: json['id'] as String,
      title: json['title'] as String,
      meetingDate: json['meeting_date'] as String,
      startTime: json['start_time'] as String?,
    );
  }
}
