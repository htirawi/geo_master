import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/country.dart';

/// Country repository interface
abstract class ICountryRepository {
  /// Get all countries
  Future<Either<Failure, List<Country>>> getAllCountries({
    bool forceRefresh = false,
  });

  /// Get country by code
  Future<Either<Failure, Country>> getCountryByCode(String code);

  /// Get countries by region
  Future<Either<Failure, List<Country>>> getCountriesByRegion(String region);

  /// Search countries by name
  Future<Either<Failure, List<Country>>> searchCountries(String query);

  /// Get random country (for "Country of the Day")
  Future<Either<Failure, Country>> getRandomCountry();

  /// Get countries for quiz (filtered and shuffled)
  Future<Either<Failure, List<Country>>> getCountriesForQuiz({
    String? region,
    int count = 4,
  });

  /// Clear country cache
  Future<Either<Failure, void>> clearCache();
}
