import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime app environment (API targets + defaults).
enum AppEnvironment {
  development,
  production,
}

/// Loads and exposes environment config for the active [AppEnvironment].
///
/// Resolution order for environment:
/// 1. `--dart-define=APP_ENV=development|production`
/// 2. Release builds → [AppEnvironment.production]
/// 3. Debug / profile → [AppEnvironment.development]
///
/// Resolution order for values:
/// 1. `--dart-define=API_BASE_URL=...` (and timeout defines)
/// 2. `.env.development` or `.env.production`
/// 3. Built-in defaults
///
/// In development on the Android emulator, `localhost` / `127.0.0.1` in
/// [apiBaseUrl] is rewritten to `10.0.2.2` automatically.
class EnvConfig {
  EnvConfig._();

  static AppEnvironment _environment = AppEnvironment.development;
  static bool _loaded = false;

  static AppEnvironment get environment => _environment;

  static bool get isProduction => _environment == AppEnvironment.production;

  static bool get isDevelopment => _environment == AppEnvironment.development;

  /// Env file used for the current [environment].
  static String get envFileName =>
      _environment == AppEnvironment.production
          ? '.env.production'
          : '.env.development';

  static Future<void> load() async {
    _environment = resolveEnvironment(
      isRelease: kReleaseMode,
      appEnvDefine: const String.fromEnvironment('APP_ENV', defaultValue: ''),
    );

    try {
      await dotenv.load(fileName: envFileName);
      _loaded = true;
    } catch (_) {
      // Fall back to legacy single `.env` if present (local override).
      try {
        await dotenv.load(fileName: '.env');
        _loaded = true;
      } catch (_) {
        _loaded = false;
      }
    }
  }

  @visibleForTesting
  static AppEnvironment resolveEnvironment({
    required bool isRelease,
    String appEnvDefine = '',
  }) {
    switch (appEnvDefine.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'development':
      case 'dev':
        return AppEnvironment.development;
      default:
        return isRelease
            ? AppEnvironment.production
            : AppEnvironment.development;
    }
  }

  static String get apiBaseUrl {
    const fromDefine =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final raw = fromDefine.isNotEmpty
        ? fromDefine
        : _envOrNull('API_BASE_URL') ??
            (_environment == AppEnvironment.production
                ? 'https://chamaplus-8fzh.onrender.com/api/v1'
                : 'http://127.0.0.1:8000/api/v1');
    return rewriteLocalhostForAndroidEmulator(
      raw,
      isAndroid: defaultTargetPlatform == TargetPlatform.android,
      isWeb: kIsWeb,
      isDevelopment: isDevelopment,
    );
  }

  static int get connectTimeoutMs {
    const fromDefine =
        String.fromEnvironment('API_CONNECT_TIMEOUT_MS', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return int.tryParse(fromDefine) ?? 15000;
    }
    return int.tryParse(_envOrNull('API_CONNECT_TIMEOUT_MS') ?? '') ?? 15000;
  }

  static int get receiveTimeoutMs {
    const fromDefine =
        String.fromEnvironment('API_RECEIVE_TIMEOUT_MS', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return int.tryParse(fromDefine) ?? 15000;
    }
    return int.tryParse(_envOrNull('API_RECEIVE_TIMEOUT_MS') ?? '') ?? 15000;
  }

  /// Maps host-loopback URLs to the Android emulator host alias.
  @visibleForTesting
  static String rewriteLocalhostForAndroidEmulator(
    String url, {
    required bool isAndroid,
    required bool isWeb,
    required bool isDevelopment,
  }) {
    if (!isDevelopment || !isAndroid || isWeb) return url;
    return url
        .replaceFirst('://127.0.0.1', '://10.0.2.2')
        .replaceFirst('://localhost', '://10.0.2.2');
  }

  static String? _envOrNull(String key) {
    if (!_loaded) return null;
    try {
      final value = dotenv.env[key];
      if (value == null || value.trim().isEmpty) return null;
      return value.trim();
    } catch (_) {
      return null;
    }
  }
}
