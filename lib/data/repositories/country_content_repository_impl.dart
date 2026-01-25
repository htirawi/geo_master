import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/cultural_item.dart';
import '../../domain/entities/phrase.dart';
import '../../domain/entities/place_of_interest.dart';
import '../../domain/repositories/i_country_content_repository.dart';
import '../datasources/remote/wikipedia_datasource.dart';

/// Country content repository implementation
class CountryContentRepositoryImpl implements ICountryContentRepository {
  CountryContentRepositoryImpl({
    required IWikipediaDataSource wikipediaDataSource,
    required HiveInterface hive,
  })  : _wikipediaDataSource = wikipediaDataSource,
        _hive = hive;

  final IWikipediaDataSource _wikipediaDataSource;
  final HiveInterface _hive;

  static const String _contentCacheBoxName = 'country_content_cache';
  static const Duration _cacheDuration = Duration(days: 7);

  Future<Box<String>?> get _cacheBox async {
    if (!isHiveAvailable) return null;

    try {
      if (!_hive.isBoxOpen(_contentCacheBoxName)) {
        return await _hive.openBox<String>(_contentCacheBoxName);
      }
      return _hive.box<String>(_contentCacheBoxName);
    } catch (e) {
      logger.warning('Failed to open content cache box', tag: 'ContentRepo', error: e);
      return null;
    }
  }

