import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/api_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../controllers/profile_controller.dart';

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ApiState<User>>(
  (ref) {
    final controller = ProfileController(ref.watch(authRepositoryProvider));
    Future.microtask(controller.load);
    return controller;
  },
);
