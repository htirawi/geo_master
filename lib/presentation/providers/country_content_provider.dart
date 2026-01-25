import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/repository_providers.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/cultural_item.dart';
import '../../domain/entities/phrase.dart';
import '../../domain/entities/place_of_interest.dart';
import '../../domain/repositories/i_country_content_repository.dart';

/// Country content state for tabs
sealed class CountryContentState {
  const CountryContentState();

  bool get isLoading => this is CountryContentLoading;
  bool get hasData => this is CountryContentLoaded;
  bool get hasError => this is CountryContentError;
}

class CountryContentInitial extends CountryContentState {
  const CountryContentInitial();
}

class CountryContentLoading extends CountryContentState {
  const CountryContentLoading();
}

class CountryContentLoaded extends CountryContentState {
  const CountryContentLoaded({
    this.overview,
    this.geography,
    this.places,
    this.foods,
    this.festivals,
    this.famousPeople,
    this.funFacts,
    this.phrases,
    this.travelEssentials,
    this.travelTips,
  });

  final CountryOverview? overview;
  final GeographyInfo? geography;
  final List<PlaceOfInterest>? places;
  final List<FoodItem>? foods;
  final List<FestivalItem>? festivals;
  final List<FamousPerson>? famousPeople;
  final List<FunFact>? funFacts;
  final List<Phrase>? phrases;
  final TravelEssentials? travelEssentials;
  final List<String>? travelTips;
}

class CountryContentError extends CountryContentState {
  const CountryContentError(this.failure);

  final Failure failure;
}

/// Country content notifier
class CountryContentNotifier extends StateNotifier<AsyncValue<CountryContentState>> {
  CountryContentNotifier(this._repository)
      : super(const AsyncValue.data(CountryContentInitial()));

  final ICountryContentRepository _repository;

  String? _currentCountryCode;

  /// Load content for a country
  Future<void> loadContent(String countryCode, String countryName) async {
    if (_currentCountryCode == countryCode &&
        state.valueOrNull is CountryContentLoaded) {
      return;
    }

    _currentCountryCode = countryCode;
    state = const AsyncValue.loading();

    try {
      // Load overview first
      final overviewResult = await _repository.getCountryOverview(countryName);
      final overview = overviewResult.fold((_) => null, (o) => o);

      // Then load other content in parallel
      final results = await Future.wait([
        _repository.getGeographyInfo(countryCode),
        _repository.getPlacesOfInterest(countryCode),
        _repository.getFamousFoods(countryCode),
        _repository.getFestivals(countryCode),
        _repository.getFamousPeople(countryCode),
        _repository.getFunFacts(countryCode),
        _repository.getEssentialPhrases(countryCode),
        _repository.getTravelEssentials(countryCode),
        _repository.getTravelTips(countryCode),
      ]);

      state = AsyncValue.data(CountryContentLoaded(
        overview: overview,
        geography: results[0].fold((_) => null, (g) => g as GeographyInfo),
        places: results[1].fold((_) => <PlaceOfInterest>[], (p) => p as List<PlaceOfInterest>),
        foods: results[2].fold((_) => <FoodItem>[], (f) => f as List<FoodItem>),
        festivals: results[3].fold((_) => <FestivalItem>[], (f) => f as List<FestivalItem>),
        famousPeople: results[4].fold((_) => <FamousPerson>[], (p) => p as List<FamousPerson>),
        funFacts: results[5].fold((_) => <FunFact>[], (f) => f as List<FunFact>),
        phrases: results[6].fold((_) => <Phrase>[], (p) => p as List<Phrase>),
        travelEssentials: results[7].fold((_) => null, (t) => t as TravelEssentials),
        travelTips: results[8].fold((_) => <String>[], (t) => t as List<String>),
      ));
    } catch (e) {
      state = const AsyncValue.data(CountryContentError(
        ServerFailure(message: 'Failed to load content'),
      ));
    }
  }

