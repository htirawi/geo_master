import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/continent.dart';
import '../entities/country.dart';
import '../entities/country_progress.dart';

/// World exploration repository interface
abstract class IWorldExplorationRepository {
  // Continent Methods

  /// Get all continents with stats
  Future<Either<Failure, List<Continent>>> getAllContinents();

  /// Get continent by ID
  Future<Either<Failure, Continent>> getContinentById(String id);

  /// Get countries by continent
  Future<Either<Failure, List<Country>>> getCountriesByContinent(String continentId);

  /// Get continent progress for user
  Future<Either<Failure, ContinentProgress>> getContinentProgress(String continentId);

  /// Update continent progress
  Future<Either<Failure, void>> updateContinentProgress(
    String continentId,
    ContinentProgress progress,
  );

  // Country Progress Methods

  /// Get progress for a specific country
  Future<Either<Failure, CountryProgress>> getCountryProgress(String countryCode);

  /// Get progress for all countries
  Future<Either<Failure, Map<String, CountryProgress>>> getAllCountryProgress();

  /// Update country progress
  Future<Either<Failure, void>> updateCountryProgress(CountryProgress progress);

  /// Mark country as visited
  Future<Either<Failure, CountryProgress>> markCountryVisited(String countryCode);

  /// Toggle country favorite
  Future<Either<Failure, CountryProgress>> toggleFavorite(String countryCode);

  /// Add bookmarked fact
  Future<Either<Failure, void>> addBookmarkedFact(String countryCode, String factId);

  /// Remove bookmarked fact
  Future<Either<Failure, void>> removeBookmarkedFact(String countryCode, String factId);

  /// Get favorite countries
  Future<Either<Failure, List<String>>> getFavoriteCountryCodes();

  // Map Markers

  /// Get country markers for map with progress colors
  Future<Either<Failure, List<CountryMapMarker>>> getCountryMarkers({
    String? continentFilter,
    ProgressLevel? progressFilter,
    bool favoritesOnly = false,
  });

  // Random Country

  /// Get random country (with optional filters)
  Future<Either<Failure, Country>> getRandomCountry({
    String? continentId,
    bool excludeVisited = false,
  });

  // Search

  /// Search countries with autocomplete
  Future<Either<Failure, List<Country>>> searchCountriesAutocomplete(
    String query, {
    int limit = 10,
  });

  /// Search countries (alias for searchCountriesAutocomplete)
  Future<Either<Failure, List<Country>>> searchCountries(String query);

  /// Get country by code
  Future<Either<Failure, Country>> getCountryByCode(String code);

  // Cache

  /// Clear exploration cache
  Future<Either<Failure, void>> clearCache();

  /// Sync progress with server
  Future<Either<Failure, void>> syncProgress();
}

/// Country map marker with location and progress
class CountryMapMarker {
  const CountryMapMarker({
    required this.countryCode,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.progressLevel,
    this.isFavorite = false,
  });

  final String countryCode;
  final String name;
  final double latitude;
  final double longitude;
  final ProgressLevel progressLevel;
  final bool isFavorite;

  /// Get marker color based on progress level
  int get markerColor => progressLevel.colorValue;
}
