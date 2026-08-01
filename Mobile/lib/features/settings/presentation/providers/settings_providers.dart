import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/api_state.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../controllers/settings_controllers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(preferencesStorageProvider));
});

final notificationPreferencesProvider = StateNotifierProvider.autoDispose<
    NotificationPreferencesController,
    ApiState<NotificationPreferences>>((ref) {
  final controller = NotificationPreferencesController(
    repository: ref.watch(settingsRepositoryProvider),
  );
  Future.microtask(controller.load);
  return controller;
});
