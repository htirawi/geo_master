import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/translation_service.dart';
import '../../data/datasources/local/chat_local_datasource.dart';
import '../../data/datasources/local/quiz_local_datasource.dart';
import '../../data/datasources/remote/claude_api_datasource.dart';
import '../../data/datasources/remote/exchange_rate_datasource.dart';
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firestore_user_datasource.dart';
import '../../data/datasources/remote/news_datasource.dart';
import '../../data/datasources/remote/rest_countries_datasource.dart';
import '../../data/datasources/remote/revenuecat_datasource.dart';
import '../../data/datasources/remote/timezone_datasource.dart';
import '../../data/datasources/remote/unsplash_datasource.dart';
import '../../data/datasources/remote/weather_datasource.dart';
import '../../data/datasources/remote/wikipedia_datasource.dart';
import '../../data/datasources/remote/youtube_datasource.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/ai_tutor_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/country_content_repository_impl.dart';
import '../../data/repositories/country_repository_impl.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/world_exploration_repository_impl.dart';
import '../../domain/repositories/i_ai_tutor_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_country_content_repository.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// API Keys - Configure via environment variables (--dart-define)
/// Example: flutter run --dart-define=CLAUDE_API_KEY=your_key_here
const String _claudeApiKey = String.fromEnvironment(
  'CLAUDE_API_KEY',
  defaultValue: '',
);
const String _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: '',
);
const String _weatherApiKey = String.fromEnvironment(
  'WEATHER_API_KEY',
  defaultValue: '',
);
const String _unsplashApiKey = String.fromEnvironment(
  'UNSPLASH_API_KEY',
  defaultValue: '',
);
const String _youtubeApiKey = String.fromEnvironment(
  'YOUTUBE_API_KEY',
  defaultValue: '',
);
const String _newsApiKey = String.fromEnvironment(
  'NEWS_API_KEY',
  defaultValue: '',
);

/// Initialize all dependencies
Future<void> initServiceLocator() async {
  await _initExternalDependencies();
  _initCore();
  _initDataSources();
  _initRepositories();
}

/// Initialize external dependencies (third-party packages)
Future<void> _initExternalDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Hive
  await Hive.initFlutter();
  sl.registerSingleton<HiveInterface>(Hive);

  // Cache Service
  sl.registerLazySingleton<CacheService>(
    () => CacheService(hive: sl<HiveInterface>()),
  );

  // Dio
  final dio = createDioClient();
  sl.registerSingleton<Dio>(dio);

  // Firebase instances
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  sl.registerSingleton<FirebaseRemoteConfig>(remoteConfig);

  // Translation Service (layered Arabic translations)
  sl.registerLazySingleton<TranslationService>(
    () => TranslationService(
      remoteConfig: sl<FirebaseRemoteConfig>(),
      hive: sl<HiveInterface>(),
    ),
  );
}

/// Initialize core utilities
void _initCore() {
  // API Client wrapper
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl<Dio>()),
  );
}

