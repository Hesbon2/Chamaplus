import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';

/// Mutation state for membership role / status updates.
class ManageMembershipState {
  const ManageMembershipState({
    this.isSubmitting = false,
    this.errorMessage,
    this.membership,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final Membership? membership;

  ManageMembershipState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    Membership? membership,
    bool clearError = false,
  }) {
    return ManageMembershipState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      membership: membership ?? this.membership,
    );
  }
}

/// Chairperson actions: change role and membership status.
class ManageMembershipController
    extends StateNotifier<ManageMembershipState> {
  ManageMembershipController(this._repository)
      : super(const ManageMembershipState());

  final ChamaRepository _repository;

  Future<Membership?> updateRole({
    required String membershipId,
    required String role,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final membership = await _repository.updateMembershipRole(
        membershipId: membershipId,
        role: role,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, membership: membership);
      return membership;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<Membership?> updateStatus({
    required String membershipId,
    required MembershipStatus status,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final membership = await _repository.updateMembershipStatus(
        membershipId: membershipId,
        status: status,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, membership: membership);
      return membership;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }
}