  @override
  Future<Either<Failure, CountryOverview>> getCountryOverview(
    String countryName, {
    bool isArabic = false,
  }) async {
    try {
      // Check cache first
      final cacheKey = 'overview_${countryName.toLowerCase()}_$isArabic';
      final cached = await _getCached<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return Right(_parseOverview(cached));
      }

      // Fetch from Wikipedia
      final summary = await _wikipediaDataSource.getSummary(
        countryName,
        isArabic: isArabic,
      );

      final overview = CountryOverview(
        summary: summary.extract,
        title: summary.title,
        imageUrl: summary.originalImageUrl ?? summary.thumbnailUrl,
        wikipediaUrl: summary.pageUrl,
        coordinates: summary.coordinates != null
            ? CountryCoordinates(
                latitude: summary.coordinates!.latitude,
                longitude: summary.coordinates!.longitude,
              )
            : null,
      );

      // Cache the result
      await _setCache(cacheKey, {
        'summary': overview.summary,
        'title': overview.title,
        'imageUrl': overview.imageUrl,
        'wikipediaUrl': overview.wikipediaUrl,
        'latitude': overview.coordinates?.latitude,
        'longitude': overview.coordinates?.longitude,
      });

      return Right(overview);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching overview', tag: 'ContentRepo', error: e);
      return const Left(ServerFailure(message: 'Failed to fetch overview'));
    }
  }

  CountryOverview _parseOverview(Map<String, dynamic> json) {
    return CountryOverview(
      summary: json['summary'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      wikipediaUrl: json['wikipediaUrl'] as String?,
      coordinates: json['latitude'] != null && json['longitude'] != null
          ? CountryCoordinates(
              latitude: (json['latitude'] as num).toDouble(),
              longitude: (json['longitude'] as num).toDouble(),
            )
          : null,
    );
  }

  @override
  Future<Either<Failure, GeographyInfo>> getGeographyInfo(
    String countryCode,
  ) async {
    try {
      // For now, return placeholder data
      // In a real app, this would fetch from a geography API or database
      return Right(GeographyInfo(
        countryCode: countryCode,
        terrainTypes: const [
          TerrainType(name: 'Mountains', percentage: 30, color: 0xFF8D6E63),
          TerrainType(name: 'Plains', percentage: 40, color: 0xFF81C784),
          TerrainType(name: 'Forests', percentage: 20, color: 0xFF2E7D32),
          TerrainType(name: 'Desert', percentage: 10, color: 0xFFFFD54F),
        ],
        climateZones: const [
          ClimateZone(
            name: 'Temperate',
            description: 'Moderate temperatures with distinct seasons',
            averageTempCelsius: 15,
            rainfallMm: 800,
          ),
        ],
        naturalHazards: const ['Earthquakes', 'Floods'],
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch geography'));
    }
  }

  @override
  Future<Either<Failure, List<PlaceOfInterest>>> getPlacesOfInterest(
    String countryCode, {
    PlaceType? type,
    int limit = 20,
  }) async {
    try {
      // Check cache
      final cacheKey = 'places_${countryCode}_${type?.name ?? 'all'}';
      final cached = await _getCached<List<dynamic>>(cacheKey);
      if (cached != null) {
        return Right(cached.map((e) => _parsePlace(e as Map<String, dynamic>)).toList());
      }

      // Return placeholder data - in real app, fetch from a places API
      final places = <PlaceOfInterest>[];
      // Placeholder implementation

      return Right(places);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch places'));
    }
  }

  PlaceOfInterest _parsePlace(Map<String, dynamic> json) {
    return PlaceOfInterest(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      type: PlaceType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PlaceType.landmark,
      ),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  Future<Either<Failure, List<PlaceOfInterest>>> getUnescoSites(
    String countryCode,
  ) async {
    final result = await getPlacesOfInterest(countryCode);
    return result.fold(
      Left.new,
      (places) => Right(places.where((p) => p.isUnescoSite).toList()),
    );
  }

  @override
  Future<Either<Failure, PlaceOfInterest>> getPlaceDetails(String placeId) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<CulturalItem>>> getCulturalItems(
    String countryCode, {
    CulturalItemType? type,
  }) async {
    try {
      // Return placeholder data
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch cultural items'));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getFamousFoods(
    String countryCode,
  ) async {
    try {
      // Return placeholder data - would fetch from a food/culture API
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch foods'));
    }
  }

  @override
  Future<Either<Failure, List<FestivalItem>>> getFestivals(
    String countryCode, {
    int? month,
  }) async {
    try {
      // Return placeholder data
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch festivals'));
    }
  }

  @override
  Future<Either<Failure, List<FamousPerson>>> getFamousPeople(
    String countryCode,
  ) async {
    try {
      // Return placeholder data
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch famous people'));
    }
  }

  @override
  Future<Either<Failure, List<FunFact>>> getFunFacts(String countryCode) async {
    try {
      // Return placeholder data
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch fun facts'));
    }
  }

  @override
  Future<Either<Failure, List<Phrase>>> getEssentialPhrases(
    String countryCode, {
    PhraseCategory? category,
    int limit = 50,
  }) async {
    try {
      // Return placeholder data - would fetch from a language/phrases API
      return const Right([]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch phrases'));
    }
  }

  @override
  Future<Either<Failure, Phrase>> getPhraseById(String phraseId) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, TravelEssentials>> getTravelEssentials(
    String countryCode,
  ) async {
    try {
      // Return placeholder data - would fetch from a travel info API
      return Right(TravelEssentials(
        countryCode: countryCode,
        electricityPlugTypes: const ['Type A', 'Type B'],
        voltage: 120,
        frequency: 60,
        emergencyNumbers: const {
          'Police': '911',
          'Ambulance': '911',
          'Fire': '911',
        },
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch travel essentials'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTravelTips(
    String countryCode,
  ) async {
    try {
      // Return placeholder tips
      return const Right([
        'Research local customs before you travel',
        'Keep copies of important documents',
        'Register with your embassy',
        'Get travel insurance',
      ]);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to fetch travel tips'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCountryCache(String countryCode) async {
    try {
      final box = await _cacheBox;
      if (box == null) return const Right(null); // Hive not available

      final keysToDelete = box.keys
          .where((key) => key.toString().contains(countryCode.toLowerCase()))
          .toList();

      for (final key in keysToDelete) {
        await box.delete(key);
      }

      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear cache'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllCache() async {
    try {
      final box = await _cacheBox;
      if (box == null) return const Right(null); // Hive not available

      await box.clear();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear cache'));
    }
  }

  // Cache helpers
  Future<T?> _getCached<T>(String key) async {
    try {
      final box = await _cacheBox;
      if (box == null) return null; // Hive not available

      final data = box.get(key);
      if (data == null) return null;

      final cacheEntry = jsonDecode(data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheEntry['timestamp'] as String);

      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await box.delete(key);
        return null;
      }

      return cacheEntry['data'] as T;
    } catch (e) {
      return null;
    }
  }

  Future<void> _setCache(String key, dynamic data) async {
    try {
      final box = await _cacheBox;
      if (box == null) return; // Hive not available

      final cacheEntry = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      });
      await box.put(key, cacheEntry);
    } catch (e) {
      logger.warning('Failed to cache data', tag: 'ContentRepo', error: e);
    }
  }
}
