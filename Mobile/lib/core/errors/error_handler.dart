import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_exception.dart';

/// Converts low-level errors into [AppException] for consistent UI handling.
class ErrorHandler {
  const ErrorHandler();

  AppException handle(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    return const AppException(
      message: 'Something went wrong. Please try again.',
    );
  }

  /// Short, user-facing copy for banners and snackbars.
  static String userMessage(Object error) {
    if (error is AppException) return error.message;
    return const ErrorHandler().handle(error).message;
  }

  AppException _handleDioException(DioException error) {
    if (error.error is AppException) {
      return error.error! as AppException;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const AppException(
          message: 'Secure connection failed. Please try again later.',
        );
      case DioExceptionType.unknown:
      default:
        return const AppException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Request failed. Please try again.';
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final detail = map['detail'] ?? map['message'] ?? map['error'];
      if (detail is String && detail.trim().isNotEmpty) {
        message = detail.trim();
      } else if (map['non_field_errors'] is List &&
          (map['non_field_errors'] as List).isNotEmpty) {
        message = (map['non_field_errors'] as List).first.toString();
      }
    }

    if (statusCode == 401) {
      message = 'Your session expired. Please sign in again.';
    } else if (statusCode == 403) {
      message = 'You do not have permission to do that.';
    } else if (statusCode == 404) {
      message = 'We could not find what you were looking for.';
    } else if (statusCode == 429) {
      message = 'Too many requests. Please wait a moment and try again.';
    } else if (statusCode != null && statusCode >= 500) {
      message = 'The server is having trouble. Please try again shortly.';
    }

    // Never surface raw stack / internal paths in release.
    if (!kDebugMode && message.contains('Exception')) {
      message = 'Something went wrong. Please try again.';
    }

    return ServerException(
      message: message,
      statusCode: statusCode,
      cause: error,
    );
  }
}
