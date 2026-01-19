import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/cultural_item.dart';
import '../entities/phrase.dart';
import '../entities/place_of_interest.dart';

/// Country content repository interface for extended content
abstract class ICountryContentRepository {
  // Wikipedia Content

  /// Get country overview/summary from Wikipedia
  Future<Either<Failure, CountryOverview>> getCountryOverview(
    String countryName, {
    bool isArabic = false,
  });

  /// Get geography information
  Future<Either<Failure, GeographyInfo>> getGeographyInfo(String countryCode);

  // Places of Interest

  /// Get places of interest for a country
  Future<Either<Failure, List<PlaceOfInterest>>> getPlacesOfInterest(
    String countryCode, {
    PlaceType? type,
    int limit = 20,
  });

  /// Get UNESCO World Heritage sites for a country
  Future<Either<Failure, List<PlaceOfInterest>>> getUnescoSites(String countryCode);

  /// Get place details
  Future<Either<Failure, PlaceOfInterest>> getPlaceDetails(String placeId);

  // Cultural Items

  /// Get cultural items for a country
  Future<Either<Failure, List<CulturalItem>>> getCulturalItems(
    String countryCode, {
    CulturalItemType? type,
  });

  /// Get famous foods for a country
  Future<Either<Failure, List<FoodItem>>> getFamousFoods(String countryCode);

  /// Get festivals for a country
  Future<Either<Failure, List<FestivalItem>>> getFestivals(
    String countryCode, {
    int? month,
  });

  /// Get famous people from a country
  Future<Either<Failure, List<FamousPerson>>> getFamousPeople(String countryCode);

  /// Get fun facts for a country
  Future<Either<Failure, List<FunFact>>> getFunFacts(String countryCode);

  // Phrases

  /// Get essential phrases for a country
  Future<Either<Failure, List<Phrase>>> getEssentialPhrases(
    String countryCode, {
    PhraseCategory? category,
    int limit = 50,
  });

  /// Get phrase by ID
  Future<Either<Failure, Phrase>> getPhraseById(String phraseId);

  // Travel Info

  /// Get travel essentials for a country
  Future<Either<Failure, TravelEssentials>> getTravelEssentials(String countryCode);

  /// Get packing tips and travel tips
  Future<Either<Failure, List<String>>> getTravelTips(String countryCode);

  // Cache

  /// Clear content cache for a country
  Future<Either<Failure, void>> clearCountryCache(String countryCode);

  /// Clear all content cache
  Future<Either<Failure, void>> clearAllCache();
}

/// Country overview from Wikipedia
class CountryOverview {
  const CountryOverview({
    required this.summary,
    required this.title,
    this.imageUrl,
    this.wikipediaUrl,
    this.coordinates,
  });

  final String summary;
  final String title;
  final String? imageUrl;
  final String? wikipediaUrl;
  final CountryCoordinates? coordinates;
}

/// Coordinates for a country
class CountryCoordinates {
  const CountryCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Geography information
class GeographyInfo {
  const GeographyInfo({
    required this.countryCode,
    this.terrainTypes = const [],
    this.climateZones = const [],
    this.naturalHazards = const [],
    this.highestPoint,
    this.lowestPoint,
    this.coastlineKm,
    this.forestCoverage,
    this.waterBodies = const [],
    this.regions = const [],
  });

  final String countryCode;
  final List<TerrainType> terrainTypes;
  final List<ClimateZone> climateZones;
  final List<String> naturalHazards;
  final String? highestPoint;
  final String? lowestPoint;
  final double? coastlineKm;
  final double? forestCoverage;
  final List<String> waterBodies;
  final List<RegionInfo> regions;
}

/// Terrain type with percentage
class TerrainType {
  const TerrainType({
    required this.name,
    required this.percentage,
    this.color,
  });

  final String name;
  final double percentage;
  final int? color;
}

/// Climate zone information
class ClimateZone {
  const ClimateZone({
    required this.name,
    this.description,
    this.averageTempCelsius,
    this.rainfallMm,
  });

  final String name;
  final String? description;
  final double? averageTempCelsius;
  final double? rainfallMm;
}

/// Region/administrative division info
class RegionInfo {
  const RegionInfo({
    required this.name,
    this.capital,
    this.population,
    this.area,
  });

  final String name;
  final String? capital;
  final int? population;
  final double? area;
}

/// Travel essentials information
class TravelEssentials {
  const TravelEssentials({
    required this.countryCode,
    this.visaRequired,
    this.visaOnArrival = false,
    this.visaNotes,
    this.electricityPlugTypes = const [],
    this.voltage,
    this.frequency,
    this.drivingSide,
    this.emergencyNumbers = const {},
    this.tippingCulture,
    this.bestTimeToVisit,
    this.averageDailyBudgetUsd,
    this.safetyLevel,
    this.healthWarnings = const [],
    this.requiredVaccinations = const [],
    this.currencyTips,
    this.connectivityInfo,
  });

  final String countryCode;
  final bool? visaRequired;
  final bool visaOnArrival;
  final String? visaNotes;
  final List<String> electricityPlugTypes;
  final int? voltage;
  final int? frequency;
  final String? drivingSide;
  final Map<String, String> emergencyNumbers;
  final String? tippingCulture;
  final String? bestTimeToVisit;
  final double? averageDailyBudgetUsd;
  final String? safetyLevel;
  final List<String> healthWarnings;
  final List<String> requiredVaccinations;
  final String? currencyTips;
  final String? connectivityInfo;
}
