/// Base class for all exceptions in the app.
/// Exceptions are thrown in the data layer and converted to Failures
/// in the repository layer.
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error occurred.',
    super.code = 'NETWORK_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection.',
        code: 'NO_CONNECTION',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timed out.',
        code: 'TIMEOUT',
      );
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred.',
    super.code = 'SERVER_ERROR',
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });

  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    return ServerException(
      message: message ?? 'Server returned status code: $statusCode',
      code: 'HTTP_$statusCode',
      statusCode: statusCode,
    );
  }

  final int? statusCode;
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred.',
    super.code = 'CACHE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory CacheException.notFound() => const CacheException(
        message: 'Data not found in cache.',
        code: 'NOT_FOUND',
      );

  factory CacheException.writeError() => const CacheException(
        message: 'Failed to write to cache.',
        code: 'WRITE_ERROR',
      );
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication error occurred.',
    super.code = 'AUTH_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthException(
          message: 'No user found with this email.',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Invalid password.',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const AuthException(
          message: 'Email already in use.',
          code: 'EMAIL_IN_USE',
        );
      case 'weak-password':
        return const AuthException(
          message: 'Password is too weak.',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Invalid email address.',
          code: 'INVALID_EMAIL',
        );
      case 'user-disabled':
        return const AuthException(
          message: 'User account has been disabled.',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Too many requests. Try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      default:
        return AuthException(
          message: 'Authentication failed: $code',
          code: code,
        );
    }
  }
}

/// API-related exceptions
class ApiException extends AppException {
  const ApiException({
    super.message = 'API error occurred.',
    super.code = 'API_ERROR',
    this.statusCode,
    this.responseBody,
    super.originalError,
    super.stackTrace,
  });

  final int? statusCode;
  final Map<String, dynamic>? responseBody;
}

/// Claude API specific exceptions
class ClaudeApiException extends AppException {
  const ClaudeApiException({
    super.message = 'Claude API error occurred.',
    super.code = 'CLAUDE_API_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory ClaudeApiException.rateLimited() => const ClaudeApiException(
        message: 'Rate limit exceeded.',
        code: 'RATE_LIMITED',
      );

  factory ClaudeApiException.invalidApiKey() => const ClaudeApiException(
        message: 'Invalid API key.',
        code: 'INVALID_API_KEY',
      );

  factory ClaudeApiException.contextTooLong() => const ClaudeApiException(
        message: 'Context too long.',
        code: 'CONTEXT_TOO_LONG',
      );
}

/// Parse/format exceptions
class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse data.',
    super.code = 'PARSE_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Purchase-related exceptions
class PurchaseException extends AppException {
  const PurchaseException({
    super.message = 'Purchase error occurred.',
    super.code = 'PURCHASE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory PurchaseException.cancelled() => const PurchaseException(
        message: 'Purchase was cancelled.',
        code: 'CANCELLED',
      );

  factory PurchaseException.paymentDeclined() => const PurchaseException(
        message: 'Payment was declined.',
        code: 'PAYMENT_DECLINED',
      );
}
