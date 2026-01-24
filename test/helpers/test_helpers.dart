import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geo_master/app/di/repository_providers.dart';
import 'package:geo_master/core/services/translation_service.dart';
import 'package:geo_master/data/datasources/remote/weather_datasource.dart';
import 'package:geo_master/domain/repositories/i_ai_tutor_repository.dart';
import 'package:geo_master/domain/repositories/i_auth_repository.dart';
import 'package:geo_master/domain/repositories/i_country_content_repository.dart';
import 'package:geo_master/domain/repositories/i_country_repository.dart';
import 'package:geo_master/domain/repositories/i_media_repository.dart';
import 'package:geo_master/domain/repositories/i_quiz_repository.dart';
import 'package:geo_master/domain/repositories/i_subscription_repository.dart';
import 'package:geo_master/domain/repositories/i_user_repository.dart';
import 'package:geo_master/domain/repositories/i_world_exploration_repository.dart';

// =============================================================================
// Mock Repositories
// =============================================================================

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockQuizRepository extends Mock implements IQuizRepository {}

class MockAiTutorRepository extends Mock implements IAiTutorRepository {}

class MockCountryRepository extends Mock implements ICountryRepository {}

class MockSubscriptionRepository extends Mock implements ISubscriptionRepository {}

class MockWorldExplorationRepository extends Mock implements IWorldExplorationRepository {}

class MockCountryContentRepository extends Mock implements ICountryContentRepository {}

class MockMediaRepository extends Mock implements IMediaRepository {}

class MockWeatherDataSource extends Mock implements IWeatherDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockTranslationService extends Mock implements TranslationService {}

// =============================================================================
// Provider Test Container
// =============================================================================

/// Creates a ProviderContainer with overridden providers for testing.
///
/// Usage:
/// ```dart
/// final mockAuthRepo = MockAuthRepository();
/// when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => Right(testUser));
///
/// final container = createTestContainer(authRepo: mockAuthRepo);
/// final result = await container.read(authStateProvider.notifier).checkAuthStatus();
/// ```
ProviderContainer createTestContainer({
  IAuthRepository? authRepo,
  IUserRepository? userRepo,
  IQuizRepository? quizRepo,
  IAiTutorRepository? aiTutorRepo,
  ICountryRepository? countryRepo,
  ISubscriptionRepository? subscriptionRepo,
  IWorldExplorationRepository? worldExplorationRepo,
  ICountryContentRepository? countryContentRepo,
  IMediaRepository? mediaRepo,
  IWeatherDataSource? weatherDataSource,
  SharedPreferences? sharedPreferences,
  TranslationService? translationService,
}) {
  return ProviderContainer(
    overrides: [
      if (authRepo != null) authRepositoryProvider.overrideWithValue(authRepo),
      if (userRepo != null) userRepositoryProvider.overrideWithValue(userRepo),
      if (quizRepo != null) quizRepositoryProvider.overrideWithValue(quizRepo),
      if (aiTutorRepo != null) aiTutorRepositoryProvider.overrideWithValue(aiTutorRepo),
      if (countryRepo != null) countryRepositoryProvider.overrideWithValue(countryRepo),
      if (subscriptionRepo != null) subscriptionRepositoryProvider.overrideWithValue(subscriptionRepo),
      if (worldExplorationRepo != null) worldExplorationRepositoryProvider.overrideWithValue(worldExplorationRepo),
      if (countryContentRepo != null) countryContentRepositoryProvider.overrideWithValue(countryContentRepo),
      if (mediaRepo != null) mediaRepositoryProvider.overrideWithValue(mediaRepo),
      if (weatherDataSource != null) weatherDataSourceProvider.overrideWithValue(weatherDataSource),
      if (sharedPreferences != null) sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      if (translationService != null) translationServiceProvider.overrideWithValue(translationService),
    ],
  );
}

// =============================================================================
// Test Data Factories
// =============================================================================

/// Common test data that can be reused across tests.
class TestData {
  static const String testUserId = 'test-user-id';
  static const String testEmail = 'test@example.com';
  static const String testDisplayName = 'Test User';
  static const String testCountryCode = 'US';
  static const String testCountryName = 'United States';
}

// =============================================================================
// Test Utilities
// =============================================================================

/// Extension to wait for async state changes in providers
extension ProviderContainerExtension on ProviderContainer {
  /// Pumps the provider until the predicate returns true or times out
  Future<T> pumpUntil<T>(
    ProviderListenable<AsyncValue<T>> provider,
    bool Function(AsyncValue<T>) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final value = read(provider);
      if (predicate(value)) {
        if (value.hasValue) return value.value!;
        throw value.error!;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw TimeoutException('Timed out waiting for provider state');
  }
}

/// Custom exception for test timeouts
class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;

  @override
  String toString() => 'TimeoutException: $message';
}
