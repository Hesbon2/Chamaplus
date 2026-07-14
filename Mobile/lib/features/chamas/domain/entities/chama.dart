/// Membership lifecycle status matching the Django API.
enum MembershipStatus {
  pending,
  active,
  suspended,
  left,
  unknown;

  static MembershipStatus fromApi(String? value) {
    switch (value) {
      case 'pending':
        return MembershipStatus.pending;
      case 'active':
        return MembershipStatus.active;
      case 'suspended':
        return MembershipStatus.suspended;
      case 'left':
        return MembershipStatus.left;
      default:
        return MembershipStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case MembershipStatus.pending:
        return 'pending';
      case MembershipStatus.active:
        return 'active';
      case MembershipStatus.suspended:
        return 'suspended';
      case MembershipStatus.left:
        return 'left';
      case MembershipStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case MembershipStatus.pending:
        return 'Pending';
      case MembershipStatus.active:
        return 'Active';
      case MembershipStatus.suspended:
        return 'Suspended';
      case MembershipStatus.left:
        return 'Left';
      case MembershipStatus.unknown:
        return 'Unknown';
    }
  }
}

/// A Chama savings group.
class Chama {
  const Chama({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.currency,
    this.inviteCode,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? location;
  final String currency;
  final String? inviteCode;
  final bool isActive;
  final DateTime? createdAt;
}

/// Nested role summary on a membership.
class MemberRole {
  const MemberRole({
    required this.id,
    required this.slug,
    required this.name,
  });

  final String id;
  final String slug;
  final String name;

  bool get isCommittee => const {
        'chairperson',
        'treasurer',
        'secretary',
        'committee_member',
      }.contains(slug);
}

/// Nested user summary on a membership.
class MemberUser {
  const MemberUser({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;

  String get displayName {
    final parts = <String>[
      if (firstName != null && firstName!.trim().isNotEmpty) firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty) lastName!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return phoneNumber;
  }

  String get initials {
    final first = firstName?.trim();
    final last = lastName?.trim();
    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first != null && first.isNotEmpty) {
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) return digits.substring(digits.length - 2);
    return '?';
  }
}

/// Chama membership linking a user to a group.
class Membership {
  const Membership({
    required this.id,
    required this.user,
    required this.role,
    required this.status,
    this.joinedAt,
    this.createdAt,
  });

  final String id;
  final MemberUser user;
  final MemberRole role;
  final MembershipStatus status;
  final DateTime? joinedAt;
  final DateTime? createdAt;
}

/// Upcoming meeting summary for a Chama.
class UpcomingMeeting {
  const UpcomingMeeting({
    required this.id,
    required this.title,
    required this.meetingDate,
    this.startTime,
  });

  final String id;
  final String title;
  final DateTime meetingDate;
  final String? startTime;
}

/// Aggregated chama detail for the details screen.
class ChamaDetails {
  const ChamaDetails({
    required this.chama,
    required this.memberCount,
    required this.pendingJoinRequests,
    required this.committeeMembers,
    this.upcomingMeeting,
    this.activeCycleName,
    this.contributionsThisCycle,
    this.outstandingLoans,
  });

  final Chama chama;
  final int memberCount;
  final int pendingJoinRequests;
  final List<Membership> committeeMembers;
  final UpcomingMeeting? upcomingMeeting;
  final String? activeCycleName;
  final String? contributionsThisCycle;
  final String? outstandingLoans;
}

/// Generic paginated list result.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.count,
    this.nextPage,
    this.hasMore = false,
  });

  final List<T> items;
  final int count;
  final int? nextPage;
  final bool hasMore;
}
