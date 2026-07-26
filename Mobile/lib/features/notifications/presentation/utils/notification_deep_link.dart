import '../../../../core/routing/route_paths.dart';
import '../../domain/entities/notification.dart';

/// Resolves in-app deep links from notification type + metadata.
class NotificationDeepLink {
  NotificationDeepLink._();

  /// Returns a GoRouter path, always non-null (falls back to Home).
  static String resolve(AppNotification notification) {
    final chamaId = notification.chamaId;
    final meetingId = notification.meetingId;
    final loanId = notification.loanApplicationId;

    if (notification.type.isMeetingRelated) {
      if (chamaId != null && meetingId != null) {
        return RoutePaths.meetingDetails(chamaId, meetingId);
      }
      if (chamaId != null) {
        return RoutePaths.chamaMeetings(chamaId);
      }
      return RoutePaths.meetings;
    }

    if (notification.type.isContributionRelated) {
      if (chamaId != null) {
        final contributionId = notification.contributionId;
        if (contributionId != null) {
          return RoutePaths.contributionDetails(chamaId, contributionId);
        }
        return RoutePaths.chamaContributions(chamaId);
      }
      return RoutePaths.contributions;
    }

    if (notification.type.isLoanRelated) {
      if (chamaId != null && loanId != null) {
        return RoutePaths.loanDetails(chamaId, loanId);
      }
      if (chamaId != null) {
        return RoutePaths.chamaLoans(chamaId);
      }
      return RoutePaths.loans;
    }

    if (chamaId != null) {
      return RoutePaths.chamaDetails(chamaId);
    }
    return RoutePaths.home;
  }

  /// Short CTA label for the resolved destination.
  static String actionLabel(AppNotification notification) {
    if (notification.type.isMeetingRelated) return 'Open meeting';
    if (notification.type.isContributionRelated) return 'Open contributions';
    if (notification.type.isLoanRelated) return 'Open loans';
    if (notification.chamaId != null) return 'Open chama';
    return 'Go to home';
  }
}
