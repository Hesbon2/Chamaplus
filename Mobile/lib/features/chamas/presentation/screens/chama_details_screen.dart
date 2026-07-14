import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Detailed overview of a single Chama.
class ChamaDetailsScreen extends ConsumerWidget {
  const ChamaDetailsScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamaDetailsControllerProvider(chamaId));
    final controller =
        ref.read(chamaDetailsControllerProvider(chamaId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.data?.chama.name ?? 'Chama details'),
      ),
      body: ApiStateBuilder<ChamaDetails>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        shimmerItemCount: 5,
        shimmerItemHeight: 88,
        builder: (context, details) => _DetailsBody(details: details),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.details});

  final ChamaDetails details;

  @override
  Widget build(BuildContext context) {
    final chama = details.chama;
    final currency = chama.currency;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarBadge(
                    initials: chama.name.isNotEmpty ? chama.name[0] : 'C',
                    size: 56,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chama.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (chama.location != null)
                          Text(
                            chama.location!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: chama.isActive ? 'Active' : 'Archived',
                    tone: chama.isActive
                        ? StatusChipTone.success
                        : StatusChipTone.neutral,
                  ),
                ],
              ),
              if (chama.description != null &&
                  chama.description!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(chama.description!),
              ],
              if (chama.inviteCode != null) ...[
                const SizedBox(height: AppSpacing.md),
                InfoTile(
                  title: 'Invite code',
                  subtitle: chama.inviteCode,
                  leading: const Icon(Icons.qr_code),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Members',
                value: '${details.memberCount}',
                icon: Icons.groups_outlined,
                onTap: () =>
                    context.push(RoutePaths.chamaMembers(chama.id)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                label: 'Pending',
                value: '${details.pendingJoinRequests}',
                subtitle: 'Join requests',
                icon: Icons.person_add_alt_1_outlined,
                accentColor: Theme.of(context).colorScheme.secondary,
                onTap: () =>
                    context.push(RoutePaths.chamaJoinRequests(chama.id)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Contributions',
                value: details.contributionsThisCycle == null
                    ? '—'
                    : '$currency ${details.contributionsThisCycle}',
                subtitle: details.activeCycleName ?? 'This cycle',
                icon: Icons.savings_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                label: 'Loans',
                value: details.outstandingLoans == null
                    ? '—'
                    : '$currency ${details.outstandingLoans}',
                subtitle: 'Outstanding',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(title: 'Upcoming meeting'),
        AppCard(
          child: details.upcomingMeeting == null
              ? Text(
                  'No upcoming meetings scheduled.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : InfoTile(
                  title: details.upcomingMeeting!.title,
                  subtitle: _formatMeeting(details.upcomingMeeting!),
                  leading: const Icon(Icons.event_outlined),
                  contentPadding: EdgeInsets.zero,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(
          title: 'Committee',
          actionLabel: 'All members',
          onAction: () => context.push(RoutePaths.chamaMembers(chama.id)),
        ),
        if (details.committeeMembers.isEmpty)
          const AppCard(
            child: Text('No committee members assigned yet.'),
          )
        else
          ...details.committeeMembers.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => context.push(
                  RoutePaths.memberDetails(chama.id, member.id),
                ),
                child: Row(
                  children: [
                    AvatarBadge(initials: member.user.initials),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.user.displayName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            member.role.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: member.role.name,
                      tone: StatusChipTone.info,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        ActionButton(
          label: 'View members',
          icon: Icons.people_outline,
          onPressed: () => context.push(RoutePaths.chamaMembers(chama.id)),
        ),
        const SizedBox(height: AppSpacing.sm),
        ActionButton(
          label: 'Join requests',
          variant: ActionButtonVariant.secondary,
          icon: Icons.inbox_outlined,
          onPressed: () =>
              context.push(RoutePaths.chamaJoinRequests(chama.id)),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  String _formatMeeting(UpcomingMeeting meeting) {
    final date = DateFormat('EEE, d MMM yyyy').format(meeting.meetingDate);
    if (meeting.startTime == null || meeting.startTime!.isEmpty) return date;
    return '$date · ${meeting.startTime}';
  }
}
