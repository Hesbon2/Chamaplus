import 'package:chamaplus_mobile/core/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig.resolveEnvironment', () {
    test('dart-define production wins over debug', () {
      expect(
        EnvConfig.resolveEnvironment(
          isRelease: false,
          appEnvDefine: 'production',
        ),
        AppEnvironment.production,
      );
    });

    test('dart-define development wins over release', () {
      expect(
        EnvConfig.resolveEnvironment(
          isRelease: true,
          appEnvDefine: 'dev',
        ),
        AppEnvironment.development,
      );
    });

    test('release defaults to production', () {
      expect(
        EnvConfig.resolveEnvironment(isRelease: true),
        AppEnvironment.production,
      );
    });

    test('debug defaults to development', () {
      expect(
        EnvConfig.resolveEnvironment(isRelease: false),
        AppEnvironment.development,
      );
    });
  });

  group('EnvConfig.rewriteLocalhostForAndroidEmulator', () {
    test('rewrites loopback on Android development', () {
      expect(
        EnvConfig.rewriteLocalhostForAndroidEmulator(
          'http://127.0.0.1:8000/api/v1',
          isAndroid: true,
          isWeb: false,
          isDevelopment: true,
        ),
        'http://10.0.2.2:8000/api/v1',
      );
      expect(
        EnvConfig.rewriteLocalhostForAndroidEmulator(
          'http://localhost:8000/api/v1',
          isAndroid: true,
          isWeb: false,
          isDevelopment: true,
        ),
        'http://10.0.2.2:8000/api/v1',
      );
    });

    test('does not rewrite in production or non-Android', () {
      const url = 'http://127.0.0.1:8000/api/v1';
      expect(
        EnvConfig.rewriteLocalhostForAndroidEmulator(
          url,
          isAndroid: true,
          isWeb: false,
          isDevelopment: false,
        ),
        url,
      );
      expect(
        EnvConfig.rewriteLocalhostForAndroidEmulator(
          url,
          isAndroid: false,
          isWeb: false,
          isDevelopment: true,
        ),
        url,
      );
    });
  });
}
