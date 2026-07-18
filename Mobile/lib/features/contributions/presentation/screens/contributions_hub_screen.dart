import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../chamas/domain/entities/chama.dart';
import '../../../chamas/presentation/providers/chama_providers.dart';

/// Entry point from dashboard — pick a Chama to manage contributions.
class ContributionsHubScreen extends ConsumerWidget {
  const ContributionsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamaListControllerProvider);
    final controller = ref.read(chamaListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: ApiStateBuilder<List<Chama>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        emptyTitle: 'No chamas yet',
        emptyMessage: 'Join a chama to view and record contributions.',
        emptyIcon: Icons.groups_outlined,
        builder: (context, chamas) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: chamas.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final chama = chamas[index];
              return AppCard(
                onTap: () => context.push(
                  RoutePaths.chamaContributions(chama.id),
                ),
                child: Row(
                  children: [
                    AvatarBadge(
                      initials:
                          chama.name.isNotEmpty ? chama.name[0] : 'C',
                      icon: Icons.savings_outlined,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chama.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Open contribution dashboard',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
