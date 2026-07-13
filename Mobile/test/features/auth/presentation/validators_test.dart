import 'package:chamaplus_mobile/features/auth/presentation/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneValidator', () {
    test('accepts local format', () {
      expect(PhoneValidator.validate('0712345678'), isNull);
    });

    test('rejects invalid numbers', () {
      expect(PhoneValidator.validate('0812345678'), isNotNull);
    });

    test('normalizes to E.164', () {
      expect(PhoneValidator.normalize('0712345678'), '+254712345678');
    });
  });

  group('PasswordValidator', () {
    test('requires minimum length', () {
      expect(PasswordValidator.validate('short'), isNotNull);
      expect(PasswordValidator.validate('longenough'), isNull);
    });
  });
}
