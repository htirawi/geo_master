import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../core/utils/retry_helper.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../datasources/remote/rest_countries_datasource.dart';
import '../models/country_model.dart';

/// Country repository implementation with caching
class CountryRepositoryImpl implements ICountryRepository {
  CountryRepositoryImpl({
    required IRestCountriesDataSource restCountriesDataSource,
    required HiveInterface hive,
  })  : _restCountriesDataSource = restCountriesDataSource,
        _hive = hive;

  final IRestCountriesDataSource _restCountriesDataSource;
  final HiveInterface _hive;

  static const String _cacheBoxName = 'countries_cache';
  static const String _allCountriesKey = 'all_countries';
  static const Duration _cacheDuration = Duration(days: 7);

  /// Country codes to exclude from all queries
  static const Set<String> _excludedCountryCodes = {'IL', 'ISR'};

  /// Filter out excluded country models before caching
  List<CountryModel> _filterExcludedModels(List<CountryModel> models) {
    return models
        .where((m) =>
            !_excludedCountryCodes.contains(m.cca2.toUpperCase()) &&
            !_excludedCountryCodes.contains(m.cca3.toUpperCase()))
        .toList();
  }

  /// Check if a country code is excluded
  bool _isExcludedCode(String code) {
    return _excludedCountryCodes.contains(code.toUpperCase());
  }

