/// Application route path constants.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String welcome = '/welcome';
  static const String createChama = '/create-chama';
  static const String joinChama = '/join-chama';
  static const String pendingApproval = '/pending-approval';
  static const String pendingInvitations = '/pending-invitations';

  static const String chamas = '/chamas';
  static const String contributions = '/contributions';
  static const String loans = '/loans';
  static const String meetings = '/meetings';
  static const String alerts = '/alerts';
  static const String alertsList = '/alerts/list';
  static String alertDetails(String notificationId) =>
      '/alerts/$notificationId';
  static const String more = '/more';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsSecurity = '/settings/security';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsHelp = '/settings/help';
  static const String settingsAbout = '/settings/about';
  static const String settingsDiagnostics = '/settings/diagnostics';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static String chamaDetails(String chamaId) => '/chamas/$chamaId';
  static String chamaMembers(String chamaId) => '/chamas/$chamaId/members';
  static String memberDetails(String chamaId, String membershipId) =>
      '/chamas/$chamaId/members/$membershipId';
  static String chamaJoinRequests(String chamaId) =>
      '/chamas/$chamaId/join-requests';
  static String chamaInviteMembers(String chamaId) =>
      '/chamas/$chamaId/invite';

  static String chamaContributions(String chamaId) =>
      '/chamas/$chamaId/contributions';
  static String contributionHistory(
    String chamaId, {
    String? cycleId,
    String? memberId,
  }) {
    final params = <String, String>{
      if (cycleId != null) 'cycleId': cycleId,
      if (memberId != null) 'memberId': memberId,
    };
    final uri = Uri(
      path: '/chamas/$chamaId/contributions/history',
      queryParameters: params.isEmpty ? null : params,
    );
    return uri.toString();
  }

  static String recordContribution(String chamaId) =>
      '/chamas/$chamaId/contributions/record';
  static String contributionDetails(String chamaId, String contributionId) =>
      '/chamas/$chamaId/contributions/$contributionId';
  static String memberContributionSummary(String chamaId, String memberId) =>
      '/chamas/$chamaId/contributions/members/$memberId';

  static String contributionCycles(String chamaId) =>
      '/chamas/$chamaId/contribution-cycles';
  static String createContributionCycle(String chamaId) =>
      '/chamas/$chamaId/contribution-cycles/create';
  static String cycleDetails(String chamaId, String cycleId) =>
      '/chamas/$chamaId/contribution-cycles/$cycleId';

  // Loans
  static String chamaLoans(String chamaId) => '/chamas/$chamaId/loans';
  static String loanProducts(String chamaId) =>
      '/chamas/$chamaId/loans/products';
  static String createLoanProduct(String chamaId) =>
      '/chamas/$chamaId/loans/products/create';
  static String loanProductDetails(String chamaId, String productId) =>
      '/chamas/$chamaId/loans/products/$productId';
  static String editLoanProduct(String chamaId, String productId) =>
      '/chamas/$chamaId/loans/products/$productId/edit';
  static String loanCalculator(String chamaId) =>
      '/chamas/$chamaId/loans/calculator';
  static String applyLoan(String chamaId, {String? productId}) {
    final uri = Uri(
      path: '/chamas/$chamaId/loans/apply',
      queryParameters: productId == null ? null : {'productId': productId},
    );
    return uri.toString();
  }

  static String loanDetails(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loans/applications/$applicationId';
  static String loanCommitteeVoting(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loans/applications/$applicationId/vote';
  static String loanRepaymentHistory(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loans/applications/$applicationId/repayments';
  static String activeLoan(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loans/applications/$applicationId/active';
  static String loanHistory(String chamaId) =>
      '/chamas/$chamaId/loans/history';

  // Meetings / Governance
  static String chamaMeetings(String chamaId) => '/chamas/$chamaId/meetings';
  static String chamaReports(String chamaId) => '/chamas/$chamaId/reports';
  static String monthlyReport(String chamaId) =>
      '/chamas/$chamaId/reports/monthly';
  static String financialReport(String chamaId) =>
      '/chamas/$chamaId/reports/financial';
  static String defaultersReport(String chamaId) =>
      '/chamas/$chamaId/reports/defaulters';
  static String memberStatement(String chamaId, {String? memberId}) {
    final uri = Uri(
      path: '/chamas/$chamaId/reports/member-statement',
      queryParameters: memberId == null ? null : {'memberId': memberId},
    );
    return uri.toString();
  }

  static String exportCenter(String chamaId) =>
      '/chamas/$chamaId/reports/export';
  static String meetingsList(String chamaId) =>
      '/chamas/$chamaId/meetings/list';
  static String upcomingMeetings(String chamaId) =>
      '/chamas/$chamaId/meetings/upcoming';
  static String scheduleMeeting(String chamaId) =>
      '/chamas/$chamaId/meetings/schedule';
  static String meetingDetails(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId';
  static String meetingAttendance(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/attendance';
  static String meetingMinutes(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/minutes';
  static String meetingActionItems(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/action-items';

  static const Set<String> publicRoutes = {
    splash,
    login,
    register,
    forgotPassword,
  };

  /// Authenticated routes allowed before the user has an active chama.
  static const Set<String> onboardingRoutes = {
    welcome,
    createChama,
    joinChama,
    pendingApproval,
    pendingInvitations,
    profile,
    editProfile,
    settings,
    settingsAppearance,
    settingsSecurity,
    settingsNotifications,
    settingsHelp,
    settingsAbout,
  };
}
