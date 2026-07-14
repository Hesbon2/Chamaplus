/// Status of an asynchronous API-backed UI resource.
enum ApiStatus {
  /// No request has started yet.
  initial,

  /// First load in progress (no usable data).
  loading,

  /// Pull-to-refresh / silent reload while previous data may still be shown.
  refreshing,

  /// Request succeeded with data.
  success,

  /// Request succeeded but there is nothing to show.
  empty,

  /// Request failed.
  error,
}

/// Immutable async UI state used across feature controllers.
///
/// Integrates cleanly with Riverpod [StateNotifier] and [ApiStateBuilder].
class ApiState<T> {
  const ApiState._({
    required this.status,
    this.data,
    this.error,
    this.stackTrace,
    this.message,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  /// No work started.
  const ApiState.initial()
      : this._(status: ApiStatus.initial);

  /// Full-screen / shimmer loading.
  const ApiState.loading()
      : this._(status: ApiStatus.loading);

  /// Refreshing while optionally keeping [data] on screen.
  const ApiState.refreshing(T data)
      : this._(status: ApiStatus.refreshing, data: data);

  /// Successful payload.
  const ApiState.success(
    T data, {
    bool hasMore = false,
    bool isLoadingMore = false,
  }) : this._(
          status: ApiStatus.success,
          data: data,
          hasMore: hasMore,
          isLoadingMore: isLoadingMore,
        );

  /// Successful but empty result set.
  const ApiState.empty({String? message})
      : this._(status: ApiStatus.empty, message: message);

  /// Failed request; [data] may retain the last good value.
  const ApiState.error(
    Object error, {
    StackTrace? stackTrace,
    T? data,
    String? message,
  }) : this._(
          status: ApiStatus.error,
          error: error,
          stackTrace: stackTrace,
          data: data,
          message: message,
        );

  final ApiStatus status;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;
  final String? message;
  final bool isLoadingMore;
  final bool hasMore;

  bool get isInitial => status == ApiStatus.initial;
  bool get isLoading => status == ApiStatus.loading;
  bool get isRefreshing => status == ApiStatus.refreshing;
  bool get isSuccess => status == ApiStatus.success;
  bool get isEmpty => status == ApiStatus.empty;
  bool get isError => status == ApiStatus.error;

  /// True when the UI should show a blocking loader (no previous data).
  bool get showLoading =>
      isLoading || (isInitial && data == null);

  /// True when content can be rendered from [data].
  bool get hasValue => data != null;

  /// User-facing error text.
  String get errorMessage {
    if (message != null && message!.isNotEmpty) return message!;
    final err = error;
    if (err == null) return 'Something went wrong. Please try again.';
    return err.toString();
  }

  ApiState<T> copyWith({
    ApiStatus? status,
    T? data,
    Object? error,
    StackTrace? stackTrace,
    String? message,
    bool? isLoadingMore,
    bool? hasMore,
    bool clearError = false,
    bool clearData = false,
  }) {
    return ApiState._(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      error: clearError ? null : (error ?? this.error),
      stackTrace: clearError ? null : (stackTrace ?? this.stackTrace),
      message: clearError ? null : (message ?? this.message),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Maps the success/refresh payload while preserving status flags.
  ApiState<R> map<R>(R Function(T data) transform) {
    final current = data;
    return ApiState._(
      status: status,
      data: current == null ? null : transform(current),
      error: error,
      stackTrace: stackTrace,
      message: message,
      isLoadingMore: isLoadingMore,
      hasMore: hasMore,
    );
  }

  @override
  String toString() =>
      'ApiState<$T>(status: $status, hasData: $hasValue, hasMore: $hasMore, '
      'isLoadingMore: $isLoadingMore, error: $error)';
}