  Future<Box<String>?> get _cacheBox async {
    // Check if Hive was successfully initialized
    if (!isHiveAvailable) {
      return null;
    }
    try {
      if (!_hive.isBoxOpen(_cacheBoxName)) {
        return await _hive.openBox<String>(_cacheBoxName);
      }
      return _hive.box<String>(_cacheBoxName);
    } catch (e) {
      logger.warning('Failed to open Hive cache box', tag: 'CountryRepo', error: e);
      return null;
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getAllCountries({
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get cached data first
      if (!forceRefresh) {
        final cachedCountries = await _getCachedCountries();
        if (cachedCountries != null) {
          logger.debug('Returning cached countries', tag: 'CountryRepo');
          return Right(cachedCountries);
        }
      }

      // Fetch from API with retry logic
      final countryModels = await RetryHelper.retry(
        operation: _restCountriesDataSource.getAllCountries,
        config: RetryConfig.network,
        operationName: 'getAllCountries',
      );

      // Filter out excluded countries before processing
      final filteredModels = _filterExcludedModels(countryModels);
      final countries = filteredModels.map((m) => m.toEntity()).toList();

      // Sort by name
      countries.sort((a, b) => a.name.compareTo(b.name));

      // Cache the filtered results
      await _cacheCountries(filteredModels);

      logger.debug('Fetched ${countries.length} countries from API', tag: 'CountryRepo');
      return Right(countries);
    } on NetworkException catch (e) {
      // Try to return cached data if network error
      final cachedCountries = await _getCachedCountries();
      if (cachedCountries != null) {
        logger.info('Network error, returning cached countries', tag: 'CountryRepo');
        return Right(cachedCountries);
      }
      logger.error('Network error and no cache available', tag: 'CountryRepo', error: e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      logger.error('Server error fetching countries', tag: 'CountryRepo', error: e);
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error fetching countries',
        tag: 'CountryRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Country>> getCountryByCode(String code) async {
    try {
      // Check if this country code is excluded
      if (_isExcludedCode(code)) {
        return const Left(ServerFailure(message: 'Country not found'));
      }

      // Try cache first
      final cachedCountries = await _getCachedCountries();
      if (cachedCountries != null) {
        final cached = cachedCountries.where(
          (c) => c.code.toLowerCase() == code.toLowerCase() ||
              c.cca3.toLowerCase() == code.toLowerCase(),
        );
        if (cached.isNotEmpty) {
          return Right(cached.first);
        }
      }

      // Fetch from API
      final countryModel = await _restCountriesDataSource.getCountryByCode(code);

      // Double-check the returned model isn't excluded
      if (_excludedCountryCodes.contains(countryModel.cca2.toUpperCase()) ||
          _excludedCountryCodes.contains(countryModel.cca3.toUpperCase())) {
        return const Left(ServerFailure(message: 'Country not found'));
      }

      return Right(countryModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getCountriesByRegion(
    String region,
  ) async {
    try {
      // Try cache first (already filtered)
      final cachedCountries = await _getCachedCountries();
      if (cachedCountries != null) {
        final filtered = cachedCountries
            .where((c) => c.region.toLowerCase() == region.toLowerCase())
            .toList();
        if (filtered.isNotEmpty) {
          return Right(filtered);
        }
      }

      // Fetch from API
      final countryModels =
          await _restCountriesDataSource.getCountriesByRegion(region);

      // Filter out excluded countries
      final filteredModels = _filterExcludedModels(countryModels);
      final countries = filteredModels.map((m) => m.toEntity()).toList();
      countries.sort((a, b) => a.name.compareTo(b.name));
      return Right(countries);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> searchCountries(String query) async {
    try {
      // Search in cache first (already filtered)
      final cachedCountries = await _getCachedCountries();
      if (cachedCountries != null) {
        final lowerQuery = query.toLowerCase();
        final filtered = cachedCountries.where((c) =>
            c.name.toLowerCase().contains(lowerQuery) ||
            c.nativeName.toLowerCase().contains(lowerQuery) ||
            c.nameArabic.toLowerCase().contains(lowerQuery) ||
            (c.capital?.toLowerCase().contains(lowerQuery) ?? false) ||
            c.code.toLowerCase() == lowerQuery);
        if (filtered.isNotEmpty) {
          return Right(filtered.toList());
        }
      }

      // Fetch from API
      final countryModels =
          await _restCountriesDataSource.searchCountriesByName(query);

      // Filter out excluded countries
      final filteredModels = _filterExcludedModels(countryModels);
      final countries = filteredModels.map((m) => m.toEntity()).toList();
      countries.sort((a, b) => a.name.compareTo(b.name));
      return Right(countries);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Country>> getRandomCountry() async {
    try {
      final result = await getAllCountries();
      return result.fold(
        Left.new,
        (countries) {
          if (countries.isEmpty) {
            return const Left(ServerFailure(message: 'No countries available'));
          }
          final random = DateTime.now().millisecondsSinceEpoch % countries.length;
          return Right(countries[random]);
        },
      );
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getCountriesForQuiz({
    String? region,
    int count = 4,
  }) async {
    try {
      final Either<Failure, List<Country>> result;
      if (region != null) {
        result = await getCountriesByRegion(region);
      } else {
        result = await getAllCountries();
      }

      return result.fold(
        Left.new,
        (countries) {
          if (countries.length < count) {
            return Right(countries);
          }
          // Shuffle and take count
          final shuffled = List<Country>.from(countries)..shuffle();
          return Right(shuffled.take(count).toList());
        },
      );
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  /// Get cached countries
  Future<List<Country>?> _getCachedCountries() async {
    try {
      final box = await _cacheBox;
      if (box == null) return null; // Hive not available

      final cachedData = box.get(_allCountriesKey);
      if (cachedData == null) return null;

      final cacheMap = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheMap['timestamp'] as String);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        logger.debug('Cache expired, deleting', tag: 'CountryRepo');
        await box.delete(_allCountriesKey);
        return null;
      }

      final countriesJson = cacheMap['data'] as List<dynamic>;
      final models = countriesJson
          .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter out excluded countries from cached data
      final filteredModels = _filterExcludedModels(models);
      return filteredModels.map((m) => m.toEntity()).toList();
    } catch (e) {
      logger.warning(
        'Failed to read countries cache',
        tag: 'CountryRepo',
        error: e,
      );
      return null;
    }
  }

  /// Cache countries
  Future<void> _cacheCountries(List<CountryModel> countries) async {
    try {
      final box = await _cacheBox;
      if (box == null) return; // Hive not available, skip caching

      final cacheData = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': countries.map((c) => c.toJson()).toList(),
      });
      await box.put(_allCountriesKey, cacheData);
      logger.debug('Cached ${countries.length} countries', tag: 'CountryRepo');
    } catch (e) {
      // Log but don't fail the operation
      logger.warning(
        'Failed to cache countries',
        tag: 'CountryRepo',
        error: e,
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final box = await _cacheBox;
      if (box == null) {
        // Hive not available, nothing to clear
        return const Right(null);
      }
      await box.clear();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear cache'));
    }
  }
}
