import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';

/// App version and about copy.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const InfoTile(
            title: 'Mission',
            subtitle:
                'ChamaPlus helps Kenyan savings groups manage contributions, '
                'loans, meetings, and reports with clear roles and transparency.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const SettingsTile(
            title: 'Made for chamas',
            subtitle: 'Built for treasurers, chairpersons, secretaries, and members.',
            icon: Icons.groups_outlined,
            trailing: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
