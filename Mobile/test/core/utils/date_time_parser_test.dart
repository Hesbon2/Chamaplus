import 'package:chamaplus_mobile/core/utils/date_time_parser.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/user_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeApiDateTime converts Django offset format', () {
    expect(
      normalizeApiDateTime('2026-08-28T21:30:24+0300'),
      '2026-08-28T21:30:24+03:00',
    );
  });

  test('parseApiDateTime parses Django datetime strings', () {
    final parsed = parseApiDateTime('2026-08-28T21:30:24+0300');
    expect(parsed, isNotNull);
    expect(parsed!.year, 2026);
    expect(parsed.month, 8);
    expect(parsed.day, 28);
  });

  test('UserDto.fromJson parses register/me payload', () {
    final dto = UserDto.fromJson({
      'id': '1e750c84-5879-45eb-a09b-31713b671b85',
      'phone_number': '+254700000099',
      'email': '',
      'first_name': 'Test',
      'last_name': 'User',
      'is_staff': false,
      'date_joined': '2026-08-28T21:30:24+0300',
      'last_login': null,
    });

    expect(dto.phoneNumber, '+254700000099');
    expect(dto.firstName, 'Test');
    expect(dto.dateJoined.year, 2026);
  });
}
