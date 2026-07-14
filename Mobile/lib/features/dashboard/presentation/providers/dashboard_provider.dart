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

final dashboardProvider =
    StateNotifierProvider<DashboardController, ApiState<Dashboard>>((ref) {
  final authState = ref.watch(authControllerProvider);
  final controller = DashboardController(
    repository: ref.watch(dashboardRepositoryProvider),
    userId: authState.user?.id ?? '',
    welcomeName: authState.user?.displayName ?? 'Member',
  );

  if (authState.isAuthenticated) {
    Future.microtask(controller.load);
  }

  return controller;
});