/// Initialize data sources
void _initDataSources() {
  // ============ Remote Data Sources ============

  // Firebase Auth
  sl.registerLazySingleton<IFirebaseAuthDataSource>(
    FirebaseAuthDataSource.new,
  );

  // Firestore User
  sl.registerLazySingleton<IFirestoreUserDataSource>(
    () => FirestoreUserDataSource(
      firestore: sl<FirebaseFirestore>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  // REST Countries API
  sl.registerLazySingleton<IRestCountriesDataSource>(
    () => RestCountriesDataSource(dio: sl<Dio>()),
  );

  // Claude API (AI Tutor)
  sl.registerLazySingleton<IClaudeApiDataSource>(
    () => ClaudeApiDataSource(
      apiKey: _claudeApiKey,
      dio: sl<Dio>(),
    ),
  );

  // RevenueCat (Subscriptions)
  sl.registerLazySingleton<IRevenueCatDataSource>(
    () => RevenueCatDataSource(apiKey: _revenueCatApiKey),
  );

  // Weather API (OpenWeatherMap)
  sl.registerLazySingleton<IWeatherDataSource>(
    () => WeatherDataSource(
      dio: sl<Dio>(),
      apiKey: _weatherApiKey,
    ),
  );

  // Wikipedia API (free, no key needed)
  sl.registerLazySingleton<IWikipediaDataSource>(
    () => WikipediaDataSource(dio: sl<Dio>()),
  );

  // Unsplash API (photos)
  sl.registerLazySingleton<IUnsplashDataSource>(
    () => UnsplashDataSource(
      dio: sl<Dio>(),
      apiKey: _unsplashApiKey,
    ),
  );

  // YouTube Data API v3
  sl.registerLazySingleton<IYouTubeDataSource>(
    () => YouTubeDataSource(
      dio: sl<Dio>(),
      apiKey: _youtubeApiKey,
    ),
  );

  // News API
  sl.registerLazySingleton<INewsDataSource>(
    () => NewsDataSource(
      dio: sl<Dio>(),
      apiKey: _newsApiKey,
    ),
  );

  // Exchange Rate API (free, no key needed)
  sl.registerLazySingleton<IExchangeRateDataSource>(
    () => ExchangeRateDataSource(dio: sl<Dio>()),
  );

  // Timezone API (WorldTimeAPI, free, no key needed)
  sl.registerLazySingleton<ITimezoneDataSource>(
    () => TimezoneDataSource(dio: sl<Dio>()),
  );

  // ============ Local Data Sources ============

  // Quiz Local Storage
  sl.registerLazySingleton<IQuizLocalDataSource>(
    () => QuizLocalDataSource(hive: sl<HiveInterface>()),
  );

  // Chat Local Storage
  sl.registerLazySingleton<IChatLocalDataSource>(
    () => ChatLocalDataSource(
      hive: sl<HiveInterface>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
}

/// Initialize repositories
void _initRepositories() {
  // Auth Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<IFirebaseAuthDataSource>()),
  );

  // User Repository
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(
      firestoreDataSource: sl<IFirestoreUserDataSource>(),
    ),
  );

  // Country Repository
  sl.registerLazySingleton<ICountryRepository>(
    () => CountryRepositoryImpl(
      restCountriesDataSource: sl<IRestCountriesDataSource>(),
      hive: sl<HiveInterface>(),
    ),
  );

  // Quiz Repository
  sl.registerLazySingleton<IQuizRepository>(
    () => QuizRepositoryImpl(
      localDataSource: sl<IQuizLocalDataSource>(),
      countryRepository: sl<ICountryRepository>(),
      firestoreDataSource: sl<IFirestoreUserDataSource>(),
    ),
  );

  // AI Tutor Repository
  sl.registerLazySingleton<IAiTutorRepository>(
    () => AiTutorRepositoryImpl(
      claudeDataSource: sl<IClaudeApiDataSource>(),
      chatLocalDataSource: sl<IChatLocalDataSource>(),
      getCurrentTier: _getCurrentSubscriptionTier,
    ),
  );

  // Subscription Repository
  sl.registerLazySingleton<ISubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      revenueCatDataSource: sl<IRevenueCatDataSource>(),
    ),
  );

  // World Exploration Repository
  sl.registerLazySingleton<IWorldExplorationRepository>(
    () => WorldExplorationRepositoryImpl(
      countryRepository: sl<ICountryRepository>(),
      hive: sl<HiveInterface>(),
    ),
  );

  // Country Content Repository
  sl.registerLazySingleton<ICountryContentRepository>(
    () => CountryContentRepositoryImpl(
      wikipediaDataSource: sl<IWikipediaDataSource>(),
      hive: sl<HiveInterface>(),
    ),
  );

  // Media Repository
  sl.registerLazySingleton<IMediaRepository>(
    () => MediaRepositoryImpl(
      unsplashDataSource: sl<IUnsplashDataSource>(),
      youtubeDataSource: sl<IYouTubeDataSource>(),
      newsDataSource: sl<INewsDataSource>(),
      exchangeRateDataSource: sl<IExchangeRateDataSource>(),
      timezoneDataSource: sl<ITimezoneDataSource>(),
      wikipediaDataSource: sl<IWikipediaDataSource>(),
    ),
  );
}

/// Helper to get current subscription tier for rate limiting
/// This creates a circular dependency workaround
SubscriptionTier _getCurrentSubscriptionTier() {
  // Default to free tier - will be updated by subscription provider
  // In a real app, this would check cached subscription status
  return SubscriptionTier.free;
}

/// Reset service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await sl.reset();
}
