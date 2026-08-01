import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/auth/session_cleanup.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Settings home — hub for profile, security, appearance, and support.
class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ProfileHeader(
            displayName: user?.displayName ?? 'Member',
            subtitle: user?.phoneNumber,
            onTap: () => context.push(RoutePaths.profile),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Account'),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Profile',
            subtitle: 'Name, email, and member details',
            icon: Icons.person_outline,
            onTap: () => context.push(RoutePaths.profile),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Edit profile',
            subtitle: 'Update your personal information',
            icon: Icons.edit_outlined,
            onTap: () => context.push(RoutePaths.editProfile),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Security',
            subtitle: 'Change password',
            icon: Icons.lock_outline,
            onTap: () => context.push(RoutePaths.settingsSecurity),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Preferences'),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Appearance',
            subtitle: 'System, light, or dark theme',
            icon: Icons.palette_outlined,
            onTap: () => context.push(RoutePaths.settingsAppearance),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Notifications',
            subtitle: 'Contribution, loan, and meeting alerts',
            icon: Icons.notifications_outlined,
            onTap: () => context.push(RoutePaths.settingsNotifications),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Support'),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Help & support',
            subtitle: 'FAQs and contact options',
            icon: Icons.help_outline,
            onTap: () => context.push(RoutePaths.settingsHelp),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'About',
            subtitle: 'Version and legal',
            icon: Icons.info_outline,
            onTap: () => context.push(RoutePaths.settingsAbout),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Developer'),
            const SizedBox(height: AppSpacing.sm),
            SettingsTile(
              title: 'Diagnostics',
              subtitle: 'Debug-only environment details',
              icon: Icons.bug_report_outlined,
              onTap: () => context.push(RoutePaths.settingsDiagnostics),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          ActionButton(
            label: 'Sign out',
            icon: Icons.logout,
            isDestructive: true,
            onPressed: () async {
              final confirmed = await showAppConfirmationDialog(
                context: context,
                title: 'Sign out?',
                message: 'You will need to sign in again to access your chamas.',
                confirmLabel: 'Sign out',
                isDestructive: true,
              );
              if (confirmed != true) return;
              await performSecureLogout(ref);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
