import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import 'api_state.dart';

/// Result of a single page fetch for [PaginationController].
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.totalCount,
  });

  final List<T> items;
  final bool hasMore;
  final int? totalCount;
}

/// Riverpod controller for paginated lists with refresh + infinite scroll.
///
/// Subclasses implement [fetchPage].
abstract class PaginationController<T>
    extends StateNotifier<ApiState<List<T>>> {
  PaginationController({
    this.pageSize = 20,
    ApiState<List<T>>? initialState,
  }) : super(initialState ?? const ApiState.loading());

  final int pageSize;

  int _page = 0;
  int? totalCount;

  List<T> get items => state.data ?? const [];

  /// Fetches a page of items. [page] is 1-based.
  Future<PageResult<T>> fetchPage({
    required int page,
    required int pageSize,
  });

  /// Initial / retry load (resets pagination).
  Future<void> load() async {
    state = const ApiState.loading();
    _page = 0;
    totalCount = null;
    await _fetchAndMerge(keepPrevious: false);
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    final previous = state.data;
    if (previous != null) {
      state = ApiState.refreshing(previous);
    } else {
      state = const ApiState.loading();
    }
    _page = 0;
    await _fetchAndMerge(keepPrevious: true);
  }

  Future<void> retry() => load();

  /// Appends the next page when [ApiState.hasMore] is true.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = _page + 1;
      final result = await fetchPage(page: nextPage, pageSize: pageSize);
      _page = nextPage;
      totalCount = result.totalCount ?? totalCount;
      final merged = [...items, ...result.items];
      state = ApiState.success(
        merged,
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } on AppException catch (error, stackTrace) {
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: state.data,
        message: error.message,
      ).copyWith(isLoadingMore: false, hasMore: state.hasMore);
    } catch (error, stackTrace) {
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: state.data,
      ).copyWith(isLoadingMore: false, hasMore: state.hasMore);
    }
  }

  Future<void> _fetchAndMerge({required bool keepPrevious}) async {
    try {
      final result = await fetchPage(page: 1, pageSize: pageSize);
      _page = 1;
      totalCount = result.totalCount;
      if (result.items.isEmpty) {
        state = const ApiState.empty();
      } else {
        state = ApiState.success(
          result.items,
          hasMore: result.hasMore,
        );
      }
    } on AppException catch (error, stackTrace) {
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: keepPrevious ? state.data : null,
        message: error.message,
      );
    } catch (error, stackTrace) {
      state = ApiState.error(
        error,
        stackTrace: stackTrace,
        data: keepPrevious ? state.data : null,
      );
    }
  }
}

/// Attaches near-bottom scroll detection for infinite lists.
class InfiniteScrollListener {
  InfiniteScrollListener({
    required this.onLoadMore,
    this.threshold = 120,
  });

  final Future<void> Function() onLoadMore;
  final double threshold;

  void attach(ScrollController controller) {
    controller.addListener(() {
      if (!controller.hasClients) return;
      final position = controller.position;
      if (position.pixels >= position.maxScrollExtent - threshold) {
        onLoadMore();
      }
    });
  }
}
