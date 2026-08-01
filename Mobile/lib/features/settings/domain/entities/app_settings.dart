/// Local notification preference toggles (device-side until backend ships).
class NotificationPreferences {
  const NotificationPreferences({
    this.contributions = true,
    this.loans = true,
    this.meetings = true,
    this.announcements = true,
  });

  final bool contributions;
  final bool loans;
  final bool meetings;
  final bool announcements;

  NotificationPreferences copyWith({
    bool? contributions,
    bool? loans,
    bool? meetings,
    bool? announcements,
  }) {
    return NotificationPreferences(
      contributions: contributions ?? this.contributions,
      loans: loans ?? this.loans,
      meetings: meetings ?? this.meetings,
      announcements: announcements ?? this.announcements,
    );
  }
}

/// Aggregate settings snapshot for the Settings module.
class AppSettings {
  const AppSettings({
    required this.notificationPreferences,
  });

  final NotificationPreferences notificationPreferences;
}
