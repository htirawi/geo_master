import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/translation_service.dart';
import '../../data/datasources/remote/weather_datasource.dart';
import '../../domain/repositories/i_ai_tutor_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_country_content_repository.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';
import 'service_locator.dart';

// =============================================================================
// Repository Providers
// =============================================================================
// Bridge GetIt service locator to Riverpod for testability.
// These providers can be overridden in tests with mock implementations.
// =============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return sl<IAuthRepository>();
});

/// User repository provider
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return sl<IUserRepository>();
});

/// Country repository provider
final countryRepositoryProvider = Provider<ICountryRepository>((ref) {
  return sl<ICountryRepository>();
});

/// Quiz repository provider
final quizRepositoryProvider = Provider<IQuizRepository>((ref) {
  return sl<IQuizRepository>();
});

/// AI Tutor repository provider
final aiTutorRepositoryProvider = Provider<IAiTutorRepository>((ref) {
  return sl<IAiTutorRepository>();
});

/// Subscription repository provider
final subscriptionRepositoryProvider = Provider<ISubscriptionRepository>((ref) {
  return sl<ISubscriptionRepository>();
});

/// World exploration repository provider
final worldExplorationRepositoryProvider = Provider<IWorldExplorationRepository>((ref) {
  return sl<IWorldExplorationRepository>();
});

/// Country content repository provider
final countryContentRepositoryProvider = Provider<ICountryContentRepository>((ref) {
  return sl<ICountryContentRepository>();
});

/// Media repository provider
final mediaRepositoryProvider = Provider<IMediaRepository>((ref) {
  return sl<IMediaRepository>();
});

// =============================================================================
// Data Source Providers
// =============================================================================

/// Weather data source provider
final weatherDataSourceProvider = Provider<IWeatherDataSource>((ref) {
  return sl<IWeatherDataSource>();
});

// =============================================================================
// Service Providers
// =============================================================================

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  return sl<SharedPreferences>();
});

/// Translation service provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  return sl<TranslationService>();
});

/// Audio service provider (for sound effects and celebrations)
final audioServiceFromDiProvider = Provider<AudioService>((ref) {
  return sl<AudioService>();
});
