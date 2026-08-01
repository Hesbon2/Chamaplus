import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/dashboard_api.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(api: ref.watch(dashboardApiProvider));
});

/// Watches only identity fields so unrelated auth updates do not rebuild/load.
final dashboardProvider =
    StateNotifierProvider<DashboardController, ApiState<Dashboard>>((ref) {
  final userId = ref.watch(authControllerProvider.select((s) => s.user?.id));
  final welcomeName = ref.watch(
    authControllerProvider.select((s) => s.user?.displayName),
  );
  final isAuthenticated = ref.watch(
    authControllerProvider.select((s) => s.isAuthenticated),
  );

  final controller = DashboardController(
    repository: ref.watch(dashboardRepositoryProvider),
    userId: userId ?? '',
    welcomeName: welcomeName ?? 'Member',
  );

  if (isAuthenticated) {
    Future.microtask(controller.load);
  }

  return controller;
});
