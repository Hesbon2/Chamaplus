import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';
import '../utils/contribution_ui_mapper.dart';

/// Read-only detail view for a recorded contribution.
class ContributionDetailsScreen extends ConsumerWidget {
  const ContributionDetailsScreen({
    super.key,
    required this.chamaId,
    required this.contributionId,
  });

  final String chamaId;
  final String contributionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (chamaId: chamaId, contributionId: contributionId);
    final state = ref.watch(contributionDetailsControllerProvider(args));
    final controller =
        ref.read(contributionDetailsControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Contribution details')),
      body: ApiStateBuilder<Contribution>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, contribution) {
          final recorded = DateFormat('EEE, d MMM yyyy · HH:mm')
              .format(contribution.recordedAt.toLocal());

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${contribution.currency} ${contribution.amount}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StatusChip(
                      label: contribution.paymentMethod.label,
                      tone: ContributionUiMapper.toneForPayment(
                        contribution.paymentMethod,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InfoTile(
                      title: 'Reference',
                      subtitle: contribution.reference,
                      leading: const Icon(Icons.tag),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Recorded at',
                      subtitle: recorded,
                      leading: const Icon(Icons.schedule),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Member ID',
                      subtitle: contribution.memberId,
                      leading: const Icon(Icons.person_outline),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Cycle ID',
                      subtitle: contribution.cycleId,
                      leading: const Icon(Icons.loop),
                      contentPadding: EdgeInsets.zero,
                    ),
                    InfoTile(
                      title: 'Recorded by',
                      subtitle: contribution.recordedBy,
                      leading: const Icon(Icons.edit_note),
                      contentPadding: EdgeInsets.zero,
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
