import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../core/theme/app_spacing.dart';
import '../components/empty_state.dart';
import '../components/shimmer_loader.dart';
import 'api_state.dart';

/// Builds UI for an [ApiState], with optional pull-to-refresh and retry.
///
/// Default widgets reuse the shared design system (`ShimmerLoader`,
/// `EmptyState`) plus a compact error surface with retry.
///
/// For infinite scroll lists, prefer appending a footer item in [builder]
/// when [ApiState.isLoadingMore] is true (the list itself stays a
/// [ScrollView] so pull-to-refresh keeps working).
class ApiStateBuilder<T> extends StatelessWidget {
  /// Creates an API state builder.
  const ApiStateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.onRefresh,
    this.isEmpty,
    this.loading,
    this.empty,
    this.errorBuilder,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Pull to refresh or try again later.',
    this.emptyIcon = Icons.inbox_outlined,
    this.shimmerItemCount = 4,
    this.shimmerItemHeight = 88,
    this.enablePullToRefresh = true,
    this.loadingMoreIndicator,
    this.physics,
    this.padding,
  });

  /// Current async state from a Riverpod controller.
  final ApiState<T> state;

  /// Builds the success (and refreshing-with-data) body.
  final Widget Function(BuildContext context, T data) builder;

  /// Retry callback for error / empty actions.
  final Future<void> Function()? onRetry;

  /// Pull-to-refresh callback.
  final Future<void> Function()? onRefresh;

  /// Optional empty check for success payloads (e.g. empty lists).
  final bool Function(T data)? isEmpty;

  /// Custom loading widget. Defaults to [ShimmerLoader].
  final Widget? loading;

  /// Custom empty widget.
  final Widget? empty;

  /// Custom error builder.
  final Widget Function(
    BuildContext context,
    Object error,
    VoidCallback? retry,
  )? errorBuilder;

  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final int shimmerItemCount;
  final double shimmerItemHeight;
  final bool enablePullToRefresh;
  final Widget? loadingMoreIndicator;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    // Only force a scroll wrapper for static empty/error/shimmer bodies.
    // Success/custom-loading widgets often embed their own ListView; wrapping
    // those in SingleChildScrollView causes "Vertical viewport was given
    // unbounded height".
    var ensureScrollable = true;

    if (state.showLoading) {
      child = loading ??
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: ShimmerLoader(
              itemCount: shimmerItemCount,
              itemHeight: shimmerItemHeight,
            ),
          );
      ensureScrollable = loading == null;
    } else if (state.isError && !state.hasValue) {
      child = _buildError(context);
    } else if (state.isEmpty ||
        (state.hasValue &&
            isEmpty != null &&
            isEmpty!(state.data as T) &&
            !state.isRefreshing)) {
      child = empty ??
          EmptyState(
            title: emptyTitle,
            message: state.message ?? emptyMessage,
            icon: emptyIcon,
            actionLabel: onRetry != null ? 'Retry' : null,
            onAction: onRetry == null ? null : () => onRetry!(),
          );
    } else if (state.hasValue) {
      final content = builder(context, state.data as T);
      if (state.isLoadingMore && loadingMoreIndicator != null) {
        child = Column(
          children: [
            Expanded(child: content),
            loadingMoreIndicator!,
          ],
        );
      } else {
        child = content;
      }
      ensureScrollable = false;
    } else {
      child = _buildError(context);
    }

    if (!enablePullToRefresh || onRefresh == null) {
      return child;
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: child is ScrollView || !ensureScrollable
          ? child
          : _ensureScrollable(context, child),
    );
  }

  Widget _buildError(BuildContext context) {
    final error = state.error ?? Exception(state.errorMessage);
    if (errorBuilder != null) {
      return errorBuilder!(
        context,
        error,
        onRetry == null ? null : () => onRetry!(),
      );
    }

    final message = error is AppException
        ? error.message
        : ErrorHandler.userMessage(error);

    final isOffline = error is NetworkException;
    return EmptyState(
      title: isOffline ? 'You appear to be offline' : 'Something went wrong',
      message: message,
      icon: isOffline ? Icons.wifi_off_outlined : Icons.error_outline,
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry == null ? null : () => onRetry!(),
    );
  }

  Widget _ensureScrollable(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
