import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/components/components.dart';

/// Theme mode selection with persistence.
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ThemeSelector(
            value: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setThemeMode(mode),
          ),
          const SizedBox(height: AppSpacing.md),
          const InfoTile(
            title: 'Tip',
            subtitle:
                'System follows your device setting. Your choice is saved on this device.',
            dense: true,
          ),
        ],
      ),
    );
  }
}
