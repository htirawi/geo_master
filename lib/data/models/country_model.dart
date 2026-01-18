import '../../domain/entities/country.dart';

/// Country data model for API responses
class CountryModel {
  const CountryModel({
    required this.name,
    required this.nativeName,
    required this.cca2,
    required this.cca3,
    required this.capitals,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.languages,
    required this.currencies,
    required this.flagUrl,
    required this.flagEmoji,
    this.coatOfArmsUrl,
    required this.latitude,
    required this.longitude,
    required this.borders,
    required this.timezones,
    required this.translations,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    // Parse name with safe type checking
    final nameData = json['name'] as Map<String, dynamic>? ?? {};
    final name = nameData['common'] as String? ?? '';
    final nativeNames = nameData['nativeName'] as Map<String, dynamic>? ?? {};
    String nativeName = name;
    if (nativeNames.isNotEmpty) {
      final firstNative = nativeNames.values.first;
      if (firstNative is Map<String, dynamic>) {
        nativeName = firstNative['common'] as String? ?? name;
      }
    }

    // Parse capitals
    final capitals = (json['capital'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Parse languages
    final languagesData = json['languages'] as Map<String, dynamic>? ?? {};
    final languages = languagesData.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Parse currencies with safe type checking
    final currenciesData = json['currencies'] as Map<String, dynamic>? ?? {};
    final currencies = <CurrencyModel>[];
    for (final entry in currenciesData.entries) {
      if (entry.value is Map<String, dynamic>) {
        final data = entry.value as Map<String, dynamic>;
        currencies.add(CurrencyModel(
          code: entry.key,
          name: data['name'] as String? ?? '',
          symbol: data['symbol'] as String? ?? '',
        ));
      }
    }

    // Parse flags
    final flagsData = json['flags'] as Map<String, dynamic>? ?? {};
    final flagUrl = flagsData['png'] as String? ?? '';
    final flagEmoji = json['flag'] as String? ?? '';

    // Parse coat of arms
    final coatOfArmsData = json['coatOfArms'] as Map<String, dynamic>? ?? {};
    final coatOfArmsUrl = coatOfArmsData['png'] as String?;

    // Parse coordinates with proper type casting
    final latlng = json['latlng'] as List<dynamic>? ?? <num>[0.0, 0.0];
    final latitude = latlng.isNotEmpty ? (latlng[0] as num).toDouble() : 0.0;
    final longitude = latlng.length > 1 ? (latlng[1] as num).toDouble() : 0.0;

    // Parse borders
    final borders = (json['borders'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Parse timezones
    final timezones = (json['timezones'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Parse translations with safe type checking
    final translationsData = json['translations'] as Map<String, dynamic>? ?? {};
    final translations = <String, TranslationModel>{};
    for (final entry in translationsData.entries) {
      if (entry.value is Map<String, dynamic>) {
        final data = entry.value as Map<String, dynamic>;
        translations[entry.key] = TranslationModel(
          official: data['official'] as String? ?? '',
          common: data['common'] as String? ?? '',
        );
      }
    }

    return CountryModel(
      name: name,
      nativeName: nativeName,
      cca2: json['cca2'] as String? ?? '',
      cca3: json['cca3'] as String? ?? '',
      capitals: capitals,
      region: json['region'] as String? ?? '',
      subregion: json['subregion'] as String? ?? '',
      population: (json['population'] as num?)?.toInt() ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      languages: languages,
      currencies: currencies,
      flagUrl: flagUrl,
      flagEmoji: flagEmoji,
      coatOfArmsUrl: coatOfArmsUrl,
      latitude: latitude,
      longitude: longitude,
      borders: borders,
      timezones: timezones,
      translations: translations,
    );
  }

  final String name;
  final String nativeName;
  final String cca2;
  final String cca3;
  final List<String> capitals;
  final String region;
  final String subregion;
  final int population;
  final double area;
  final Map<String, String> languages;
  final List<CurrencyModel> currencies;
  final String flagUrl;
  final String flagEmoji;
  final String? coatOfArmsUrl;
  final double latitude;
  final double longitude;
  final List<String> borders;
  final List<String> timezones;
  final Map<String, TranslationModel> translations;

  Map<String, dynamic> toJson() {
    return {
      'name': {
        'common': name,
        'nativeName': {
          'native': {'common': nativeName},
        },
      },
      'cca2': cca2,
      'cca3': cca3,
      'capital': capitals,
      'region': region,
      'subregion': subregion,
      'population': population,
      'area': area,
      'languages': languages,
      'currencies': {
        for (final c in currencies)
          c.code: {'name': c.name, 'symbol': c.symbol},
      },
      'flags': {'png': flagUrl},
      'flag': flagEmoji,
      'coatOfArms': {'png': coatOfArmsUrl},
      'latlng': [latitude, longitude],
      'borders': borders,
      'timezones': timezones,
      'translations': {
        for (final entry in translations.entries)
          entry.key: {
            'official': entry.value.official,
            'common': entry.value.common,
          },
      },
    };
  }

  /// Convert to domain entity
  Country toEntity() {
    return Country(
      code: cca2,
      code3: cca3,
      name: name,
      nameArabic: translations['ara']?.common ?? name,
      capital: capitals.isNotEmpty ? capitals.first : null,
      capitalArabic: translations['ara']?.common,
      region: region,
      subregion: subregion,
      population: population,
      area: area,
      languages: languages.values.toList(),
      currencies: currencies
          .map((c) => Currency(
                code: c.code,
                name: c.name,
                symbol: c.symbol,
              ))
          .toList(),
      flagUrl: flagUrl,
      coatOfArmsUrl: coatOfArmsUrl,
      coordinates: LatLng(latitude: latitude, longitude: longitude),
      borders: borders,
      timezones: timezones,
    );
  }
}

/// Currency model
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

/// Translation model
class TranslationModel {
  const TranslationModel({
    required this.official,
    required this.common,
  });

  final String official;
  final String common;
}
