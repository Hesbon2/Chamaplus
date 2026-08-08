import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/errors/error_handler.dart';
import 'package:chamaplus_mobile/core/utils/logger.dart';
import 'package:chamaplus_mobile/core/utils/safe_clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorHandler', () {
    const handler = ErrorHandler();

    test('maps connection errors to NetworkException', () {
      final result = handler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(result, isA<NetworkException>());
      expect(result.message.toLowerCase(), contains('internet'));
    });

    test('maps timeouts', () {
      final result = handler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(result, isA<TimeoutException>());
    });

    test('maps 401 to session message', () {
      final result = handler.handle(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 401,
            data: {'message': 'nope'},
          ),
        ),
      );
      expect(result.message.toLowerCase(), contains('session'));
    });
  });

  group('SafeClipboard', () {
    test('rejects JWT-like payloads', () async {
      final ok = await SafeClipboard.copyPublicText(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.signature',
      );
      expect(ok, isFalse);
    });

    test('allows support email', () async {
      final ok = await SafeClipboard.copyPublicText('support@chamaplus.app');
      expect(ok, isTrue);
    });
  });

  group('AppLogger', () {
    test('debug is a no-op outside debug tooling contract', () {
      // Ensures call does not throw; redaction exercised in debug mode only.
      expect(() => AppLogger.debug('Bearer supersecrettoken'), returnsNormally);
      expect(kDebugMode, isTrue);
    });
  });
}
