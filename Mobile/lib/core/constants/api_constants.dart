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

  /// Dio [RequestOptions.extra] flag — skip attaching Bearer token.
  static const String skipAuthKey = 'skipAuth';

  /// Dio [RequestOptions.extra] flag — skip 401 refresh handling.
  static const String skipRefreshKey = 'skipRefresh';
}
