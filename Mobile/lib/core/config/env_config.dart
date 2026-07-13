import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and exposes environment variables from `.env`.
class EnvConfig {
  EnvConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api/v1';

  static int get connectTimeoutMs =>
      int.tryParse(dotenv.env['API_CONNECT_TIMEOUT_MS'] ?? '') ?? 15000;

  static int get receiveTimeoutMs =>
      int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT_MS'] ?? '') ?? 15000;
}
