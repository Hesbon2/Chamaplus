import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

/// Debug-only diagnostics. Never registered or linked in release builds.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(kDebugMode, 'DiagnosticsScreen must not be used in release');

    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final gate = ref.watch(onboardingGateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const InfoTile(
            title: 'Debug build',
            subtitle: 'This screen is only available when kDebugMode is true.',
            dense: true,
          ),
          const SizedBox(height: AppSpacing.md),
          const SettingsTile(
            title: 'App version',
            subtitle: AppConstants.appVersion,
            icon: Icons.tag,
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Environment',
            subtitle: EnvConfig.environment.name,
            icon: Icons.tune,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'API base URL',
            subtitle: EnvConfig.apiBaseUrl,
            icon: Icons.cloud_outlined,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Theme mode',
            subtitle: themeMode.name,
            icon: Icons.palette_outlined,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Auth status',
            subtitle: auth.status.name,
            icon: Icons.verified_user_outlined,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'User id',
            subtitle: auth.user?.id ?? '—',
            icon: Icons.badge_outlined,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Onboarding gate',
            subtitle: gate.name,
            icon: Icons.flag_outlined,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Platform',
            subtitle: defaultTargetPlatform.name,
            icon: Icons.phone_android_outlined,
            trailing: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
