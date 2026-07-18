import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Form submission state for recording a contribution.
class RecordContributionState {
  const RecordContributionState({
    this.isSubmitting = false,
    this.errorMessage,
    this.recorded,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final Contribution? recorded;

  RecordContributionState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    Contribution? recorded,
    bool clearError = false,
    bool clearRecorded = false,
  }) {
    return RecordContributionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recorded: clearRecorded ? null : (recorded ?? this.recorded),
    );
  }
}

class RecordContributionController
    extends StateNotifier<RecordContributionState> {
  RecordContributionController({
    required ContributionRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId,
        super(const RecordContributionState());

  final ContributionRepository _repository;
  final String _chamaId;

  Future<Contribution?> submit(RecordContributionInput input) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearRecorded: true,
    );
    try {
      final recorded = await _repository.recordContribution(
        chamaId: _chamaId,
        input: input,
      );
      state = state.copyWith(isSubmitting: false, recorded: recorded);
      return recorded;
    } on AppException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to record contribution.',
      );
      return null;
    }
  }
}
