import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnvConfig.load();
    AppLogger.debug('Environment loaded: ${EnvConfig.apiBaseUrl}');
  } catch (error, stackTrace) {
    AppLogger.error('Failed to load .env', error, stackTrace);
  }

  runApp(
    const ProviderScope(
      child: ChamaplusApp(),
    ),
  );
}
