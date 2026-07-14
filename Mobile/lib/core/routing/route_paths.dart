/// Application route path constants.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static const String chamas = '/chamas';
  static const String contributions = '/contributions';
  static const String loans = '/loans';
  static const String meetings = '/meetings';
  static const String reports = '/reports';
  static const String profile = '/profile';

  static String chamaDetails(String chamaId) => '/chamas/$chamaId';
  static String chamaMembers(String chamaId) => '/chamas/$chamaId/members';
  static String memberDetails(String chamaId, String membershipId) =>
      '/chamas/$chamaId/members/$membershipId';
  static String chamaJoinRequests(String chamaId) =>
      '/chamas/$chamaId/join-requests';

  static const Set<String> publicRoutes = {
    splash,
    login,
    forgotPassword,
  };
}
