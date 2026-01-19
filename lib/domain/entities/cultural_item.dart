import 'package:flutter/foundation.dart';

/// Cultural item entity for foods, arts, festivals, and famous people
@immutable
class CulturalItem {
  const CulturalItem({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.countryCode,
    required this.type,
    this.description,
    this.descriptionArabic,
    this.imageUrl,
    this.images = const [],
    this.videoUrl,
    this.wikipediaUrl,
    this.tags = const [],
    this.metadata = const {},
  });

  final String id;
  final String name;
  final String nameArabic;
  final String countryCode;
  final CulturalItemType type;
  final String? description;
  final String? descriptionArabic;
  final String? imageUrl;
  final List<String> images;
  final String? videoUrl;
  final String? wikipediaUrl;
  final List<String> tags;
  final Map<String, dynamic> metadata; // Type-specific metadata

  /// Get display name based on locale
  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  /// Get display description based on locale
  String? getDisplayDescription({required bool isArabic}) {
    return isArabic ? descriptionArabic : description;
  }

  /// Check if has video
  bool get hasVideo => videoUrl != null;

  /// Check if has Wikipedia article
  bool get hasWikipedia => wikipediaUrl != null;

  CulturalItem copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? countryCode,
    CulturalItemType? type,
    String? description,
    String? descriptionArabic,
    String? imageUrl,
    List<String>? images,
    String? videoUrl,
    String? wikipediaUrl,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return CulturalItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      countryCode: countryCode ?? this.countryCode,
      type: type ?? this.type,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      wikipediaUrl: wikipediaUrl ?? this.wikipediaUrl,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CulturalItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Type of cultural item
enum CulturalItemType {
  food,
  drink,
  art,
  music,
  dance,
  festival,
  tradition,
  craft,
  clothing,
  architecture,
  sport,
  famousPerson;

  String get displayName {
    switch (this) {
      case CulturalItemType.food:
        return 'Food';
      case CulturalItemType.drink:
        return 'Drink';
      case CulturalItemType.art:
        return 'Art';
      case CulturalItemType.music:
        return 'Music';
      case CulturalItemType.dance:
        return 'Dance';
      case CulturalItemType.festival:
        return 'Festival';
      case CulturalItemType.tradition:
        return 'Tradition';
      case CulturalItemType.craft:
        return 'Craft';
      case CulturalItemType.clothing:
        return 'Clothing';
      case CulturalItemType.architecture:
        return 'Architecture';
      case CulturalItemType.sport:
        return 'Sport';
      case CulturalItemType.famousPerson:
        return 'Famous Person';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case CulturalItemType.food:
        return 'طعام';
      case CulturalItemType.drink:
        return 'شراب';
      case CulturalItemType.art:
        return 'فن';
      case CulturalItemType.music:
        return 'موسيقى';
      case CulturalItemType.dance:
        return 'رقص';
      case CulturalItemType.festival:
        return 'مهرجان';
      case CulturalItemType.tradition:
        return 'تقاليد';
      case CulturalItemType.craft:
        return 'حرفة';
      case CulturalItemType.clothing:
        return 'ملابس';
      case CulturalItemType.architecture:
        return 'عمارة';
      case CulturalItemType.sport:
        return 'رياضة';
      case CulturalItemType.famousPerson:
        return 'شخصية مشهورة';
    }
  }