  /// Clear content (when navigating away)
  void clear() {
    _currentCountryCode = null;
    state = const AsyncValue.data(CountryContentInitial());
  }
}

/// Country content provider
final countryContentProvider = StateNotifierProvider.family<
    CountryContentNotifier, AsyncValue<CountryContentState>, String>((ref, countryCode) {
  final repository = ref.watch(countryContentRepositoryProvider);
  return CountryContentNotifier(repository);
});

/// Overview provider for a country
final countryOverviewProvider = FutureProvider.family<CountryOverview?, (String, String)>(
  (ref, params) async {
    final (countryCode, countryName) = params;
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getCountryOverview(countryName);
    return result.fold((_) => null, (overview) => overview);
  },
);

/// Places of interest provider
final placesOfInterestProvider = FutureProvider.family<List<PlaceOfInterest>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getPlacesOfInterest(countryCode);
    return result.fold((_) => [], (places) => places);
  },
);

/// UNESCO sites provider
final unescoSitesProvider = FutureProvider.family<List<PlaceOfInterest>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getUnescoSites(countryCode);
    return result.fold((_) => [], (sites) => sites);
  },
);

/// Famous foods provider
final famousFoodsProvider = FutureProvider.family<List<FoodItem>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getFamousFoods(countryCode);
    return result.fold((_) => [], (foods) => foods);
  },
);

/// Festivals provider
final festivalsProvider = FutureProvider.family<List<FestivalItem>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getFestivals(countryCode);
    return result.fold((_) => [], (festivals) => festivals);
  },
);

/// Famous people provider
final famousPeopleProvider = FutureProvider.family<List<FamousPerson>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getFamousPeople(countryCode);
    return result.fold((_) => [], (people) => people);
  },
);

/// Fun facts provider
final funFactsProvider = FutureProvider.family<List<FunFact>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getFunFacts(countryCode);
    return result.fold((_) => [], (facts) => facts);
  },
);

/// Essential phrases provider
final essentialPhrasesProvider = FutureProvider.family<List<Phrase>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getEssentialPhrases(countryCode);
    return result.fold((_) => [], (phrases) => phrases);
  },
);

/// Travel essentials provider
final travelEssentialsProvider = FutureProvider.family<TravelEssentials?, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getTravelEssentials(countryCode);
    return result.fold((_) => null, (essentials) => essentials);
  },
);

/// Travel tips provider
final travelTipsProvider = FutureProvider.family<List<String>, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getTravelTips(countryCode);
    return result.fold((_) => [], (tips) => tips);
  },
);

/// Geography info provider
final geographyInfoProvider = FutureProvider.family<GeographyInfo?, String>(
  (ref, countryCode) async {
    final repository = ref.watch(countryContentRepositoryProvider);

    final result = await repository.getGeographyInfo(countryCode);
    return result.fold((_) => null, (info) => info);
  },
);

/// Current tab index for country detail
final countryDetailTabIndexProvider = StateProvider<int>((ref) => 0);

/// Tab names
enum CountryDetailTab {
  overview,
  geography,
  culture,
  travel,
  learn,
}

extension CountryDetailTabX on CountryDetailTab {
  String get displayName {
    switch (this) {
      case CountryDetailTab.overview:
        return 'Overview';
      case CountryDetailTab.geography:
        return 'Geography';
      case CountryDetailTab.culture:
        return 'Culture';
      case CountryDetailTab.travel:
        return 'Travel';
      case CountryDetailTab.learn:
        return 'Learn';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case CountryDetailTab.overview:
        return 'نظرة عامة';
      case CountryDetailTab.geography:
        return 'الجغرافيا';
      case CountryDetailTab.culture:
        return 'الثقافة';
      case CountryDetailTab.travel:
        return 'السفر';
      case CountryDetailTab.learn:
        return 'تعلم';
    }
  }
}
