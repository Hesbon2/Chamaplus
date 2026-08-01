import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a deep-link / intended destination while auth or onboarding bootstraps.
///
/// GoRouter redirects write here before sending the user to splash/login so the
/// original path can be restored after authentication succeeds.
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);

/// Returns true when [location] is a public auth/onboarding entry that should
/// not be captured as a post-login restore target.
bool isEphemeralAuthLocation(String location) {
  return location == '/' ||
      location == '/splash' ||
      location == '/login' ||
      location == '/register' ||
      location == '/forgot-password';
}
