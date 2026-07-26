export '../../../../core/models/paged_result.dart';

/// Delivery channel for an inbox item.
enum NotificationChannel {
  inApp,
  sms,
  email,
  unknown;

  static NotificationChannel fromApi(String? value) {
    switch (value) {
      case 'in_app':
        return NotificationChannel.inApp;
      case 'sms':
        return NotificationChannel.sms;
      case 'email':
        return NotificationChannel.email;
      default:
        return NotificationChannel.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case NotificationChannel.inApp:
        return 'in_app';
      case NotificationChannel.sms:
        return 'sms';
      case NotificationChannel.email:
        return 'email';
      case NotificationChannel.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case NotificationChannel.inApp:
        return 'In-app';
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.unknown:
        return 'Unknown';
    }
  }
}

/// Backend `notification_type` values.
enum NotificationType {
  loanApplied,
  loanApproved,
  loanRejected,
  contributionRecorded,
  repaymentRecorded,
  committeeVoteCompleted,
  attendanceFinalized,
  unknown;

  static NotificationType fromApi(String? value) {
    switch (value) {
      case 'loan_applied':
        return NotificationType.loanApplied;
      case 'loan_approved':
        return NotificationType.loanApproved;
      case 'loan_rejected':
        return NotificationType.loanRejected;
      case 'contribution_recorded':
        return NotificationType.contributionRecorded;
      case 'repayment_recorded':
        return NotificationType.repaymentRecorded;
      case 'committee_vote_completed':
        return NotificationType.committeeVoteCompleted;
      case 'attendance_finalized':
        return NotificationType.attendanceFinalized;
      default:
        return NotificationType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case NotificationType.loanApplied:
        return 'loan_applied';
      case NotificationType.loanApproved:
        return 'loan_approved';
      case NotificationType.loanRejected:
        return 'loan_rejected';
      case NotificationType.contributionRecorded:
        return 'contribution_recorded';
      case NotificationType.repaymentRecorded:
        return 'repayment_recorded';
      case NotificationType.committeeVoteCompleted:
        return 'committee_vote_completed';
      case NotificationType.attendanceFinalized:
        return 'attendance_finalized';
      case NotificationType.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case NotificationType.loanApplied:
        return 'Loan applied';
      case NotificationType.loanApproved:
        return 'Loan approved';
      case NotificationType.loanRejected:
        return 'Loan rejected';
      case NotificationType.contributionRecorded:
        return 'Contribution';
      case NotificationType.repaymentRecorded:
        return 'Repayment';
      case NotificationType.committeeVoteCompleted:
        return 'Committee vote';
      case NotificationType.attendanceFinalized:
        return 'Attendance';
      case NotificationType.unknown:
        return 'Alert';
    }
  }

  String get categoryLabel {
    switch (this) {
      case NotificationType.loanApplied:
      case NotificationType.loanApproved:
      case NotificationType.loanRejected:
      case NotificationType.repaymentRecorded:
      case NotificationType.committeeVoteCompleted:
        return 'Loans';
      case NotificationType.contributionRecorded:
        return 'Contributions';
      case NotificationType.attendanceFinalized:
        return 'Meetings';
      case NotificationType.unknown:
        return 'General';
    }
  }

  bool get isLoanRelated =>
      this == NotificationType.loanApplied ||
      this == NotificationType.loanApproved ||
      this == NotificationType.loanRejected ||
      this == NotificationType.repaymentRecorded ||
      this == NotificationType.committeeVoteCompleted;

  bool get isContributionRelated =>
      this == NotificationType.contributionRecorded;

  bool get isMeetingRelated => this == NotificationType.attendanceFinalized;
}

/// Inbox notification entity.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.channel,
    required this.isRead,
    this.readAt,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationChannel channel;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  String? get chamaId =>
      metadata['chama_id']?.toString() ?? metadata['chamaId']?.toString();

  String? get meetingId =>
      metadata['meeting_id']?.toString() ?? metadata['meetingId']?.toString();

  String? get loanApplicationId =>
      metadata['loan_id']?.toString() ??
      metadata['application_id']?.toString() ??
      metadata['loan_application_id']?.toString();

  String? get contributionId =>
      metadata['contribution_id']?.toString() ??
      metadata['contributionId']?.toString();

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      channel: channel,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      metadata: metadata,
      createdAt: createdAt,
    );
  }
}

/// Dashboard summary for the Alerts tab.
class NotificationsDashboard {
  const NotificationsDashboard({
    required this.unreadCount,
    required this.totalCount,
    required this.recent,
  });

  final int unreadCount;
  final int totalCount;
  final List<AppNotification> recent;

  double get readPercentage {
    if (totalCount <= 0) return 100;
    final read = (totalCount - unreadCount).clamp(0, totalCount);
    return (read / totalCount) * 100;
  }
}
