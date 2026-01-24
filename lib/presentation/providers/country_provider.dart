import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/repository_providers.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/i_country_repository.dart';

/// Country list state
sealed class CountryListState {
  const CountryListState();

  bool get isLoading => this is CountryListLoading;
  bool get hasData => this is CountryListLoaded;

  List<Country> get countries {
    if (this is CountryListLoaded) {
      return (this as CountryListLoaded).countries;
    }
    return [];
  }
}

class CountryListInitial extends CountryListState {
  const CountryListInitial();
}

class CountryListLoading extends CountryListState {
  const CountryListLoading();
}

class CountryListLoaded extends CountryListState {
  const CountryListLoaded(this.countries);

  @override
  final List<Country> countries;
}

class CountryListError extends CountryListState {
  const CountryListError(this.failure);

  final Failure failure;
}

/// Country list state notifier
class CountryListNotifier extends StateNotifier<AsyncValue<CountryListState>> {
  CountryListNotifier(this._countryRepository)
      : super(const AsyncValue.data(CountryListInitial()));

  final ICountryRepository _countryRepository;
  List<Country> _allCountries = [];

  /// Load all countries
  Future<void> loadCountries({bool forceRefresh = false}) async {
    // Skip if already loaded and not forcing refresh
    if (_allCountries.isNotEmpty && !forceRefresh) {
      state = AsyncValue.data(CountryListLoaded(_allCountries));
      return;
    }

    state = const AsyncValue.loading();

    final result = await _countryRepository.getAllCountries(
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => state = AsyncValue.data(CountryListError(failure)),
      (countries) {
        _allCountries = countries;
        state = AsyncValue.data(CountryListLoaded(countries));
      },
    );
  }

  /// Filter countries by region
  void filterByRegion(String region) {
    if (_allCountries.isEmpty) return;

    final filtered =
        _allCountries.where((c) => c.region == region).toList();
    state = AsyncValue.data(CountryListLoaded(filtered));
  }

  /// Search countries by name
  Future<void> searchCountries(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(CountryListLoaded(_allCountries));
      return;
    }

    // Local search first
    final localFiltered = _allCountries.where((country) {
      return country.name.toLowerCase().contains(query.toLowerCase()) ||
          country.nameArabic.contains(query) ||
          country.code.toLowerCase() == query.toLowerCase();
    }).toList();

    if (localFiltered.isNotEmpty) {
      state = AsyncValue.data(CountryListLoaded(localFiltered));
      return;
    }

    // Fall back to API search
    final result = await _countryRepository.searchCountries(query);
    result.fold(
      (failure) => state = AsyncValue.data(CountryListError(failure)),
      (countries) => state = AsyncValue.data(CountryListLoaded(countries)),
    );
  }

  /// Clear filters and show all countries
  void clearFilters() {
    state = AsyncValue.data(CountryListLoaded(_allCountries));
  }

  /// Clear cache and reload
  Future<void> clearCacheAndReload() async {
    await _countryRepository.clearCache();
    _allCountries = [];
    await loadCountries(forceRefresh: true);
  }
}

/// Country list state provider
final countryListProvider =
    StateNotifierProvider<CountryListNotifier, AsyncValue<CountryListState>>(
        (ref) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  final notifier = CountryListNotifier(countryRepository);

  // Auto-load countries on provider creation
  notifier.loadCountries();

  return notifier;
});

/// All countries provider (convenience)
final allCountriesProvider = Provider<List<Country>>((ref) {
  final countryState = ref.watch(countryListProvider);
  return countryState.valueOrNull?.countries ?? [];
});

/// Countries by region provider
final countriesByRegionProvider =
    FutureProvider.family<List<Country>, String>((ref, region) async {
  final countryRepository = ref.watch(countryRepositoryProvider);

  final result = await countryRepository.getCountriesByRegion(region);
  return result.fold(
    (failure) => [],
    (countries) => countries,
  );
});

/// Country by code provider
final countryByCodeProvider =
    FutureProvider.family<Country?, String>((ref, code) async {
  final countryRepository = ref.watch(countryRepositoryProvider);

  final result = await countryRepository.getCountryByCode(code);
  return result.fold(
    (failure) => null,
    (country) => country,
  );
});

/// Random country provider (for "Country of the Day")
final randomCountryProvider = FutureProvider<Country?>((ref) async {
  final countryRepository = ref.watch(countryRepositoryProvider);

  final result = await countryRepository.getRandomCountry();
  return result.fold(
    (failure) => null,
    (country) => country,
  );
});

/// Country of the day provider (persisted for 24 hours)
final countryOfTheDayProvider = FutureProvider<Country?>((ref) async {
  // This will return a consistent country for the day
  // The repository implementation should handle caching this for 24 hours
  final countryRepository = ref.watch(countryRepositoryProvider);

  final result = await countryRepository.getRandomCountry();
  return result.fold(
    (failure) => null,
    (country) => country,
  );
});

/// Selected country provider (for detail view)
final selectedCountryProvider = StateProvider<Country?>((ref) => null);

/// Search query provider
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered countries provider
final filteredCountriesProvider = Provider<List<Country>>((ref) {
  final allCountries = ref.watch(allCountriesProvider);
  final searchQuery = ref.watch(countrySearchQueryProvider);

  if (searchQuery.isEmpty) {
    return allCountries;
  }

  return allCountries.where((country) {
    return country.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        country.nameArabic.contains(searchQuery) ||
        country.code.toLowerCase() == searchQuery.toLowerCase() ||
        (country.capital?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false);
  }).toList();
});

/// Regions list provider
final regionsProvider = Provider<List<String>>((ref) {
  return [
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
  ];
});

/// Selected region filter provider
final selectedRegionProvider = StateProvider<String?>((ref) => null);

/// Countries filtered by selected region provider
final regionFilteredCountriesProvider = Provider<List<Country>>((ref) {
  final allCountries = ref.watch(filteredCountriesProvider);
  final selectedRegion = ref.watch(selectedRegionProvider);

  if (selectedRegion == null) {
    return allCountries;
  }

  return allCountries.where((c) => c.region == selectedRegion).toList();
});
