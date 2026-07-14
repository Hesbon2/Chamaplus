import '../../domain/entities/chama.dart';
import '../../../../shared/components/status_chip.dart';

/// Helpers for presenting membership status and roles.
class ChamaUiMapper {
  ChamaUiMapper._();

  static StatusChipTone toneForStatus(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return StatusChipTone.success;
      case MembershipStatus.pending:
        return StatusChipTone.warning;
      case MembershipStatus.suspended:
        return StatusChipTone.error;
      case MembershipStatus.left:
        return StatusChipTone.neutral;
      case MembershipStatus.unknown:
        return StatusChipTone.neutral;
    }
  }
}
