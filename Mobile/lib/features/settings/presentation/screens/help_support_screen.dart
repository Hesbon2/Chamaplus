import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/safe_clipboard.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';

/// In-app help content and support contact.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionHeader(title: 'Common questions'),
          const SizedBox(height: AppSpacing.sm),
          const SettingsTile(
            title: 'How do I join a chama?',
            subtitle:
                'Ask a treasurer for an invite code, then use Join chama from Home or Welcome.',
            icon: Icons.group_add_outlined,
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const SettingsTile(
            title: 'How are contributions recorded?',
            subtitle:
                'Treasurers record payments under Contributions. Members can view history anytime.',
            icon: Icons.payments_outlined,
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const SettingsTile(
            title: 'Who can approve loans?',
            subtitle:
                'Committee members vote; chairperson/treasurer complete disbursement steps.',
            icon: Icons.account_balance_outlined,
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Contact'),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Email support',
            subtitle: AppConstants.supportEmail,
            icon: Icons.email_outlined,
            trailing: const Icon(Icons.copy_outlined),
            onTap: () async {
              final copied = await SafeClipboard.copyPublicText(
                AppConstants.supportEmail,
              );
              if (context.mounted) {
                AppSnackbar.info(
                  context,
                  copied ? 'Support email copied.' : 'Could not copy.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
