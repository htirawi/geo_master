import 'package:flutter/foundation.dart';

import 'country.dart';

/// Place of interest / tourist attraction entity
@immutable
class PlaceOfInterest {
  const PlaceOfInterest({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.countryCode,
    required this.type,
    this.description,
    this.descriptionArabic,
    this.imageUrl,
    this.images = const [],
    this.coordinates,
    this.address,
    this.website,
    this.rating,
    this.reviewCount,
    this.isUnescoSite = false,
    this.unescoYear,
    this.openingHours,
    this.entryFee,
    this.virtualTourUrl,
    this.videoUrl,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String nameArabic;
  final String countryCode;
  final PlaceType type;
  final String? description;
  final String? descriptionArabic;
  final String? imageUrl;
  final List<String> images;
  final LatLng? coordinates;
  final String? address;
  final String? website;
  final double? rating; // 0-5 scale
  final int? reviewCount;
  final bool isUnescoSite;
  final int? unescoYear;
  final String? openingHours;
  final String? entryFee;
  final String? virtualTourUrl;
  final String? videoUrl;
  final List<String> tags;

  /// Get display name based on locale
  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  /// Get display description based on locale
  String? getDisplayDescription({required bool isArabic}) {
    return isArabic ? descriptionArabic : description;
  }

  /// Check if place has virtual tour
  bool get hasVirtualTour => virtualTourUrl != null;

  /// Check if place has video
  bool get hasVideo => videoUrl != null;

  /// Get formatted rating string
  String get formattedRating {
    if (rating == null) return 'N/A';
    return rating!.toStringAsFixed(1);
  }

  PlaceOfInterest copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? countryCode,
    PlaceType? type,
    String? description,
    String? descriptionArabic,
    String? imageUrl,
    List<String>? images,
    LatLng? coordinates,
    String? address,
    String? website,
    double? rating,
    int? reviewCount,
    bool? isUnescoSite,
    int? unescoYear,
    String? openingHours,
    String? entryFee,
    String? virtualTourUrl,
    String? videoUrl,
    List<String>? tags,
  }) {
    return PlaceOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      countryCode: countryCode ?? this.countryCode,
      type: type ?? this.type,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isUnescoSite: isUnescoSite ?? this.isUnescoSite,
      unescoYear: unescoYear ?? this.unescoYear,
      openingHours: openingHours ?? this.openingHours,
      entryFee: entryFee ?? this.entryFee,
      virtualTourUrl: virtualTourUrl ?? this.virtualTourUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceOfInterest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Type of place/attraction
enum PlaceType {
  landmark,
  museum,
  naturalWonder,
  historicalSite,
  religiousSite,
  park,
  beach,
  mountain,
  lake,
  waterfall,
  castle,
  palace,
  temple,
  monument,
  bridge,
  tower,
  market,
  neighborhood,
  other;

  String get displayName {
    switch (this) {
      case PlaceType.landmark:
        return 'Landmark';
      case PlaceType.museum:
        return 'Museum';
      case PlaceType.naturalWonder:
        return 'Natural Wonder';
      case PlaceType.historicalSite:
        return 'Historical Site';
      case PlaceType.religiousSite:
        return 'Religious Site';
      case PlaceType.park:
        return 'Park';
      case PlaceType.beach:
        return 'Beach';
      case PlaceType.mountain:
        return 'Mountain';
      case PlaceType.lake:
        return 'Lake';
      case PlaceType.waterfall:
        return 'Waterfall';
      case PlaceType.castle:
        return 'Castle';
      case PlaceType.palace:
        return 'Palace';
      case PlaceType.temple:
        return 'Temple';
      case PlaceType.monument:
        return 'Monument';
      case PlaceType.bridge:
        return 'Bridge';
      case PlaceType.tower:
        return 'Tower';
      case PlaceType.market:
        return 'Market';
      case PlaceType.neighborhood:
        return 'Neighborhood';
      case PlaceType.other:
        return 'Other';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case PlaceType.landmark:
        return 'معلم';
      case PlaceType.museum:
        return 'متحف';
      case PlaceType.naturalWonder:
        return 'أعجوبة طبيعية';
      case PlaceType.historicalSite:
        return 'موقع تاريخي';
      case PlaceType.religiousSite:
        return 'موقع ديني';
      case PlaceType.park:
        return 'حديقة';
      case PlaceType.beach:
        return 'شاطئ';
      case PlaceType.mountain:
        return 'جبل';
      case PlaceType.lake:
        return 'بحيرة';
      case PlaceType.waterfall:
        return 'شلال';
      case PlaceType.castle:
        return 'قلعة';
      case PlaceType.palace:
        return 'قصر';
      case PlaceType.temple:
        return 'معبد';
      case PlaceType.monument:
        return 'نصب تذكاري';
      case PlaceType.bridge:
        return 'جسر';
      case PlaceType.tower:
        return 'برج';
      case PlaceType.market:
        return 'سوق';
      case PlaceType.neighborhood:
        return 'حي';
      case PlaceType.other:
        return 'آخر';
    }
  }

  /// Get icon name for this place type
  String get iconName {
    switch (this) {
      case PlaceType.landmark:
        return 'location_city';
      case PlaceType.museum:
        return 'museum';
      case PlaceType.naturalWonder:
        return 'landscape';
      case PlaceType.historicalSite:
        return 'account_balance';
      case PlaceType.religiousSite:
        return 'church';
      case PlaceType.park:
        return 'park';
      case PlaceType.beach:
        return 'beach_access';
      case PlaceType.mountain:
        return 'terrain';
      case PlaceType.lake:
        return 'water';
      case PlaceType.waterfall:
        return 'waterfall_chart';
      case PlaceType.castle:
        return 'castle';
      case PlaceType.palace:
        return 'villa';
      case PlaceType.temple:
        return 'temple_hindu';
      case PlaceType.monument:
        return 'monument';
      case PlaceType.bridge:
        return 'bridge';
      case PlaceType.tower:
        return 'cell_tower';
      case PlaceType.market:
        return 'storefront';
      case PlaceType.neighborhood:
        return 'holiday_village';
      case PlaceType.other:
        return 'place';
    }
  }
}
