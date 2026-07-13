/// Application route path constants.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static const Set<String> publicRoutes = {
    splash,
    login,
    forgotPassword,
  };
}
