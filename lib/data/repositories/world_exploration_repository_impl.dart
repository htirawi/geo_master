import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/continent.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/country_progress.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';
import '../models/continent_model.dart';
import '../models/country_progress_model.dart';

/// World exploration repository implementation
class WorldExplorationRepositoryImpl implements IWorldExplorationRepository {
  WorldExplorationRepositoryImpl({
    required ICountryRepository countryRepository,
    required HiveInterface hive,
  })  : _countryRepository = countryRepository,
        _hive = hive;

  final ICountryRepository _countryRepository;
  final HiveInterface _hive;

  static const String _progressBoxName = 'country_progress';
  static const String _continentBoxName = 'continents_cache';

  Future<Box<String>> get _progressBox async {
    if (!_hive.isBoxOpen(_progressBoxName)) {
      return await _hive.openBox<String>(_progressBoxName);
    }
    return _hive.box<String>(_progressBoxName);
  }

  Future<Box<String>> get _continentBox async {
    if (!_hive.isBoxOpen(_continentBoxName)) {
      return await _hive.openBox<String>(_continentBoxName);
    }
    return _hive.box<String>(_continentBoxName);
  }

  // Continent data - static for now
  static final List<ContinentModel> _continentData = [
    const ContinentModel(
      id: ContinentIds.africa,
      name: 'Africa',
      nameArabic: 'أفريقيا',
      imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5',
      countryCount: 54,
      totalPopulation: 1400000000,
      totalArea: 30370000,
      description: 'The world\'s second-largest and second-most populous continent.',
      descriptionArabic: 'ثاني أكبر قارة وثاني أكثر قارة اكتظاظًا بالسكان.',
    ),
    const ContinentModel(
      id: ContinentIds.asia,
      name: 'Asia',
      nameArabic: 'آسيا',
      imageUrl: 'https://images.unsplash.com/photo-1480796927426-f609979314bd',
      countryCount: 48,
      totalPopulation: 4700000000,
      totalArea: 44579000,
      description: 'The largest and most populous continent, home to diverse cultures.',
      descriptionArabic: 'أكبر قارة وأكثرها اكتظاظًا بالسكان، موطن لثقافات متنوعة.',
    ),
    const ContinentModel(
      id: ContinentIds.europe,
      name: 'Europe',
      nameArabic: 'أوروبا',
      imageUrl: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b',
      countryCount: 44,
      totalPopulation: 750000000,
      totalArea: 10180000,
      description: 'A continent with rich history and cultural heritage.',
      descriptionArabic: 'قارة ذات تاريخ وتراث ثقافي غني.',
    ),
    const ContinentModel(
      id: ContinentIds.northAmerica,
      name: 'North America',
      nameArabic: 'أمريكا الشمالية',
      imageUrl: 'https://images.unsplash.com/photo-1485738422979-f5c462d49f74',
      countryCount: 23,
      totalPopulation: 580000000,
      totalArea: 24709000,
      description: 'The third-largest continent, known for its natural wonders.',
      descriptionArabic: 'ثالث أكبر قارة، معروفة بعجائبها الطبيعية.',
    ),
    const ContinentModel(
      id: ContinentIds.southAmerica,
      name: 'South America',
      nameArabic: 'أمريكا الجنوبية',
      imageUrl: 'https://images.unsplash.com/photo-1619546952812-520e98064a52',
      countryCount: 12,
      totalPopulation: 430000000,
      totalArea: 17840000,
      description: 'Home to the Amazon rainforest and diverse ecosystems.',
      descriptionArabic: 'موطن غابات الأمازون والنظم البيئية المتنوعة.',
    ),
    const ContinentModel(
      id: ContinentIds.oceania,
      name: 'Oceania',
      nameArabic: 'أوقيانوسيا',
      imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9',
      countryCount: 16,
      totalPopulation: 45000000,
      totalArea: 8525989,
      description: 'The smallest continent, featuring unique wildlife.',
      descriptionArabic: 'أصغر قارة، تتميز بحياة برية فريدة.',
    ),
    const ContinentModel(
      id: ContinentIds.antarctica,
      name: 'Antarctica',
      nameArabic: 'أنتاركتيكا',
      imageUrl: 'https://images.unsplash.com/photo-1551415923-a2297c7fda79',
      countryCount: 0,
      totalPopulation: 1000,
      totalArea: 14000000,
      description: 'The coldest, driest, and windiest continent.',
      descriptionArabic: 'أبرد قارة وأكثرها جفافاً ورياحاً.',
    ),
  ];