  /// Get icon name for this type
  String get iconName {
    switch (this) {
      case CulturalItemType.food:
        return 'restaurant_menu';
      case CulturalItemType.drink:
        return 'local_cafe';
      case CulturalItemType.art:
        return 'palette';
      case CulturalItemType.music:
        return 'music_note';
      case CulturalItemType.dance:
        return 'sports_martial_arts';
      case CulturalItemType.festival:
        return 'celebration';
      case CulturalItemType.tradition:
        return 'auto_stories';
      case CulturalItemType.craft:
        return 'handyman';
      case CulturalItemType.clothing:
        return 'checkroom';
      case CulturalItemType.architecture:
        return 'architecture';
      case CulturalItemType.sport:
        return 'sports_soccer';
      case CulturalItemType.famousPerson:
        return 'person';
    }
  }
}

/// Food-specific cultural item
@immutable
class FoodItem extends CulturalItem {
  const FoodItem({
    required super.id,
    required super.name,
    required super.nameArabic,
    required super.countryCode,
    super.description,
    super.descriptionArabic,
    super.imageUrl,
    super.images,
    super.videoUrl,
    super.wikipediaUrl,
    super.tags,
    this.cuisine,
    this.ingredients = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isHalal,
    this.spiceLevel,
    this.servingSize,
    this.preparationTime,
  }) : super(type: CulturalItemType.food);

  final String? cuisine; // e.g., "Mediterranean", "Asian"
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isVegan;
  final bool? isHalal;
  final int? spiceLevel; // 0-5
  final String? servingSize;
  final String? preparationTime;

  /// Get spice level emoji
  String get spiceLevelEmoji {
    if (spiceLevel == null) return '';
    switch (spiceLevel!) {
      case 0:
        return 'No spice';
      case 1:
        return 'Mild';
      case 2:
        return 'Medium';
      case 3:
        return 'Spicy';
      case 4:
        return 'Very Spicy';
      case 5:
        return 'Extremely Spicy';
      default:
        return '';
    }
  }
}

/// Festival-specific cultural item
@immutable
class FestivalItem extends CulturalItem {
  const FestivalItem({
    required super.id,
    required super.name,
    required super.nameArabic,
    required super.countryCode,
    super.description,
    super.descriptionArabic,
    super.imageUrl,
    super.images,
    super.videoUrl,
    super.wikipediaUrl,
    super.tags,
    this.month,
    this.dateRange,
    this.isNationalHoliday = false,
    this.isReligious = false,
    this.religion,
    this.activities = const [],
  }) : super(type: CulturalItemType.festival);

  final int? month; // 1-12
  final String? dateRange; // e.g., "March 21-22"
  final bool isNationalHoliday;
  final bool isReligious;
  final String? religion;
  final List<String> activities;

  /// Get month name
  String? get monthName {
    if (month == null) return null;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month! - 1];
  }

  /// Get Arabic month name
  String? get monthNameArabic {
    if (month == null) return null;
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month! - 1];
  }
}

/// Famous person cultural item
@immutable
class FamousPerson extends CulturalItem {
  const FamousPerson({
    required super.id,
    required super.name,
    required super.nameArabic,
    required super.countryCode,
    super.description,
    super.descriptionArabic,
    super.imageUrl,
    super.images,
    super.videoUrl,
    super.wikipediaUrl,
    super.tags,
    this.profession,
    this.professionArabic,
    this.birthYear,
    this.deathYear,
    this.achievements = const [],
    this.isHistorical = false,
  }) : super(type: CulturalItemType.famousPerson);

  final String? profession;
  final String? professionArabic;
  final int? birthYear;
  final int? deathYear;
  final List<String> achievements;
  final bool isHistorical;

  /// Get profession based on locale
  String? getProfession({required bool isArabic}) {
    return isArabic ? professionArabic : profession;
  }

  /// Get life span string
  String get lifeSpan {
    if (birthYear == null) return '';
    if (deathYear != null) {
      return '$birthYear - $deathYear';
    }
    return 'Born $birthYear';
  }
}

/// Fun fact for countries
@immutable
class FunFact {
  const FunFact({
    required this.id,
    required this.countryCode,
    required this.fact,
    required this.factArabic,
    this.category,
    this.source,
    this.imageUrl,
    this.isVerified = true,
  });

  final String id;
  final String countryCode;
  final String fact;
  final String factArabic;
  final String? category;
  final String? source;
  final String? imageUrl;
  final bool isVerified;

  /// Get fact based on locale
  String getFact({required bool isArabic}) {
    return isArabic ? factArabic : fact;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunFact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
