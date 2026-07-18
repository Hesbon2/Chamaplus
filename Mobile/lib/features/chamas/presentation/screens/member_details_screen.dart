import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../providers/chama_providers.dart';
import '../utils/chama_ui_mapper.dart';

/// Membership profile for a single Chama member.
class MemberDetailsScreen extends ConsumerWidget {
  const MemberDetailsScreen({
    super.key,
    required this.chamaId,
    required this.membershipId,
  });

  final String chamaId;
  final String membershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMember = ref.watch(
      memberDetailsProvider(
        (chamaId: chamaId, membershipId: membershipId),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Member details')),
      body: asyncMember.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ShimmerLoader(itemCount: 4, itemHeight: 72),
        ),
        error: (error, _) => EmptyState(
          title: 'Unable to load member',
          message: error.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(
            memberDetailsProvider(
              (chamaId: chamaId, membershipId: membershipId),
            ),
          ),
        ),
        data: (member) {
          if (member == null) {
            return const EmptyState(
              title: 'Member not found',
              message: 'This membership may have been removed.',
              icon: Icons.person_off_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  children: [
                    AvatarBadge(
                      initials: member.user.initials,
                      size: 72,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      member.user.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        StatusChip(
                          label: member.role.name,
                          tone: StatusChipTone.info,
                        ),
                        StatusChip(
                          label: member.status.label,
                          tone: ChamaUiMapper.toneForStatus(member.status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ActionButton(
                label: 'Contribution summary',
                icon: Icons.savings_outlined,
                onPressed: () => context.push(
                  RoutePaths.memberContributionSummary(
                    chamaId,
                    member.user.id,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Profile'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    InfoTile(
                      title: 'Phone',
                      subtitle: member.user.phoneNumber,
                      leading: const Icon(Icons.phone_outlined),
                    ),
                    const Divider(height: 1),
                    InfoTile(
                      title: 'Role',
                      subtitle: member.role.name,
                      leading: const Icon(Icons.badge_outlined),
                    ),
                    const Divider(height: 1),
                    InfoTile(
                      title: 'Status',
                      subtitle: member.status.label,
                      leading: const Icon(Icons.verified_outlined),
                    ),
                    if (member.joinedAt != null) ...[
                      const Divider(height: 1),
                      InfoTile(
                        title: 'Joined',
                        subtitle: DateFormat('d MMM yyyy')
                            .format(member.joinedAt!.toLocal()),
                        leading: const Icon(Icons.calendar_today_outlined),
                      ),
                    ],
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