  @override
  Future<Either<Failure, List<Continent>>> getAllContinents() async {
    try {
      final continents = <Continent>[];

      for (final model in _continentData) {
        // Get progress for each continent
        final progressResult = await getContinentProgress(model.id);
        final progress = progressResult.fold(
          (_) => const ContinentProgress(),
          (p) => p,
        );

        continents.add(model.toEntity().copyWith(progress: progress));
      }

      return Right(continents);
    } catch (e) {
      logger.error('Error getting continents', tag: 'WorldExplRepo', error: e);
      return Left(ServerFailure(message: 'Failed to get continents'));
    }
  }

  @override
  Future<Either<Failure, Continent>> getContinentById(String id) async {
    try {
      final model = _continentData.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Continent not found'),
      );

      final progressResult = await getContinentProgress(id);
      final progress = progressResult.fold(
        (_) => const ContinentProgress(),
        (p) => p,
      );

      return Right(model.toEntity().copyWith(progress: progress));
    } catch (e) {
      return Left(ServerFailure(message: 'Continent not found: $id'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getCountriesByContinent(
    String continentId,
  ) async {
    try {
      // Handle Americas specially - they share the same region in REST Countries API
      if (continentId == ContinentIds.northAmerica ||
          continentId == ContinentIds.southAmerica) {
        return _getAmericasCountries(continentId);
      }

      // Map continent ID to region name
      final regionName = _continentIdToRegion(continentId);
      if (regionName == null) {
        return const Left(ServerFailure(message: 'Invalid continent ID'));
      }

      return _countryRepository.getCountriesByRegion(regionName);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get countries'));
    }
  }

  /// Get Americas countries filtered by subregion
  Future<Either<Failure, List<Country>>> _getAmericasCountries(
    String continentId,
  ) async {
    final result = await _countryRepository.getCountriesByRegion('Americas');
    return result.fold(
      Left.new,
      (countries) {
        // North America subregions: Northern America, Central America, Caribbean
        // South America subregion: South America
        final isNorthAmerica = continentId == ContinentIds.northAmerica;

        final filtered = countries.where((c) {
          final subregion = (c.subregion ?? '').toLowerCase();
          if (isNorthAmerica) {
            return subregion.contains('northern') ||
                   subregion.contains('central') ||
                   subregion.contains('caribbean');
          } else {
            return subregion.contains('south');
          }
        }).toList();

        return Right(filtered);
      },
    );
  }

  String? _continentIdToRegion(String continentId) {
    switch (continentId) {
      case ContinentIds.africa:
        return 'Africa';
      case ContinentIds.asia:
        return 'Asia';
      case ContinentIds.europe:
        return 'Europe';
      case ContinentIds.oceania:
        return 'Oceania';
      case ContinentIds.antarctica:
        return 'Antarctic';
      default:
        return null;
    }
  }

  @override
  Future<Either<Failure, ContinentProgress>> getContinentProgress(
    String continentId,
  ) async {
    try {
      final box = await _continentBox;
      final data = box.get('progress_$continentId');

      if (data != null) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        return Right(ContinentProgressModel.fromJson(json).toEntity());
      }

      return const Right(ContinentProgress());
    } catch (e) {
      return const Right(ContinentProgress());
    }
  }

  @override
  Future<Either<Failure, void>> updateContinentProgress(
    String continentId,
    ContinentProgress progress,
  ) async {
    try {
      final box = await _continentBox;
      final model = ContinentProgressModel.fromEntity(progress);
      await box.put('progress_$continentId', jsonEncode(model.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save progress'));
    }
  }

  @override
  Future<Either<Failure, CountryProgress>> getCountryProgress(
    String countryCode,
  ) async {
    try {
      final box = await _progressBox;
      final data = box.get(countryCode.toUpperCase());

      if (data != null) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        return Right(CountryProgressModel.fromJson(json).toEntity());
      }

      return Right(CountryProgress(countryCode: countryCode.toUpperCase()));
    } catch (e) {
      return Right(CountryProgress(countryCode: countryCode.toUpperCase()));
    }
  }

  @override
  Future<Either<Failure, Map<String, CountryProgress>>> getAllCountryProgress() async {
    try {
      final box = await _progressBox;
      final progress = <String, CountryProgress>{};

      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          final json = jsonDecode(data) as Map<String, dynamic>;
          progress[key as String] = CountryProgressModel.fromJson(json).toEntity();
        }
      }

      return Right(progress);
    } catch (e) {
      return const Right({});
    }
  }

  @override
  Future<Either<Failure, void>> updateCountryProgress(
    CountryProgress progress,
  ) async {
    try {
      final box = await _progressBox;
      final model = CountryProgressModel.fromEntity(progress);
      await box.put(progress.countryCode.toUpperCase(), jsonEncode(model.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save progress'));
    }
  }

  @override
  Future<Either<Failure, CountryProgress>> markCountryVisited(
    String countryCode,
  ) async {
    try {
      final progressResult = await getCountryProgress(countryCode);
      final currentProgress = progressResult.fold(
        (_) => CountryProgress(countryCode: countryCode.toUpperCase()),
        (p) => p,
      );

      final now = DateTime.now();
      final updatedProgress = currentProgress.copyWith(
        exploredAt: currentProgress.exploredAt ?? now,
        lastVisitedAt: now,
        visitCount: currentProgress.visitCount + 1,
      );

      await updateCountryProgress(updatedProgress);
      return Right(updatedProgress);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to mark visited'));
    }
  }

  @override
  Future<Either<Failure, CountryProgress>> toggleFavorite(
    String countryCode,
  ) async {
    try {
      final progressResult = await getCountryProgress(countryCode);
      final currentProgress = progressResult.fold(
        (_) => CountryProgress(countryCode: countryCode.toUpperCase()),
        (p) => p,
      );

      final updatedProgress = currentProgress.copyWith(
        isFavorite: !currentProgress.isFavorite,
      );

      await updateCountryProgress(updatedProgress);
      return Right(updatedProgress);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to toggle favorite'));
    }
  }

  @override
  Future<Either<Failure, void>> addBookmarkedFact(
    String countryCode,
    String factId,
  ) async {
    try {
      final progressResult = await getCountryProgress(countryCode);
      final currentProgress = progressResult.fold(
        (_) => CountryProgress(countryCode: countryCode.toUpperCase()),
        (p) => p,
      );

      if (!currentProgress.bookmarkedFacts.contains(factId)) {
        final updatedProgress = currentProgress.copyWith(
          bookmarkedFacts: [...currentProgress.bookmarkedFacts, factId],
        );
        await updateCountryProgress(updatedProgress);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to bookmark fact'));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmarkedFact(
    String countryCode,
    String factId,
  ) async {
    try {
      final progressResult = await getCountryProgress(countryCode);
      final currentProgress = progressResult.fold(
        (_) => CountryProgress(countryCode: countryCode.toUpperCase()),
        (p) => p,
      );

      final updatedProgress = currentProgress.copyWith(
        bookmarkedFacts: currentProgress.bookmarkedFacts
            .where((f) => f != factId)
            .toList(),
      );

      await updateCountryProgress(updatedProgress);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to remove bookmark'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteCountryCodes() async {
    try {
      final progressResult = await getAllCountryProgress();
      return progressResult.fold(
        Left.new,
        (progress) {
          final favorites = progress.entries
              .where((e) => e.value.isFavorite)
              .map((e) => e.key)
              .toList();
          return Right(favorites);
        },
      );
    } catch (e) {
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, List<CountryMapMarker>>> getCountryMarkers({
    String? continentFilter,
    ProgressLevel? progressFilter,
    bool favoritesOnly = false,
  }) async {
    try {
      // Get all countries
      final countriesResult = await _countryRepository.getAllCountries();

      return countriesResult.fold(
        Left.new,
        (countries) async {
          // Get all progress
          final progressResult = await getAllCountryProgress();
          final allProgress = progressResult.fold((_) => <String, CountryProgress>{}, (p) => p);

          // Filter countries
          var filteredCountries = countries;

          if (continentFilter != null) {
            filteredCountries = filteredCountries
                .where((c) => c.continents.any(
                    (cont) => cont.toLowerCase().contains(continentFilter.toLowerCase())))
                .toList();
          }

          // Create markers
          final markers = <CountryMapMarker>[];

          for (final country in filteredCountries) {
            final progress = allProgress[country.code.toUpperCase()];
            final progressLevel = progress?.progressLevel ?? ProgressLevel.notStarted;
            final isFavorite = progress?.isFavorite ?? false;

            // Apply filters
            if (progressFilter != null && progressLevel != progressFilter) {
              continue;
            }
            if (favoritesOnly && !isFavorite) {
              continue;
            }

            markers.add(CountryMapMarker(
              countryCode: country.code,
              name: country.name,
              latitude: country.coordinates.latitude,
              longitude: country.coordinates.longitude,
              progressLevel: progressLevel,
              isFavorite: isFavorite,
            ));
          }

          return Right(markers);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get markers'));
    }
  }

  @override
  Future<Either<Failure, Country>> getRandomCountry({
    String? continentId,
    bool excludeVisited = false,
  }) async {
    try {
      List<Country> countries;

      if (continentId != null) {
        final result = await getCountriesByContinent(continentId);
        countries = result.fold((_) => [], (c) => c);
      } else {
        final result = await _countryRepository.getAllCountries();
        countries = result.fold((_) => [], (c) => c);
      }

      if (countries.isEmpty) {
        return const Left(ServerFailure(message: 'No countries available'));
      }

      if (excludeVisited) {
        final progressResult = await getAllCountryProgress();
        final allProgress = progressResult.fold((_) => <String, CountryProgress>{}, (p) => p);

        countries = countries.where((c) {
          final progress = allProgress[c.code.toUpperCase()];
          return progress == null || !progress.isExplored;
        }).toList();

        if (countries.isEmpty) {
          return const Left(ServerFailure(message: 'All countries have been visited'));
        }
      }

      final random = DateTime.now().millisecondsSinceEpoch % countries.length;
      return Right(countries[random]);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get random country'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> searchCountriesAutocomplete(
    String query, {
    int limit = 10,
  }) async {
    try {
      final result = await _countryRepository.searchCountries(query);
      return result.fold(
        Left.new,
        (countries) => Right(countries.take(limit).toList()),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Search failed'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> searchCountries(String query) async {
    return searchCountriesAutocomplete(query);
  }

  @override
  Future<Either<Failure, Country>> getCountryByCode(String code) async {
    try {
      return _countryRepository.getCountryByCode(code);
    } catch (e) {
      return Left(ServerFailure(message: 'Country not found'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final progressBox = await _progressBox;
      final continentBox = await _continentBox;
      await progressBox.clear();
      await continentBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cache'));
    }
  }

  @override
  Future<Either<Failure, void>> syncProgress() async {
    // For now, this is a no-op as we don't have server sync implemented
    // In the future, this would sync local progress with Firebase
    return const Right(null);
  }
}
