import 'dart:async';
import 'dart:math' as math;

import '../services/logger_service.dart';

/// Configuration for retry behavior
class RetryConfig {
  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffFactor = 2.0,
    this.useJitter = true,
  });

  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Initial delay between retries (will be multiplied by backoff factor)
  final Duration initialDelay;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// Exponential backoff factor
  final double backoffFactor;

  /// Whether to add jitter to prevent thundering herd
  final bool useJitter;

  /// Default config for network requests
  static const network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
    backoffFactor: 2.0,
    useJitter: true,
  );

  /// Config for critical operations (more retries, longer delays)
  static const critical = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 60),
    backoffFactor: 2.0,
    useJitter: true,
  );

  /// Config for quick retries
  static const quick = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 2),
    backoffFactor: 1.5,
    useJitter: false,
  );
}

/// Helper class for retrying operations with exponential backoff
class RetryHelper {
  static final _random = math.Random();

  /// Execute an async operation with retry logic
  ///
  /// [operation] - The async operation to execute
  /// [config] - Retry configuration
  /// [shouldRetry] - Optional function to determine if an exception should trigger retry
  /// [onRetry] - Optional callback when a retry is about to happen
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.network,
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Object error, Duration delay)? onRetry,
    String? operationName,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= config.maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        lastError = error;

        // Check if we should retry this error
        final shouldRetryError = shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (!shouldRetryError || attempt == config.maxAttempts) {
          // Don't retry: either not a retryable error or max attempts reached
          logger.error(
            'Operation ${operationName ?? 'unknown'} failed after $attempt attempt(s)',
            tag: 'Retry',
            error: error,
            stackTrace: stackTrace,
          );
          rethrow;
        }

        // Calculate delay with exponential backoff
        final baseDelay = config.initialDelay.inMilliseconds *
            math.pow(config.backoffFactor, attempt - 1);
        var delayMs = math.min(baseDelay.toInt(), config.maxDelay.inMilliseconds);

        // Add jitter if enabled (random variation of ±25%)
        if (config.useJitter) {
          final jitter = (delayMs * 0.25 * (_random.nextDouble() * 2 - 1)).toInt();
          delayMs = delayMs + jitter;
        }

        final delay = Duration(milliseconds: delayMs);

        logger.warning(
          'Operation ${operationName ?? 'unknown'} failed (attempt $attempt/${config.maxAttempts}), '
          'retrying in ${delay.inMilliseconds}ms',
          tag: 'Retry',
          error: error,
        );

        onRetry?.call(attempt, error, delay);

        await Future<void>.delayed(delay);
      }
    }

    // This shouldn't be reached, but just in case
    throw lastError ?? Exception('Retry failed with no error captured');
  }

  /// Default logic for determining if an error should be retried
  static bool _defaultShouldRetry(Object error) {
    final errorString = error.toString().toLowerCase();

    // Retry network-related errors
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('network') ||
        errorString.contains('failed host lookup')) {
      return true;
    }

    // Retry server errors (5xx)
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }

    // Don't retry client errors (4xx) or other errors by default
    return false;
  }
}

/// Extension to make retry easier to use with Futures
extension RetryExtension<T> on Future<T> Function() {
  /// Retry this async operation with the given config
  Future<T> withRetry({
    RetryConfig config = RetryConfig.network,
    bool Function(Object error)? shouldRetry,
    String? operationName,
  }) {
    return RetryHelper.retry(
      operation: this,
      config: config,
      shouldRetry: shouldRetry,
      operationName: operationName,
    );
  }
}
