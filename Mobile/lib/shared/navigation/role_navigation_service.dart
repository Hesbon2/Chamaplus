import 'package:flutter/material.dart';

import '../../core/routing/route_paths.dart';

/// Normalized chama membership role used for navigation RBAC.
enum AppMemberRole {
  chairperson,
  treasurer,
  secretary,
  committeeMember,
  member,
  unknown;

  static AppMemberRole fromLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return AppMemberRole.unknown;
    final slug = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    switch (slug) {
      case 'chairperson':
      case 'chair':
      case 'chairman':
      case 'chairwoman':
      case 'chair_person':
        return AppMemberRole.chairperson;
      case 'treasurer':
        return AppMemberRole.treasurer;
      case 'secretary':
        return AppMemberRole.secretary;
      case 'committee_member':
      case 'committee':
        return AppMemberRole.committeeMember;
      case 'member':
        return AppMemberRole.member;
      default:
        return AppMemberRole.unknown;
    }
  }

  bool get isCommittee =>
      this == AppMemberRole.chairperson ||
      this == AppMemberRole.treasurer ||
      this == AppMemberRole.secretary ||
      this == AppMemberRole.committeeMember;

  bool get canManageMoney =>
      this == AppMemberRole.treasurer || this == AppMemberRole.chairperson;

  bool get canManageMeetings =>
      this == AppMemberRole.secretary ||
      this == AppMemberRole.chairperson ||
      this == AppMemberRole.committeeMember;
}

/// A role-aware navigation / FAB quick action.
class NavQuickAction {
  const NavQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.subtitle,
  });

  final String id;
  final String label;
  final IconData icon;
  final String route;
  final String? subtitle;
}

/// Builds quick actions and More-menu entries from the user's chama role.
class RoleNavigationService {
  RoleNavigationService._();

  /// FAB / bottom-sheet actions for [roleLabel] (slug or display name).
  static List<NavQuickAction> quickActionsFor({
    required String? roleLabel,
    String? chamaId,
  }) {
    final role = AppMemberRole.fromLabel(roleLabel);
    final actions = <NavQuickAction>[];

    if (chamaId != null && chamaId.isNotEmpty) {
      actions.add(
        NavQuickAction(
          id: 'record_contribution',
          label: role.canManageMoney ? 'Record contribution' : 'My contributions',
          subtitle: role.canManageMoney
              ? 'Log a member payment'
              : 'View contribution history',
          icon: Icons.payments_outlined,
          route: role.canManageMoney
              ? RoutePaths.recordContribution(chamaId)
              : RoutePaths.chamaContributions(chamaId),
        ),
      );
      actions.add(
        NavQuickAction(
          id: 'apply_loan',
          label: 'Apply for loan',
          subtitle: 'Start a new application',
          icon: Icons.account_balance_wallet_outlined,
          route: RoutePaths.applyLoan(chamaId),
        ),
      );
      if (role.canManageMeetings) {
        actions.add(
          NavQuickAction(
            id: 'schedule_meeting',
            label: 'Schedule meeting',
            subtitle: 'Create a governance session',
            icon: Icons.event_available_outlined,
            route: RoutePaths.scheduleMeeting(chamaId),
          ),
        );
      } else {
        actions.add(
          NavQuickAction(
            id: 'upcoming_meetings',
            label: 'Upcoming meetings',
            subtitle: 'See what is next',
            icon: Icons.event_outlined,
            route: RoutePaths.upcomingMeetings(chamaId),
          ),
        );
      }
      if (role.isCommittee) {
        actions.add(
          NavQuickAction(
            id: 'invite_members',
            label: 'Invite members',
            subtitle: 'Grow your chama',
            icon: Icons.person_add_alt_1_outlined,
            route: RoutePaths.chamaInviteMembers(chamaId),
          ),
        );
        actions.add(
          NavQuickAction(
            id: 'join_requests',
            label: 'Join requests',
            subtitle: 'Review pending applicants',
            icon: Icons.how_to_reg_outlined,
            route: RoutePaths.chamaJoinRequests(chamaId),
          ),
        );
      }
      actions.add(
        NavQuickAction(
          id: 'loan_calculator',
          label: 'Loan calculator',
          subtitle: 'Estimate repayments',
          icon: Icons.calculate_outlined,
          route: RoutePaths.loanCalculator(chamaId),
        ),
      );
    } else {
      actions.addAll(const [
        NavQuickAction(
          id: 'create_chama',
          label: 'Create chama',
          subtitle: 'Start a new savings group',
          icon: Icons.add_business_outlined,
          route: RoutePaths.createChama,
        ),
        NavQuickAction(
          id: 'join_chama',
          label: 'Join with code',
          subtitle: 'Enter an invite code',
          icon: Icons.group_add_outlined,
          route: RoutePaths.joinChama,
        ),
      ]);
    }

    actions.add(
      const NavQuickAction(
        id: 'profile',
        label: 'My profile',
        subtitle: 'Account & preferences',
        icon: Icons.person_outline,
        route: RoutePaths.profile,
      ),
    );

    return actions;
  }

  /// Destinations listed on the More tab.
  static List<NavQuickAction> moreMenuActions() {
    return const [
      NavQuickAction(
        id: 'meetings',
        label: 'Meetings & governance',
        subtitle: 'Schedules, attendance, minutes',
        icon: Icons.event_outlined,
        route: RoutePaths.meetings,
      ),
      NavQuickAction(
        id: 'contributions',
        label: 'Contributions',
        subtitle: 'Cycles, payments, history',
        icon: Icons.payments_outlined,
        route: RoutePaths.contributions,
      ),
      NavQuickAction(
        id: 'profile',
        label: 'Profile',
        subtitle: 'Your account',
        icon: Icons.person_outline,
        route: RoutePaths.profile,
      ),
      NavQuickAction(
        id: 'reports',
        label: 'Reports',
        subtitle: 'Coming soon',
        icon: Icons.assessment_outlined,
        route: RoutePaths.reports,
      ),
      NavQuickAction(
        id: 'settings',
        label: 'Settings',
        subtitle: 'App preferences',
        icon: Icons.settings_outlined,
        route: RoutePaths.settings,
      ),
    ];
  }
}
