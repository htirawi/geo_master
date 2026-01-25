import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app/di/service_locator.dart';
import 'logger_service.dart';

/// Layered translation service for Arabic country names and related data.
///
/// Translation priority (highest to lowest):
/// 1. Firebase Remote Config (for urgent fixes/updates)
/// 2. Local JSON asset (bundled, curated translations)
/// 3. REST Countries API translations (from API response)
/// 4. English name (final fallback)
class TranslationService {
  TranslationService({
    required FirebaseRemoteConfig remoteConfig,
    required HiveInterface hive,
  })  : _remoteConfig = remoteConfig,
        _hive = hive;

  final FirebaseRemoteConfig _remoteConfig;
  final HiveInterface _hive;

  // Cache box name
  static const String _translationsBox = 'translations_cache';

  // Asset path
  static const String _assetPath = 'assets/data/arabic_translations.json';

  // Remote Config keys
  static const String _remoteConfigKey = 'arabic_translations_override';

  // In-memory cache for fast access
  Map<String, dynamic>? _localTranslations;
  Map<String, dynamic>? _remoteOverrides;
  bool _isInitialized = false;

  /// Initialize the translation service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load local JSON asset
      await _loadLocalTranslations();

      // Load remote config overrides
      await _loadRemoteOverrides();

      _isInitialized = true;
      logger.info('TranslationService initialized', tag: 'TranslationService');
    } catch (e) {
      logger.error(
        'Failed to initialize TranslationService',
        tag: 'TranslationService',
        error: e,
      );
      // Even if initialization fails, mark as initialized to avoid blocking
      _isInitialized = true;
    }
  }

  /// Load translations from bundled JSON asset
  Future<void> _loadLocalTranslations() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      _localTranslations = jsonDecode(jsonString) as Map<String, dynamic>;
      logger.debug(
        'Loaded ${(_localTranslations?['countries'] as Map?)?.length ?? 0} country translations',
        tag: 'TranslationService',
      );
    } catch (e) {
      logger.warning(
        'Failed to load local translations',
        tag: 'TranslationService',
        error: e,
      );
      _localTranslations = {};
    }
  }

  /// Load remote config overrides
  Future<void> _loadRemoteOverrides() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final overrideJson = _remoteConfig.getString(_remoteConfigKey);
      if (overrideJson.isNotEmpty) {
        _remoteOverrides = jsonDecode(overrideJson) as Map<String, dynamic>;
        logger.debug(
          'Loaded remote translation overrides',
          tag: 'TranslationService',
        );
      } else {
        _remoteOverrides = {};
      }
    } catch (e) {
      logger.warning(
        'Failed to load remote config overrides',
        tag: 'TranslationService',
        error: e,
      );
      _remoteOverrides = {};
    }
  }

  /// Refresh translations from remote config
  Future<void> refresh() async {
    await _loadRemoteOverrides();
  }

  /// Get Arabic country name with layered fallback
  ///
  /// Priority:
  /// 1. Firebase Remote Config override
  /// 2. Local JSON asset
  /// 3. API translation (from apiTranslation parameter)
  /// 4. English name fallback
  String getCountryName({
    required String countryCode,
    required String englishName,
    String? apiTranslation,
  }) {
    final code = countryCode.toUpperCase();

    // 1. Check remote config override
    final remoteCountries = _remoteOverrides?['countries'] as Map<String, dynamic>?;
    if (remoteCountries != null && remoteCountries.containsKey(code)) {
      final remoteData = remoteCountries[code] as Map<String, dynamic>?;
      if (remoteData != null && remoteData['name'] != null) {
        return remoteData['name'] as String;
      }
    }

    // 2. Check local JSON asset
    final localCountries = _localTranslations?['countries'] as Map<String, dynamic>?;
    if (localCountries != null && localCountries.containsKey(code)) {
      final localData = localCountries[code] as Map<String, dynamic>?;
      if (localData != null && localData['name'] != null) {
        return localData['name'] as String;
      }
    }

    // 3. Use API translation if available
    if (apiTranslation != null && apiTranslation.isNotEmpty) {
      return apiTranslation;
    }

    // 4. Fall back to English name
    return englishName;
  }

  /// Get Arabic capital name with layered fallback
  String? getCapitalName({
    required String countryCode,
    String? englishCapital,
    String? apiTranslation,
  }) {
    if (englishCapital == null) return null;

    final code = countryCode.toUpperCase();

    // 1. Check remote config override
    final remoteCountries = _remoteOverrides?['countries'] as Map<String, dynamic>?;
    if (remoteCountries != null && remoteCountries.containsKey(code)) {
      final remoteData = remoteCountries[code] as Map<String, dynamic>?;
      if (remoteData != null && remoteData['capital'] != null) {
        return remoteData['capital'] as String;
      }
    }

    // 2. Check local JSON asset
    final localCountries = _localTranslations?['countries'] as Map<String, dynamic>?;
    if (localCountries != null && localCountries.containsKey(code)) {
      final localData = localCountries[code] as Map<String, dynamic>?;
      if (localData != null && localData['capital'] != null) {
        return localData['capital'] as String;
      }
    }

    // 3. Use API translation if available
    if (apiTranslation != null && apiTranslation.isNotEmpty) {
      return apiTranslation;
    }

    // 4. Fall back to English capital
    return englishCapital;
  }

  /// Get Arabic region name
  String getRegion(String englishRegion) {
    // 1. Check remote config override
    final remoteRegions = _remoteOverrides?['regions'] as Map<String, dynamic>?;
    if (remoteRegions != null && remoteRegions.containsKey(englishRegion)) {
      return remoteRegions[englishRegion] as String;
    }

    // 2. Check local JSON asset
    final localRegions = _localTranslations?['regions'] as Map<String, dynamic>?;
    if (localRegions != null && localRegions.containsKey(englishRegion)) {
      return localRegions[englishRegion] as String;
    }

    // 3. Fall back to English
    return englishRegion;
  }

  /// Get Arabic subregion name
  String getSubregion(String englishSubregion) {
    // 1. Check remote config override
    final remoteSubregions = _remoteOverrides?['subregions'] as Map<String, dynamic>?;
    if (remoteSubregions != null && remoteSubregions.containsKey(englishSubregion)) {
      return remoteSubregions[englishSubregion] as String;
    }

    // 2. Check local JSON asset
    final localSubregions = _localTranslations?['subregions'] as Map<String, dynamic>?;
    if (localSubregions != null && localSubregions.containsKey(englishSubregion)) {
      return localSubregions[englishSubregion] as String;
    }

    // 3. Fall back to English
    return englishSubregion;
  }

  /// Get Arabic continent name
  String getContinent(String englishContinent) {
    // 1. Check remote config override
    final remoteContinents = _remoteOverrides?['continents'] as Map<String, dynamic>?;
    if (remoteContinents != null && remoteContinents.containsKey(englishContinent)) {
      return remoteContinents[englishContinent] as String;
    }

    // 2. Check local JSON asset
    final localContinents = _localTranslations?['continents'] as Map<String, dynamic>?;
    if (localContinents != null && localContinents.containsKey(englishContinent)) {
      return localContinents[englishContinent] as String;
    }

    // 3. Fall back to English
    return englishContinent;
  }

  /// Check if a country has a translation
  bool hasTranslation(String countryCode) {
    final code = countryCode.toUpperCase();

    final remoteCountries = _remoteOverrides?['countries'] as Map<String, dynamic>?;
    if (remoteCountries != null && remoteCountries.containsKey(code)) {
      return true;
    }

    final localCountries = _localTranslations?['countries'] as Map<String, dynamic>?;
    if (localCountries != null && localCountries.containsKey(code)) {
      return true;
    }

    return false;
  }

  /// Get all country codes that have translations
  Set<String> get translatedCountryCodes {
    final codes = <String>{};

    final remoteCountries = _remoteOverrides?['countries'] as Map<String, dynamic>?;
    if (remoteCountries != null) {
      codes.addAll(remoteCountries.keys);
    }

    final localCountries = _localTranslations?['countries'] as Map<String, dynamic>?;
    if (localCountries != null) {
      codes.addAll(localCountries.keys);
    }

    return codes;
  }

  /// Get translation version info
  String get version {
    return _localTranslations?['version'] as String? ?? 'unknown';
  }

  /// Get last updated date
  String get lastUpdated {
    return _localTranslations?['lastUpdated'] as String? ?? 'unknown';
  }

  /// Cache translations to Hive for offline access
  Future<void> cacheTranslations() async {
    if (!isHiveAvailable) return; // Hive not available

    try {
      final box = await _hive.openBox<String>(_translationsBox);
      if (_localTranslations != null) {
        await box.put('local', jsonEncode(_localTranslations));
      }
      if (_remoteOverrides != null && _remoteOverrides!.isNotEmpty) {
        await box.put('remote', jsonEncode(_remoteOverrides));
      }
      logger.debug('Translations cached to Hive', tag: 'TranslationService');
    } catch (e) {
      logger.warning(
        'Failed to cache translations',
        tag: 'TranslationService',
        error: e,
      );
    }
  }

  /// Load cached translations (for offline use)
  Future<void> loadCachedTranslations() async {
    if (!isHiveAvailable) return; // Hive not available

    try {
      final box = await _hive.openBox<String>(_translationsBox);

      final localJson = box.get('local');
      if (localJson != null) {
        _localTranslations = jsonDecode(localJson) as Map<String, dynamic>;
      }

      final remoteJson = box.get('remote');
      if (remoteJson != null) {
        _remoteOverrides = jsonDecode(remoteJson) as Map<String, dynamic>;
      }

      logger.debug('Loaded cached translations', tag: 'TranslationService');
    } catch (e) {
      logger.warning(
        'Failed to load cached translations',
        tag: 'TranslationService',
        error: e,
      );
    }
  }
}
