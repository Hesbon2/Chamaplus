import 'package:dio/dio.dart';

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

    return AppException(
      message: 'Something went wrong. Please try again.',
      cause: error,
    );
  }

  AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Cannot reach the server. Check API_BASE_URL and that Django is running on 0.0.0.0:8000.',
          cause: error,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return AppException(
          message: error.message ?? 'An unexpected network error occurred.',
          cause: error,
        );
    }
  }

  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Request failed.';
    if (data is Map<String, dynamic> && data['message'] is String) {
      message = data['message'] as String;
    } else if (statusCode != null) {
      message = 'Request failed with status $statusCode.';
    }

    return ServerException(
      message: message,
      statusCode: statusCode,
      cause: error,
    );
  }
}
