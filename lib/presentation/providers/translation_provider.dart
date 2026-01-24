import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/repository_providers.dart';
import '../../core/services/translation_service.dart';

/// Translation service initialization state
final translationServiceInitProvider = FutureProvider<void>((ref) async {
  final translationService = ref.watch(translationServiceProvider);
  await translationService.initialize();
});

/// Get Arabic country name provider
final arabicCountryNameProvider =
    Provider.family<String, ArabicNameParams>((ref, params) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.getCountryName(
    countryCode: params.countryCode,
    englishName: params.englishName,
    apiTranslation: params.apiTranslation,
  );
});

/// Get Arabic capital name provider
final arabicCapitalNameProvider =
    Provider.family<String?, ArabicCapitalParams>((ref, params) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.getCapitalName(
    countryCode: params.countryCode,
    englishCapital: params.englishCapital,
    apiTranslation: params.apiTranslation,
  );
});

/// Get Arabic region name provider
final arabicRegionProvider = Provider.family<String, String>((ref, region) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.getRegion(region);
});

/// Get Arabic subregion name provider
final arabicSubregionProvider =
    Provider.family<String, String>((ref, subregion) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.getSubregion(subregion);
});

/// Get Arabic continent name provider
final arabicContinentProvider =
    Provider.family<String, String>((ref, continent) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.getContinent(continent);
});

/// Check if country has translation
final hasTranslationProvider =
    Provider.family<bool, String>((ref, countryCode) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.hasTranslation(countryCode);
});

/// Translation version info
final translationVersionProvider = Provider<String>((ref) {
  final translationService = ref.watch(translationServiceProvider);
  return translationService.version;
});

/// Refresh translations action
final refreshTranslationsProvider = FutureProvider<void>((ref) async {
  final translationService = ref.watch(translationServiceProvider);
  await translationService.refresh();
});

/// Parameters for Arabic country name lookup
class ArabicNameParams {
  const ArabicNameParams({
    required this.countryCode,
    required this.englishName,
    this.apiTranslation,
  });

  final String countryCode;
  final String englishName;
  final String? apiTranslation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArabicNameParams &&
        other.countryCode == countryCode &&
        other.englishName == englishName &&
        other.apiTranslation == apiTranslation;
  }

  @override
  int get hashCode =>
      countryCode.hashCode ^ englishName.hashCode ^ apiTranslation.hashCode;
}

/// Parameters for Arabic capital name lookup
class ArabicCapitalParams {
  const ArabicCapitalParams({
    required this.countryCode,
    this.englishCapital,
    this.apiTranslation,
  });

  final String countryCode;
  final String? englishCapital;
  final String? apiTranslation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArabicCapitalParams &&
        other.countryCode == countryCode &&
        other.englishCapital == englishCapital &&
        other.apiTranslation == apiTranslation;
  }

  @override
  int get hashCode =>
      countryCode.hashCode ^ englishCapital.hashCode ^ apiTranslation.hashCode;
}
