import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/cache/offline_cache_store.dart';
import 'core/config/env_config.dart';
import 'core/storage/preferences_storage.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();

  try {
    await EnvConfig.load();
    AppLogger.debug(
      'Environment loaded: ${EnvConfig.environment.name} '
      '(${EnvConfig.envFileName}) → ${EnvConfig.apiBaseUrl}',
    );
  } catch (error, stackTrace) {
    AppLogger.error('Failed to load .env', error, stackTrace);
  }

  final preferences = await PreferencesStorage.create();
  final offlineCache = await OfflineCacheStore.create();

  runApp(
    ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(preferences),
        offlineCacheStoreProvider.overrideWithValue(offlineCache),
      ],
      child: const ChamaplusApp(),
    ),
  );
}

void _installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FlutterError',
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught platform error', error, stack);
    return true;
  };

  ErrorWidget.builder = (details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return const Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Something went wrong displaying this screen.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
}
