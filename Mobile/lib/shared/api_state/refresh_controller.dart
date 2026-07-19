import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import 'api_state.dart';

/// Base Riverpod controller for a single refreshable API resource.
///
/// Subclasses implement [fetchData] (and optionally [isEmptyData]).
abstract class RefreshController<T> extends StateNotifier<ApiState<T>> {
  RefreshController({ApiState<T>? initialState})
      : super(initialState ?? const ApiState.loading());

  /// Loads data from the remote/local source.
  Future<T> fetchData({bool forceRefresh = false});

  /// Returns true when [data] should be treated as an empty state.
  bool isEmptyData(T data) => false;

  /// First load (blocking / shimmer).
  Future<void> load({bool forceRefresh = false}) async {
    if (!mounted) return;
    if (!forceRefresh && state.isSuccess && state.hasValue) {
      return;
    }

    state = const ApiState.loading();
    await _runFetch(forceRefresh: forceRefresh, keepPrevious: false);
  }

  /// Pull-to-refresh while keeping previous data visible when available.
  Future<void> refresh() async {
    if (!mounted) return;
    final previous = state.data;
    if (previous != null) {
      state = ApiState.refreshing(previous);
    } else {
      state = const ApiState.loading();
    }
    await _runFetch(forceRefresh: true, keepPrevious: true);
  }

  /// Alias used by error / empty retry actions.
  Future<void> retry() => load(forceRefresh: true);

  Future<void> _runFetch({
    required bool forceRefresh,
    required bool keepPrevious,
  }) async {
    try {
      final data = await fetchData(forceRefresh: forceRefresh);
      if (!mounted) return;
      if (isEmptyData(data)) {
        state = const ApiState.empty();
      } else {
        state = ApiState.success(data);
      }
    } on AppException catch (error, stackTrace) {
      if (!mounted) return;
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: keepPrevious ? state.data : null,
        message: error.message,
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: keepPrevious ? state.data : null,
      );
    }
  }
}
