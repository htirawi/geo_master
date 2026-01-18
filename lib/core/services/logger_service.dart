import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized logging service for the app
/// Handles debug logging and production error tracking
class LoggerService {
  factory LoggerService() => _instance;
  LoggerService._internal();

  static final LoggerService _instance = LoggerService._internal();

  bool _initialized = false;

  /// Initialize the logger service
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Configure Crashlytics to capture Flutter errors
    FlutterError.onError = (errorDetails) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(errorDetails);
      } else {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      }
    };
  }

  /// Log debug message (only in debug mode)
  void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('🔍 DEBUG: $prefix$message');
    }
  }

  /// Log info message
  void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('ℹ️ INFO: $prefix$message');
    }
    // In production, optionally log to analytics
  }

  /// Log warning message
  void warning(String message, {String? tag, dynamic error}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('⚠️ WARNING: $prefix$message');
      if (error != null) {
        print('   Error: $error');
      }
    }
    // In production, log non-fatal to Crashlytics
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.log('WARNING: $message');
    }
  }

  /// Log error with optional stack trace
  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    final prefix = tag != null ? '[$tag] ' : '';

    if (kDebugMode) {
      print('❌ ERROR: $prefix$message');
      if (error != null) {
        print('   Exception: $error');
      }
      if (stackTrace != null) {
        print('   Stack trace:\n$stackTrace');
      }
    } else {
      // Production: send to Crashlytics
      FirebaseCrashlytics.instance.log('ERROR: $prefix$message');

      if (error != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace ?? StackTrace.current,
          reason: message,
          fatal: fatal,
        );
      }
    }
  }

  /// Log network request
  void network(String method, String url, {int? statusCode, String? error}) {
    if (kDebugMode) {
      if (error != null) {
        print('🌐 NETWORK [$method] $url → ERROR: $error');
      } else {
        print('🌐 NETWORK [$method] $url → $statusCode');
      }
    }
  }

  /// Log user action for analytics
  void userAction(String action, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('👆 USER ACTION: $action');
      if (parameters != null) {
        print('   Parameters: $parameters');
      }
    }
    // In production, log to analytics
  }

  /// Set user identifier for crash reports
  void setUserId(String? userId) {
    if (!kDebugMode && userId != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  /// Add custom key-value for crash reports
  void setCustomKey(String key, dynamic value) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    }
  }

  /// Log breadcrumb for crash debugging
  void breadcrumb(String message) {
    if (kDebugMode) {
      print('🍞 BREADCRUMB: $message');
    } else {
      FirebaseCrashlytics.instance.log(message);
    }
  }
}

/// Global logger instance
final logger = LoggerService();
