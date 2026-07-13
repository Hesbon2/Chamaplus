import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/token_response_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/user_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chamaplus_mobile/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_secure_storage.dart';
import '../helpers/fake_auth_remote_data_source.dart';

void main() {
  late FakeSecureStorage secureStorage;
  late FakeAuthRemoteDataSource authApi;
  late AuthRepositoryImpl repository;

  final sampleUserDto = UserDto(
    id: 'user-1',
    phoneNumber: '+254712345678',
    firstName: 'Jane',
    lastName: 'Doe',
    isStaff: false,
    dateJoined: DateTime.parse('2026-07-12T10:00:00+03:00'),
  );

  setUp(() {
    secureStorage = FakeSecureStorage();
    authApi = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      authApi: authApi,
      secureStorage: secureStorage,
    );
  });

  group('AuthRepositoryImpl', () {
    test('login stores tokens and returns user', () async {
      authApi.loginResponse = const TokenResponseDto(
        access: 'access-token',
        refresh: 'refresh-token',
      );
      authApi.userResponse = sampleUserDto;

      final user = await repository.login(
        phoneNumber: '0712345678',
        password: 'password123',
      );

      expect(user.id, 'user-1');
      expect(await secureStorage.readAccessToken(), 'access-token');
      expect(await secureStorage.readRefreshToken(), 'refresh-token');
    });

    test('restoreSession returns null when no tokens stored', () async {
      final user = await repository.restoreSession();
      expect(user, isNull);
    });

    test('restoreSession returns user when tokens exist and profile loads',
        () async {
      await secureStorage.writeAccessToken('access');
      await secureStorage.writeRefreshToken('refresh');
      authApi.userResponse = sampleUserDto;

      final user = await repository.restoreSession();

      expect(user, isA<User>());
      expect(user?.phoneNumber, '+254712345678');
    });

    test('restoreSession clears tokens when profile fetch fails', () async {
      await secureStorage.writeAccessToken('access');
      await secureStorage.writeRefreshToken('refresh');
      authApi.getCurrentUserError =
          const ServerException(message: 'Unauthorized');

      final user = await repository.restoreSession();

      expect(user, isNull);
      expect(await secureStorage.readAccessToken(), isNull);
      expect(await secureStorage.readRefreshToken(), isNull);
    });

    test('logout clears tokens', () async {
      await secureStorage.writeRefreshToken('refresh-token');

      await repository.logout();

      expect(authApi.logoutCalled, isTrue);
      expect(await secureStorage.readRefreshToken(), isNull);
      expect(await secureStorage.readAccessToken(), isNull);
    });

    test('login propagates server errors', () async {
      authApi.loginError =
          const ServerException(message: 'Invalid credentials');

      expect(
        () => repository.login(
          phoneNumber: '0712345678',
          password: 'wrong',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
