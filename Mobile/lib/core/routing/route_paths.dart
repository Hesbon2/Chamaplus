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

  static const Set<String> publicRoutes = {
    splash,
    login,
    forgotPassword,
  };
}
