import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Placeholder screen for feature modules not yet implemented.
class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$title coming soon',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This module will be available in a future release.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
