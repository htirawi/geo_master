import '../../domain/entities/continent.dart';

/// Continent data model with JSON serialization
class ContinentModel {
  const ContinentModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.imageUrl,
    required this.countryCount,
    required this.totalPopulation,
    required this.totalArea,
    this.countryCodes = const [],
    this.description,
    this.descriptionArabic,
    this.progress,
  });

  factory ContinentModel.fromJson(Map<String, dynamic> json) {
    return ContinentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      countryCount: (json['countryCount'] as num?)?.toInt() ?? 0,
      totalPopulation: (json['totalPopulation'] as num?)?.toInt() ?? 0,
      totalArea: (json['totalArea'] as num?)?.toDouble() ?? 0.0,
      countryCodes: (json['countryCodes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String?,
      descriptionArabic: json['descriptionArabic'] as String?,
      progress: json['progress'] != null
          ? ContinentProgressModel.fromJson(
              json['progress'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create model from entity
  factory ContinentModel.fromEntity(Continent entity) {
    return ContinentModel(
      id: entity.id,
      name: entity.name,
      nameArabic: entity.nameArabic,
      imageUrl: entity.imageUrl,
      countryCount: entity.countryCount,
      totalPopulation: entity.totalPopulation,
      totalArea: entity.totalArea,
      countryCodes: entity.countryCodes,
      description: entity.description,
      descriptionArabic: entity.descriptionArabic,
      progress: ContinentProgressModel.fromEntity(entity.progress),
    );
  }

  final String id;
  final String name;
  final String nameArabic;
  final String imageUrl;
  final int countryCount;
  final int totalPopulation;
  final double totalArea;
  final List<String> countryCodes;
  final String? description;
  final String? descriptionArabic;
  final ContinentProgressModel? progress;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'imageUrl': imageUrl,
      'countryCount': countryCount,
      'totalPopulation': totalPopulation,
      'totalArea': totalArea,
      'countryCodes': countryCodes,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'progress': progress?.toJson(),
    };
  }

  /// Convert to domain entity
  Continent toEntity() {
    return Continent(
      id: id,
      name: name,
      nameArabic: nameArabic,
      imageUrl: imageUrl,
      countryCount: countryCount,
      totalPopulation: totalPopulation,
      totalArea: totalArea,
      countryCodes: countryCodes,
      description: description,
      descriptionArabic: descriptionArabic,
      progress: progress?.toEntity() ?? const ContinentProgress(),
    );
  }
}

/// Continent progress model
class ContinentProgressModel {
  const ContinentProgressModel({
    this.countriesExplored = 0,
    this.countriesCompleted = 0,
    this.totalXpEarned = 0,
    this.quizzesCompleted = 0,
    this.lastVisitedCountryCode,
    this.lastVisitedAt,
  });

  factory ContinentProgressModel.fromJson(Map<String, dynamic> json) {
    return ContinentProgressModel(
      countriesExplored: (json['countriesExplored'] as num?)?.toInt() ?? 0,
      countriesCompleted: (json['countriesCompleted'] as num?)?.toInt() ?? 0,
      totalXpEarned: (json['totalXpEarned'] as num?)?.toInt() ?? 0,
      quizzesCompleted: (json['quizzesCompleted'] as num?)?.toInt() ?? 0,
      lastVisitedCountryCode: json['lastVisitedCountryCode'] as String?,
      lastVisitedAt: json['lastVisitedAt'] != null
          ? DateTime.tryParse(json['lastVisitedAt'] as String)
          : null,
    );
  }

  factory ContinentProgressModel.fromEntity(ContinentProgress entity) {
    return ContinentProgressModel(
      countriesExplored: entity.countriesExplored,
      countriesCompleted: entity.countriesCompleted,
      totalXpEarned: entity.totalXpEarned,
      quizzesCompleted: entity.quizzesCompleted,
      lastVisitedCountryCode: entity.lastVisitedCountryCode,
      lastVisitedAt: entity.lastVisitedAt,
    );
  }

  final int countriesExplored;
  final int countriesCompleted;
  final int totalXpEarned;
  final int quizzesCompleted;
  final String? lastVisitedCountryCode;
  final DateTime? lastVisitedAt;

  Map<String, dynamic> toJson() {
    return {
      'countriesExplored': countriesExplored,
      'countriesCompleted': countriesCompleted,
      'totalXpEarned': totalXpEarned,
      'quizzesCompleted': quizzesCompleted,
      'lastVisitedCountryCode': lastVisitedCountryCode,
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
    };
  }

  ContinentProgress toEntity() {
    return ContinentProgress(
      countriesExplored: countriesExplored,
      countriesCompleted: countriesCompleted,
      totalXpEarned: totalXpEarned,
      quizzesCompleted: quizzesCompleted,
      lastVisitedCountryCode: lastVisitedCountryCode,
      lastVisitedAt: lastVisitedAt,
    );
  }
}
