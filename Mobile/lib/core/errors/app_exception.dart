/// Base application exception with user-facing message support.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// Network connectivity is unavailable.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.cause,
  }) : super(statusCode: null);
}

/// Server returned an error response.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Request timed out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The request timed out. Please try again.',
  }) : super(statusCode: 408);
}

/// Local storage operation failed.
class StorageException extends AppException {
  const StorageException({
    super.message = 'Secure storage is unavailable.',
    super.cause,
  });
}
