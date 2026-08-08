import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../chamas/domain/entities/chama.dart';
import '../../../chamas/presentation/providers/chama_providers.dart';

/// Hub to pick a chama before opening reports.
class ReportsHubScreen extends ConsumerWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamaListControllerProvider);
    final controller = ref.read(chamaListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ApiStateBuilder<List<Chama>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        isEmpty: (chamas) => chamas.isEmpty,
        emptyTitle: 'No chamas yet',
        emptyMessage: 'Join a chama to view analytics and reports.',
        emptyIcon: Icons.assessment_outlined,
        builder: (context, chamas) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: chamas.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final chama = chamas[index];
              return ChamaHubTile(
                name: chama.name,
                subtitle: 'Open reports & analytics',
                icon: Icons.assessment_outlined,
                onTap: () => context.push(RoutePaths.chamaReports(chama.id)),
              );
            },
          );
        },
      ),
    );
  }
}
