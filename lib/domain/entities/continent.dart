import 'package:flutter/foundation.dart';

/// Continent entity with stats and progress tracking
@immutable
class Continent {
  const Continent({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.imageUrl,
    required this.countryCount,
    required this.totalPopulation,
    required this.totalArea,
    this.countryCodes = const [],
    this.progress = const ContinentProgress(),
    this.description,
    this.descriptionArabic,
  });

  final String id; // e.g., "africa", "europe", "asia"
  final String name;
  final String nameArabic;
  final String imageUrl;
  final int countryCount;
  final int totalPopulation;
  final double totalArea; // in km²
  final List<String> countryCodes;
  final ContinentProgress progress;
  final String? description;
  final String? descriptionArabic;

  /// Get display name based on locale
  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  /// Get display description based on locale
  String? getDisplayDescription({required bool isArabic}) {
    return isArabic ? descriptionArabic : description;
  }

  /// Get formatted population
  String get formattedPopulation {
    if (totalPopulation >= 1000000000) {
      return '${(totalPopulation / 1000000000).toStringAsFixed(2)}B';
    } else if (totalPopulation >= 1000000) {
      return '${(totalPopulation / 1000000).toStringAsFixed(2)}M';
    }
    return totalPopulation.toString();
  }

  /// Get formatted area
  String get formattedArea {
    if (totalArea >= 1000000) {
      return '${(totalArea / 1000000).toStringAsFixed(2)}M km²';
    }
    return '${totalArea.toStringAsFixed(0)} km²';
  }

  /// Get progress percentage (0-100)
  double get progressPercentage => progress.completionPercentage;

  /// Check if all countries in continent are completed
  bool get isCompleted => progress.completionPercentage >= 100;

  Continent copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? imageUrl,
    int? countryCount,
    int? totalPopulation,
    double? totalArea,
    List<String>? countryCodes,
    ContinentProgress? progress,
    String? description,
    String? descriptionArabic,
  }) {
    return Continent(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      imageUrl: imageUrl ?? this.imageUrl,
      countryCount: countryCount ?? this.countryCount,
      totalPopulation: totalPopulation ?? this.totalPopulation,
      totalArea: totalArea ?? this.totalArea,
      countryCodes: countryCodes ?? this.countryCodes,
      progress: progress ?? this.progress,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Continent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Progress tracking for a continent
@immutable
class ContinentProgress {
  const ContinentProgress({
    this.countriesExplored = 0,
    this.countriesCompleted = 0,
    this.totalXpEarned = 0,
    this.quizzesCompleted = 0,
    this.lastVisitedCountryCode,
    this.lastVisitedAt,
  });

  final int countriesExplored;
  final int countriesCompleted;
  final int totalXpEarned;
  final int quizzesCompleted;
  final String? lastVisitedCountryCode;
  final DateTime? lastVisitedAt;

  /// Calculate completion percentage based on explored countries
  double get completionPercentage {
    if (countriesCompleted == 0) return 0;
    return (countriesCompleted / countriesExplored * 100).clamp(0, 100);
  }

  ContinentProgress copyWith({
    int? countriesExplored,
    int? countriesCompleted,
    int? totalXpEarned,
    int? quizzesCompleted,
    String? lastVisitedCountryCode,
    DateTime? lastVisitedAt,
  }) {
    return ContinentProgress(
      countriesExplored: countriesExplored ?? this.countriesExplored,
      countriesCompleted: countriesCompleted ?? this.countriesCompleted,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      lastVisitedCountryCode:
          lastVisitedCountryCode ?? this.lastVisitedCountryCode,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
    );
  }
}

/// Predefined continent IDs
abstract final class ContinentIds {
  static const String africa = 'africa';
  static const String antarctica = 'antarctica';
  static const String asia = 'asia';
  static const String europe = 'europe';
  static const String northAmerica = 'north_america';
  static const String oceania = 'oceania';
  static const String southAmerica = 'south_america';

  static const List<String> all = [
    africa,
    antarctica,
    asia,
    europe,
    northAmerica,
    oceania,
    southAmerica,
  ];
}
