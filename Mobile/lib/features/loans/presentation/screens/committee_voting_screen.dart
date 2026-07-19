import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/api_state.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Committee voting screen for a pending loan application.
class CommitteeVotingScreen extends ConsumerStatefulWidget {
  const CommitteeVotingScreen({
    super.key,
    required this.chamaId,
    required this.applicationId,
  });

  final String chamaId;
  final String applicationId;

  @override
  ConsumerState<CommitteeVotingScreen> createState() =>
      _CommitteeVotingScreenState();
}

class _CommitteeVotingScreenState extends ConsumerState<CommitteeVotingScreen> {
  final _commentController = TextEditingController();
  VoteDecision _decision = VoteDecision.approve;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final args = (
      chamaId: widget.chamaId,
      applicationId: widget.applicationId,
    );
    final controller =
        ref.read(committeeVotingControllerProvider(args).notifier);
    final ok = await controller.castVote(
      CastVoteInput(
        decision: _decision,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      ),
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Vote recorded.');
      context.pop();
    } else if (controller.actionError != null) {
      AppSnackbar.error(
        context,
        controller.actionError!.replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (
      chamaId: widget.chamaId,
      applicationId: widget.applicationId,
    );
    final state = ref.watch(committeeVotingControllerProvider(args));
    final controller =
        ref.read(committeeVotingControllerProvider(args).notifier);

    final votes = state.data ?? const <CommitteeVote>[];
    final approveCount =
        votes.where((v) => v.decision == VoteDecision.approve).length;
    final rejectCount =
        votes.where((v) => v.decision == VoteDecision.reject).length;
    final total = votes.length;
    final progress = total == 0 ? 0.0 : (approveCount / total) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Committee vote')),
      body: ApiStateBuilder<List<CommitteeVote>>(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.retry,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ProgressStatCard(
                title: 'Voting progress',
                subtitle: '$approveCount approve · $rejectCount reject',
                currentValue: '$total vote${total == 1 ? '' : 's'}',
                percentage: progress,
                icon: Icons.how_to_vote_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Cast your vote'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<VoteDecision>(
                      segments: const [
                        ButtonSegment(
                          value: VoteDecision.approve,
                          label: Text('Approve'),
                          icon: Icon(Icons.check),
                        ),
                        ButtonSegment(
                          value: VoteDecision.reject,
                          label: Text('Reject'),
                          icon: Icon(Icons.close),
                        ),
                        ButtonSegment(
                          value: VoteDecision.abstain,
                          label: Text('Abstain'),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                      selected: {_decision},
                      onSelectionChanged: (value) {
                        setState(() => _decision = value.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppMultilineField(
                      controller: _commentController,
                      label: 'Comment (optional)',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ActionButton(
                      label: 'Submit vote',
                      icon: Icons.send_outlined,
                      isLoading: controller.isSubmitting,
                      onPressed: controller.isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Votes cast'),
              if (votes.isEmpty)
                const EmptyState(
                  title: 'No votes yet',
                  message: 'Be the first committee member to vote.',
                  icon: Icons.how_to_vote_outlined,
                )
              else
                ...votes.map(
                  (vote) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vote.decision.label,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (vote.comment != null &&
                                    vote.comment!.isNotEmpty)
                                  Text(vote.comment!),
                                Text(
                                  LoanFormatters.date(vote.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: vote.decision.label,
                            tone: LoanUiMapper.toneForVote(vote.decision),
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
