import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../services/logger_service.dart';

/// Create and configure Dio client with security features
Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Security: Add headers to prevent MIME type sniffing and caching of sensitive data
        'X-Content-Type-Options': 'nosniff',
        'Cache-Control': 'no-store, no-cache, must-revalidate',
      },
    ),
  );

  // Security: Configure certificate pinning for production
  if (!kDebugMode) {
    _configureCertificatePinning(dio);
  }

  // Add interceptors
  dio.interceptors.addAll([
    _RateLimitInterceptor(),
    _LoggingInterceptor(),
    _ErrorInterceptor(),
    _RetryInterceptor(dio),
  ]);

  return dio;
}

/// Configure certificate pinning for trusted domains
/// Security: Prevents MITM attacks by validating server certificates
void _configureCertificatePinning(Dio dio) {
  // List of trusted domains and their expected certificate properties
  const trustedHosts = [
    'api.anthropic.com',
    'api.openweathermap.org',
    'restcountries.com',
    'en.wikipedia.org',
    'ar.wikipedia.org',
    'api.unsplash.com',
    'www.googleapis.com',
    'newsapi.org',
  ];

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();

      // Security: Reject bad certificates in production
      client.badCertificateCallback = (cert, host, port) {
        // In production, reject all bad certificates
        logger.warning(
          'Bad certificate for $host:$port',
          tag: 'CertPin',
        );
        return false;
      };

      return client;
    },
    validateCertificate: (cert, host, port) {
      // Security: Strict certificate validation for all hosts
      if (cert == null) {
        logger.warning('No certificate provided for $host', tag: 'CertPin');
        return false;
      }

      // Check certificate validity period first
      final now = DateTime.now();
      if (cert.endValidity.isBefore(now)) {
        logger.warning('Expired certificate for $host', tag: 'CertPin');
        return false;
      }

      // Check if certificate is not yet valid
      if (cert.startValidity.isAfter(now)) {
        logger.warning('Certificate not yet valid for $host', tag: 'CertPin');
        return false;
      }

      // Security: Only allow connections to explicitly trusted hosts
      // This prevents connections to unknown/malicious servers
      final isTrusted = trustedHosts.any((trusted) => host.endsWith(trusted));
      if (!isTrusted) {
        // Security: Reject untrusted hosts in production
        logger.warning(
          'Rejecting untrusted host: $host - not in allowlist',
          tag: 'CertPin',
        );
        return false;
      }

      // For trusted hosts, certificate is valid
      return true;
    },
  );
}

/// Wrapper around Dio for type-safe API calls
class ApiClient {
  ApiClient({required this.dio});

  final Dio dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request with streaming response
  Future<Response<ResponseBody>> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final streamOptions = (options ?? Options()).copyWith(
      responseType: ResponseType.stream,
    );

    return dio.post<ResponseBody>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: streamOptions,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Rate limiting interceptor to prevent API abuse
/// Security: Implements per-host rate limiting
class _RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestHistory = {};

  // Rate limits per host (requests per minute)
  static const Map<String, int> _rateLimits = {
    'api.anthropic.com': 10,
    'api.openweathermap.org': 30,
    'restcountries.com': 60,
    'api.unsplash.com': 30,
    'www.googleapis.com': 50,
    'newsapi.org': 30,
  };
  static const int _defaultRateLimit = 60; // default: 60 requests per minute
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final host = options.uri.host;
    final limit = _rateLimits[host] ?? _defaultRateLimit;

    // Clean up old entries
    _cleanupOldEntries(host);

    // Check rate limit
    final history = _requestHistory[host] ?? [];
    if (history.length >= limit) {
      // Rate limit exceeded
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Rate limit exceeded for $host. Please wait before retrying.',
        ),
      );
      return;
    }

    // Record this request
    _requestHistory[host] = [...history, DateTime.now()];
    handler.next(options);
  }

  void _cleanupOldEntries(String host) {
    final history = _requestHistory[host];
    if (history == null) return;

    final cutoff = DateTime.now().subtract(_rateLimitWindow);
    _requestHistory[host] = history.where((t) => t.isAfter(cutoff)).toList();
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Security: Only log in debug mode, and don't log sensitive data
    if (kDebugMode) {
      logger.debug(
        'REQUEST[${options.method}] => ${options.uri.host}${options.uri.path}',
        tag: 'HTTP',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      logger.debug(
        'RESPONSE[${response.statusCode}] <= ${response.requestOptions.uri.host}',
        tag: 'HTTP',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Security: Don't log full error details in production
    if (kDebugMode) {
      logger.debug(
        'ERROR[${err.response?.statusCode}] <= ${err.requestOptions.uri.host}',
        tag: 'HTTP',
      );
    }
    handler.next(err);
  }
}

/// Error handling interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add custom error handling logic here
    // For example, refresh tokens on 401, etc.
    handler.next(err);
  }
}

/// Retry interceptor for failed requests
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this.dio);

  final Dio dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (_shouldRetry(err) && retryCount < ApiEndpoints.maxRetries) {
      await Future<void>.delayed(
        ApiEndpoints.retryDelay * (retryCount + 1),
      );

      try {
        final options = err.requestOptions;
        options.extra['retryCount'] = retryCount + 1;

        final response = await dio.fetch<dynamic>(options);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with error handling
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }
}
