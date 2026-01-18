import 'package:flutter/foundation.dart';

import '../services/logger_service.dart';

/// Environment configuration for the app
/// API keys and secrets should be loaded from environment variables or secure storage
///
/// Usage in development:
/// 1. Create a `.env` file in project root (add to .gitignore!)
/// 2. Add: CLAUDE_API_KEY=your_key_here
/// 3. Run with: flutter run --dart-define-from-file=.env
///
/// Usage in production:
/// Configure in CI/CD pipeline or use flutter_secure_storage
class EnvConfig {
  EnvConfig._();

  /// App environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: kDebugMode ? 'development' : 'production',
  );

  /// Whether we're in debug/development mode
  static bool get isDevelopment => environment == 'development';

  /// Whether we're in production mode
  static bool get isProduction => environment == 'production';

  /// Claude API key - MUST be provided via environment variable
  /// Never commit this to source control!
  static const String claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: '',
  );

  /// Whether Claude API is configured
  static bool get isClaudeConfigured => claudeApiKey.isNotEmpty;

  /// Google Maps API key (for Maps SDK)
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// RevenueCat public API key
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  /// OpenWeatherMap API key
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );

  /// Firebase Cloud Functions base URL
  static const String cloudFunctionsBaseUrl = String.fromEnvironment(
    'CLOUD_FUNCTIONS_URL',
    defaultValue: '',
  );

  /// Validate that all required configuration is present
  static List<String> validateConfig() {
    final missing = <String>[];

    // In production, Claude API key is required
    if (isProduction && !isClaudeConfigured) {
      missing.add('CLAUDE_API_KEY');
    }

    return missing;
  }

  /// Print configuration status (for debugging)
  static void printConfigStatus() {
    if (!kDebugMode) return;

    logger.debug('=== Environment Configuration ===', tag: 'EnvConfig');
    logger.debug('Environment: $environment', tag: 'EnvConfig');
    logger.debug('Claude API: ${isClaudeConfigured ? "Configured" : "NOT CONFIGURED"}', tag: 'EnvConfig');
    logger.debug('Google Maps: ${googleMapsApiKey.isNotEmpty ? "Configured" : "NOT CONFIGURED"}', tag: 'EnvConfig');
    logger.debug('RevenueCat: ${revenueCatApiKey.isNotEmpty ? "Configured" : "NOT CONFIGURED"}', tag: 'EnvConfig');
    logger.debug('OpenWeather: ${openWeatherApiKey.isNotEmpty ? "Configured" : "NOT CONFIGURED"}', tag: 'EnvConfig');
  }
}

/// Build configuration
class BuildConfig {
  BuildConfig._();

  /// App version from pubspec
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// Build number
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  /// Full version string
  static String get fullVersion => '$version+$buildNumber';
}
