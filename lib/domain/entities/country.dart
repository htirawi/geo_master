import 'package:flutter/foundation.dart';

/// Country entity
@immutable
class Country {
  const Country({
    required this.code,
    required this.code3,
    required this.name,
    required this.nameArabic,
    this.capital,
    this.capitalArabic,
    required this.region,
    this.subregion,
    required this.population,
    required this.area,
    this.languages = const [],
    this.currencies = const [],
    required this.flagUrl,
    this.coatOfArmsUrl,
    required this.coordinates,
    this.borders = const [],
    this.timezones = const [],
    this.continents = const [],
    this.isUnMember = false,
    this.isLandlocked = false,
    this.drivingSide,
  });

  final String code; // ISO 3166-1 alpha-2 (e.g., "US", "JP")
  final String code3; // ISO 3166-1 alpha-3 (e.g., "USA", "JPN")
  final String name;
  final String nameArabic;
  final String? capital;
  final String? capitalArabic;
  final String region;
  final String? subregion;
  final int population;
  final double area; // in km²
  final List<String> languages;
  final List<Currency> currencies;
  final String flagUrl;
  final String? coatOfArmsUrl;
  final LatLng coordinates;
  final List<String> borders; // Country codes
  final List<String> timezones;
  final List<String> continents;
  final bool isUnMember;
  final bool isLandlocked;
  final String? drivingSide; // "left" or "right"

  /// Get display name based on locale
  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  /// Get display capital based on locale
  String? getDisplayCapital({required bool isArabic}) {
    if (isArabic && capitalArabic != null) return capitalArabic;
    return capital;
  }

  /// Get formatted population
  String get formattedPopulation {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(2)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(2)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(2)}K';
    }
    return population.toString();
  }

  /// Get formatted area
  String get formattedArea {
    if (area >= 1000000) {
      return '${(area / 1000000).toStringAsFixed(2)}M km²';
    } else if (area >= 1000) {
      return '${(area / 1000).toStringAsFixed(2)}K km²';
    }
    return '${area.toStringAsFixed(0)} km²';
  }

  /// Get flag emoji from country code
  String get flagEmoji {
    final codePoints = code.toUpperCase().codeUnits.map(
      (code) => code - 0x41 + 0x1F1E6,
    );
    return String.fromCharCodes(codePoints);
  }

  // Aliases for backward compatibility
  String get cca3 => code3;
  String get nativeName => nameArabic;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Currency information
@immutable
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Geographic coordinates
@immutable
class LatLng {
  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Weather information for a country's capital
@immutable
class CountryWeather {
  const CountryWeather({
    required this.countryCode,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
  });

  final String countryCode;
  final double temperature; // Celsius
  final String condition; // e.g., "Sunny", "Cloudy", "Rainy"
  final String icon;
  final int humidity;
  final double windSpeed;
  final DateTime lastUpdated;

  /// Get temperature in Fahrenheit
  double get temperatureFahrenheit => (temperature * 9 / 5) + 32;
}
