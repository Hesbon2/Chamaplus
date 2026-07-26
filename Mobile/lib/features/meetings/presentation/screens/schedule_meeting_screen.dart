import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/meeting.dart';
import '../controllers/meeting_controllers.dart';
import '../providers/meeting_providers.dart';

/// Form to schedule a new meeting.
class ScheduleMeetingScreen extends ConsumerStatefulWidget {
  const ScheduleMeetingScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<ScheduleMeetingScreen> createState() =>
      _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends ConsumerState<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  MeetingType _type = MeetingType.ordinary;
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _start == null) {
      AppSnackbar.error(context, 'Pick a date and start time.');
      return;
    }

    try {
      final meeting =
          await ref.read(scheduleMeetingControllerProvider.notifier).submit(
                chamaId: widget.chamaId,
                input: ScheduleMeetingInput(
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  meetingType: _type,
                  venue: _venueController.text.trim(),
                  meetingDate: _date!,
                  startTime: _formatTime(_start!),
                  endTime: _end == null ? null : _formatTime(_end!),
                ),
              );
      if (!mounted) return;
      if (meeting == null) {
        final err = ref.read(scheduleMeetingControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (err == null || err.isEmpty)
              ? 'Could not schedule meeting.'
              : err.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }
      AppSnackbar.success(context, 'Meeting scheduled.');
      context.go(RoutePaths.meetingDetails(widget.chamaId, meeting.id));
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleMeetingControllerProvider);

    ref.listen<ScheduleMeetingState>(scheduleMeetingControllerProvider,
        (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppSnackbar.error(
          context,
          next.errorMessage!.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule meeting')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Meeting details',
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    validator: (v) =>
                        AppValidators.required(v, field: 'Title'),
                  ),
                  AppDropdown<MeetingType>(
                    label: 'Type',
                    value: _type,
                    items: MeetingType.values
                        .where((t) => t != MeetingType.unknown)
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                  ),
                  AppTextField(
                    controller: _venueController,
                    label: 'Venue',
                    validator: (v) =>
                        AppValidators.required(v, field: 'Venue'),
                  ),
                  AppMultilineField(
                    controller: _descriptionController,
                    label: 'Description (optional)',
                  ),
                  AppDatePicker(
                    label: 'Meeting date',
                    initialValue: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    onChanged: (v) => setState(() => _date = v),
                  ),
                  AppTimePicker(
                    label: 'Start time',
                    initialValue: _start,
                    onChanged: (v) => setState(() => _start = v),
                  ),
                  AppTimePicker(
                    label: 'End time (optional)',
                    initialValue: _end,
                    isRequired: false,
                    onChanged: (v) => setState(() => _end = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Schedule meeting',
                formKey: _formKey,
                isLoading: state.isSubmitting,
                onSubmit: state.isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
