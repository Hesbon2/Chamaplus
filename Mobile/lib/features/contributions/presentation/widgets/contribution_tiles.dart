import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';
import '../utils/contribution_ui_mapper.dart';

/// Shared list tile for a contribution payment row.
class ContributionListTile extends StatelessWidget {
  const ContributionListTile({
    super.key,
    required this.contribution,
    this.onTap,
    this.subtitle,
  });

  final Contribution contribution;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy · HH:mm').format(
      contribution.recordedAt.toLocal(),
    );

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarBadge(
            initials: contribution.reference.isNotEmpty
                ? contribution.reference[0].toUpperCase()
                : 'C',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${contribution.currency} ${contribution.amount}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  subtitle ?? contribution.reference,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          StatusChip(
            label: contribution.paymentMethod.label,
            tone: ContributionUiMapper.toneForPayment(
              contribution.paymentMethod,
            ),
            compact: true,
          ),
        ],
      ),
    );
  }
}

/// Shared list tile for a contribution cycle row.
class CycleListTile extends StatelessWidget {
  const CycleListTile({
    super.key,
    required this.cycle,
    this.onTap,
  });

  final ContributionCycle cycle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final range =
        '${DateFormat('d MMM yyyy').format(cycle.startDate)} – '
        '${DateFormat('d MMM yyyy').format(cycle.endDate)}';

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarBadge(
            initials: cycle.name.isNotEmpty ? cycle.name[0] : 'C',
            icon: Icons.event_repeat_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cycle.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${cycle.frequency.label} · ${cycle.contributionAmount}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(range, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          StatusChip(
            label: cycle.status.label,
            tone: ContributionUiMapper.toneForCycle(cycle.status),
            compact: true,
          ),
        ],
      ),
    );
  }
}
