/// HTTP and API-related constants.
class ApiConstants {
  ApiConstants._();

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';

  // Auth endpoints (relative to API base URL)
  static const String authLogin = '/auth/login/';
  static const String authRefresh = '/auth/refresh/';
  static const String authLogout = '/auth/logout/';
  static const String usersMe = '/users/me/';

  // Chama & dashboard
  static const String chamas = '/chamas/';
  static String chamaDetail(String chamaId) => '/chamas/$chamaId/';
  static String chamaDashboard(String chamaId) => '/chamas/$chamaId/dashboard/';
  static String chamaMembers(String chamaId) => '/chamas/$chamaId/members/';
  static String chamaMeetings(String chamaId) => '/chamas/$chamaId/meetings/';
  static String chamaMonthlyReport(String chamaId) =>
      '/chamas/$chamaId/reports/monthly/';
  static String membershipStatus(String membershipId) =>
      '/memberships/$membershipId/status/';
  static const String notifications = '/notifications/';
  static const int defaultPageSize = 20;

  /// Dio [RequestOptions.extra] flag — skip attaching Bearer token.
  static const String skipAuthKey = 'skipAuth';

  /// Dio [RequestOptions.extra] flag — skip 401 refresh handling.
  static const String skipRefreshKey = 'skipRefresh';
}
