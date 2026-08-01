import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';

/// Device-side notification preference toggles.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationPreferencesProvider);
    final controller = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ApiStateBuilder<NotificationPreferences>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, prefs) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const InfoTile(
                title: 'Alert preferences',
                subtitle:
                    'These control which in-app categories you care about. '
                    'Server-side push preferences will sync here when available.',
                dense: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Contributions'),
                      subtitle: const Text('Payments and cycle reminders'),
                      value: prefs.contributions,
                      onChanged: controller.setContributions,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Loans'),
                      subtitle: const Text('Applications, votes, and repayments'),
                      value: prefs.loans,
                      onChanged: controller.setLoans,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Meetings'),
                      subtitle: const Text('Schedules, attendance, and minutes'),
                      value: prefs.meetings,
                      onChanged: controller.setMeetings,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Announcements'),
                      subtitle: const Text('General chama updates'),
                      value: prefs.announcements,
                      onChanged: controller.setAnnouncements,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
