import '../../../../shared/components/components.dart';
import '../../domain/entities/contribution.dart';

/// Maps contribution domain enums to design-system chip tones.
class ContributionUiMapper {
  ContributionUiMapper._();

  static StatusChipTone toneForCycle(CycleStatus status) {
    switch (status) {
      case CycleStatus.open:
        return StatusChipTone.success;
      case CycleStatus.closed:
        return StatusChipTone.neutral;
      case CycleStatus.unknown:
        return StatusChipTone.warning;
    }
  }

  static StatusChipTone toneForPayment(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return StatusChipTone.info;
      case PaymentMethod.bank:
        return StatusChipTone.info;
      case PaymentMethod.cash:
        return StatusChipTone.success;
      case PaymentMethod.unknown:
        return StatusChipTone.neutral;
    }
  }
}
