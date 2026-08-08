import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/shared/navigation/role_navigation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppMemberRole.fromLabel', () {
    test('normalizes display names and slugs', () {
      expect(AppMemberRole.fromLabel('Treasurer'), AppMemberRole.treasurer);
      expect(AppMemberRole.fromLabel('committee_member'),
          AppMemberRole.committeeMember);
      expect(AppMemberRole.fromLabel('Chair Person'), AppMemberRole.chairperson);
      expect(AppMemberRole.fromLabel(null), AppMemberRole.unknown);
    });
  });

  group('RoleNavigationService.quickActionsFor', () {
    test('member without chama gets onboarding shortcuts', () {
      final actions = RoleNavigationService.quickActionsFor(roleLabel: 'member');
      expect(actions.map((a) => a.id), containsAll(['create_chama', 'join_chama']));
      expect(actions.any((a) => a.id == 'schedule_meeting'), isFalse);
    });

    test('treasurer gets money actions but not invite for a chama', () {
      final actions = RoleNavigationService.quickActionsFor(
        roleLabel: 'treasurer',
        chamaId: 'c1',
      );
      final ids = actions.map((a) => a.id).toSet();
      expect(ids, contains('record_contribution'));
      expect(ids, isNot(contains('invite_members')));
      expect(ids, isNot(contains('join_requests')));
      expect(ids, contains('apply_loan'));
      expect(
        actions.firstWhere((a) => a.id == 'record_contribution').route,
        RoutePaths.recordContribution('c1'),
      );
    });

    test('secretary can invite and schedule but not approve join requests', () {
      final actions = RoleNavigationService.quickActionsFor(
        roleLabel: 'Secretary',
        chamaId: 'c1',
      );
      final ids = actions.map((a) => a.id).toSet();
      expect(ids, contains('invite_members'));
      expect(ids, contains('schedule_meeting'));
      expect(ids, isNot(contains('join_requests')));
    });

    test('chairperson can invite and manage join requests', () {
      final actions = RoleNavigationService.quickActionsFor(
        roleLabel: 'chairperson',
        chamaId: 'c1',
      );
      final ids = actions.map((a) => a.id).toSet();
      expect(ids, contains('invite_members'));
      expect(ids, contains('join_requests'));
    });

    test('regular member sees upcoming meetings instead of schedule', () {
      final actions = RoleNavigationService.quickActionsFor(
        roleLabel: 'member',
        chamaId: 'c1',
      );
      final ids = actions.map((a) => a.id).toSet();
      expect(ids, contains('upcoming_meetings'));
      expect(ids, isNot(contains('schedule_meeting')));
      expect(ids, isNot(contains('invite_members')));
    });

    test('secretary can schedule meetings', () {
      final actions = RoleNavigationService.quickActionsFor(
        roleLabel: 'Secretary',
        chamaId: 'c1',
      );
      expect(actions.map((a) => a.id), contains('schedule_meeting'));
    });
  });

  test('moreMenuActions includes reports and settings', () {
    final ids =
        RoleNavigationService.moreMenuActions().map((a) => a.id).toSet();
    expect(ids, containsAll(['meetings', 'reports', 'settings', 'profile']));
    final reports = RoleNavigationService.moreMenuActions()
        .firstWhere((a) => a.id == 'reports');
    expect(reports.subtitle, isNot(contains('Coming soon')));
    expect(reports.route, RoutePaths.reports);
  });

  test('moreMenuActions deep-links when chamaId is provided', () {
    final actions =
        RoleNavigationService.moreMenuActions(chamaId: 'chama-42');
    expect(
      actions.firstWhere((a) => a.id == 'meetings').route,
      RoutePaths.chamaMeetings('chama-42'),
    );
    expect(
      actions.firstWhere((a) => a.id == 'contributions').route,
      RoutePaths.chamaContributions('chama-42'),
    );
    expect(
      actions.firstWhere((a) => a.id == 'reports').route,
      RoutePaths.chamaReports('chama-42'),
    );
    expect(
      actions.firstWhere((a) => a.id == 'settings').route,
      RoutePaths.settings,
    );
  });
}
