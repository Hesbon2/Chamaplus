import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_providers.dart';
import '../utils/meeting_ui_mapper.dart';
import '../widgets/meeting_tiles.dart';

/// Create / edit / approve meeting minutes.
class MeetingMinutesScreen extends ConsumerStatefulWidget {
  const MeetingMinutesScreen({
    super.key,
    required this.chamaId,
    required this.meetingId,
  });

  final String chamaId;
  final String meetingId;

  @override
  ConsumerState<MeetingMinutesScreen> createState() =>
      _MeetingMinutesScreenState();
}

class _MeetingMinutesScreenState extends ConsumerState<MeetingMinutesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();
  final _resolutionsController = TextEditingController();
  final _actionTaskController = TextEditingController();
  final _actionOwnerController = TextEditingController();
  final List<MeetingActionItem> _actionItems = [];
  bool _seeded = false;

  @override
  void dispose() {
    _minutesController.dispose();
    _resolutionsController.dispose();
    _actionTaskController.dispose();
    _actionOwnerController.dispose();
    super.dispose();
  }

  void _seedFrom(MeetingMinutes minutes) {
    _minutesController.text = minutes.minutes;
    _resolutionsController.text = minutes.resolutions.join('\n');
    _actionItems
      ..clear()
      ..addAll(minutes.actionItems);
  }

  void _addActionItem() {
    final task = _actionTaskController.text.trim();
    if (task.isEmpty) return;
    setState(() {
      _actionItems.add(
        MeetingActionItem(
          task: task,
          owner: _actionOwnerController.text.trim().isEmpty
              ? null
              : _actionOwnerController.text.trim(),
        ),
      );
      _actionTaskController.clear();
      _actionOwnerController.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final args = (chamaId: widget.chamaId, meetingId: widget.meetingId);
    final controller =
        ref.read(meetingMinutesControllerProvider(args).notifier);
    final resolutions = _resolutionsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ok = await controller.save(
      MeetingMinutesInput(
        minutes: _minutesController.text.trim(),
        resolutions: resolutions,
        actionItems: List.of(_actionItems),
      ),
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Minutes saved.');
    } else {
      final err = ref.read(meetingMinutesControllerProvider(args)).errorMessage;
      AppSnackbar.error(
        context,
        (err == null || err.isEmpty)
            ? 'Could not save minutes.'
            : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }

  Future<void> _approve() async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Approve minutes?',
      message: 'Only the chairperson can approve. This cannot be undone easily.',
      confirmLabel: 'Approve',
    );
    if (!confirmed) return;

    final args = (chamaId: widget.chamaId, meetingId: widget.meetingId);
    final controller =
        ref.read(meetingMinutesControllerProvider(args).notifier);
    final ok = await controller.approve();
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Minutes approved.');
    } else {
      final err = ref.read(meetingMinutesControllerProvider(args)).errorMessage;
      AppSnackbar.error(
        context,
        (err == null || err.isEmpty)
            ? 'Could not approve minutes.'
            : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (chamaId: widget.chamaId, meetingId: widget.meetingId);
    final state = ref.watch(meetingMinutesControllerProvider(args));

    if (!_seeded && state.minutes != null && !state.isLoading) {
      _seeded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _seedFrom(state.minutes!));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meeting minutes')),
      body: state.isLoading
          ? const ShimmerLoader(itemCount: 5)
          : state.errorMessage != null && state.minutes == null && !_seeded
              ? EmptyState(
                  title: 'Could not load minutes',
                  message: state.errorMessage!,
                  icon: Icons.error_outline,
                  actionLabel: 'Retry',
                  onAction: () => ref
                      .read(meetingMinutesControllerProvider(args).notifier)
                      .load(),
                )
              : SafeArea(
              child: AppForm(
                formKey: _formKey,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ListView(
                  children: [
                    if (state.minutes != null)
                      TimelineCard(
                        title: 'Minutes status',
                        steps: [
                          TimelineStep(
                            title: 'Drafted',
                            isCompleted: true,
                            isActive: !state.minutes!.approved,
                            timestamp: MeetingFormatters.shortDate(
                              state.minutes!.createdAt ?? DateTime.now(),
                            ),
                          ),
                          TimelineStep(
                            title: 'Approved',
                            isCompleted: state.minutes!.approved,
                            isActive: state.minutes!.approved,
                            timestamp: state.minutes!.approvedAt == null
                                ? null
                                : MeetingFormatters.shortDate(
                                    state.minutes!.approvedAt!,
                                  ),
                          ),
                        ],
                      ),
                    if (state.minutes != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      StatusChip(
                        label: state.minutes!.approved
                            ? 'Approved'
                            : 'Awaiting approval',
                        tone: state.minutes!.approved
                            ? StatusChipTone.success
                            : StatusChipTone.warning,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    FormSection(
                      title: 'Minutes',
                      children: [
                        AppMultilineField(
                          controller: _minutesController,
                          label: 'Minutes body',
                          maxLines: 8,
                          validator: (v) =>
                              AppValidators.required(v, field: 'Minutes'),
                          enabled: !(state.minutes?.approved ?? false),
                        ),
                        AppMultilineField(
                          controller: _resolutionsController,
                          label: 'Resolutions (one per line)',
                          maxLines: 4,
                          enabled: !(state.minutes?.approved ?? false),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const SectionHeader(title: 'Action items'),
                    if (!(state.minutes?.approved ?? false)) ...[
                      AppTextField(
                        controller: _actionTaskController,
                        label: 'Task',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _actionOwnerController,
                        label: 'Owner (optional)',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ActionButton(
                        label: 'Add action item',
                        icon: Icons.add,
                        variant: ActionButtonVariant.secondary,
                        onPressed: _addActionItem,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (_actionItems.isEmpty)
                      const EmptyState(
                        title: 'No action items yet',
                        message: 'Add tasks below to track follow-ups.',
                        icon: Icons.checklist_outlined,
                      )
                    else
                      ..._actionItems.map(
                        (item) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ActionItemTile(item: item),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    if (!(state.minutes?.approved ?? false)) ...[
                      AppSubmitButton(
                        label: state.exists ? 'Update minutes' : 'Save minutes',
                        formKey: _formKey,
                        isLoading: state.isSaving,
                        onSubmit: state.isSaving ? null : _save,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (state.exists)
                        ActionButton(
                          label: 'Approve minutes',
                          icon: Icons.verified_outlined,
                          isLoading: state.isApproving,
                          onPressed: state.isApproving ? null : _approve,
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
