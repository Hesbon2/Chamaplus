/// HTTP and API-related constants.
class ApiConstants {
  ApiConstants._();

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';

  // Auth endpoints (relative to API base URL)
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authRefresh = '/auth/refresh/';
  static const String authLogout = '/auth/logout/';
  static const String authChangePassword = '/auth/change-password/';
  static const String usersMe = '/users/me/';

  // Chama & dashboard
  static const String chamas = '/chamas/';
  static const String chamaJoin = '/chamas/join/';
  static String chamaDetail(String chamaId) => '/chamas/$chamaId/';
  static String chamaInvite(String chamaId) => '/chamas/$chamaId/invite/';
  static String chamaDashboard(String chamaId) => '/chamas/$chamaId/dashboard/';
  static String chamaMembers(String chamaId) => '/chamas/$chamaId/members/';
  static String chamaMeetings(String chamaId) => '/chamas/$chamaId/meetings/';
  static String chamaMeetingDetail(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/';
  static String chamaMeetingStart(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/start/';
  static String chamaMeetingClose(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/close/';
  static String chamaMeetingAttendance(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/attendance/';
  static String chamaMeetingAttendanceDetail(
    String chamaId,
    String meetingId,
    String attendanceId,
  ) =>
      '/chamas/$chamaId/meetings/$meetingId/attendance/$attendanceId/';
  static String chamaMeetingMinutes(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/minutes/';
  static String chamaMeetingMinutesApprove(String chamaId, String meetingId) =>
      '/chamas/$chamaId/meetings/$meetingId/minutes/approve/';
  static String chamaMonthlyReport(String chamaId) =>
      '/chamas/$chamaId/reports/monthly/';
  static String chamaLoansReport(String chamaId) =>
      '/chamas/$chamaId/reports/loans/';
  static String chamaRepaymentsReport(String chamaId) =>
      '/chamas/$chamaId/reports/repayments/';
  static String chamaFinancialReport(String chamaId) =>
      '/chamas/$chamaId/reports/financial/';
  static String chamaReportExport(String chamaId, String reportType) =>
      '/chamas/$chamaId/reports/$reportType/export/';
  static String membershipStatus(String membershipId) =>
      '/memberships/$membershipId/status/';
  static const String notifications = '/notifications/';
  static String notificationDetail(String notificationId) =>
      '/notifications/$notificationId/';
  static const String notificationsMarkAllRead =
      '/notifications/mark-all-read/';

  // Contributions
  static String contributionCycles(String chamaId) =>
      '/chamas/$chamaId/contribution-cycles/';
  static String contributionCycleDetail(String chamaId, String cycleId) =>
      '/chamas/$chamaId/contribution-cycles/$cycleId/';
  static String contributionCycleClose(String chamaId, String cycleId) =>
      '/chamas/$chamaId/contribution-cycles/$cycleId/close/';
  static String contributions(String chamaId) =>
      '/chamas/$chamaId/contributions/';
  static String contributionDetail(String chamaId, String contributionId) =>
      '/chamas/$chamaId/contributions/$contributionId/';
  static String contributionsReport(String chamaId) =>
      '/chamas/$chamaId/reports/contributions/';
  static String memberFinancialReport(String chamaId, String memberId) =>
      '/chamas/$chamaId/reports/members/$memberId/financial/';

  // Loans
  static String loanProducts(String chamaId) =>
      '/chamas/$chamaId/loan-products/';
  static String loanProductDetail(String chamaId, String productId) =>
      '/chamas/$chamaId/loan-products/$productId/';
  static String loanApplications(String chamaId) =>
      '/chamas/$chamaId/loan-applications/';
  static String loanApplicationDetail(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/';
  static String loanApplicationSubmit(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/submit/';
  static String loanApplicationCancel(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/cancel/';
  static String loanApplicationApprove(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/approve/';
  static String loanApplicationReject(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/reject/';
  static String loanApplicationDisburse(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/disburse/';
  static String loanVotes(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/votes/';
  static String loanRepayments(String chamaId, String applicationId) =>
      '/chamas/$chamaId/loan-applications/$applicationId/repayments/';
  static String loanRepaymentDetail(
    String chamaId,
    String applicationId,
    String repaymentId,
  ) =>
      '/chamas/$chamaId/loan-applications/$applicationId/repayments/$repaymentId/';
  static String memberCreditScoreCurrent(String chamaId, String memberId) =>
      '/chamas/$chamaId/members/$memberId/credit-scores/current/';

  static const int defaultPageSize = 20;

  /// Dio [RequestOptions.extra] flag — skip attaching Bearer token.
  static const String skipAuthKey = 'skipAuth';

  /// Dio [RequestOptions.extra] flag — skip 401 refresh handling.
  static const String skipRefreshKey = 'skipRefresh';

  /// Skip offline GET cache read/write for this request.
  static const String skipCacheKey = 'skipCache';

  /// Bypass fresh-cache short-circuit and hit the network.
  static const String forceRefreshKey = 'forceRefresh';

  /// Response was served from [OfflineCacheStore].
  static const String fromCacheKey = 'fromCache';

  /// Cached response is past its TTL (stale-while-offline).
  static const String staleCacheKey = 'staleCache';

  /// Skip [RetryInterceptor] for this request.
  static const String skipRetryKey = 'skipRetry';

  /// Current retry attempt counter (managed by [RetryInterceptor]).
  static const String retryAttemptKey = 'retryAttempt';
}
