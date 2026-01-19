import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/country_progress.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';

/// World map state
sealed class WorldMapState {
  const WorldMapState();

  bool get isLoading => this is WorldMapLoading;
  bool get hasData => this is WorldMapLoaded;
}

class WorldMapInitial extends WorldMapState {
  const WorldMapInitial();
}

class WorldMapLoading extends WorldMapState {
  const WorldMapLoading();
}

class WorldMapLoaded extends WorldMapState {
  const WorldMapLoaded({
    required this.markers,
    this.selectedContinent,
    this.selectedCountry,
  });

  final List<CountryMapMarker> markers;
  final String? selectedContinent;
  final Country? selectedCountry;
}

class WorldMapError extends WorldMapState {
  const WorldMapError(this.failure);

  final Failure failure;
}

/// World map state notifier
class WorldMapNotifier extends StateNotifier<AsyncValue<WorldMapState>> {
  WorldMapNotifier(this._repository)
      : super(const AsyncValue.data(WorldMapInitial()));

  final IWorldExplorationRepository _repository;

  List<CountryMapMarker> _allMarkers = [];
  String? _continentFilter;
  ProgressLevel? _progressFilter;
  bool _favoritesOnly = false;

  /// Load map markers
  Future<void> loadMarkers({bool forceRefresh = false}) async {
    if (_allMarkers.isNotEmpty && !forceRefresh) {
      state = AsyncValue.data(WorldMapLoaded(
        markers: _getFilteredMarkers(),
        selectedContinent: _continentFilter,
      ));
      return;
    }

    state = const AsyncValue.loading();

    final result = await _repository.getCountryMarkers();

    result.fold(
      (failure) => state = AsyncValue.data(WorldMapError(failure)),
      (markers) {
        _allMarkers = markers;
        state = AsyncValue.data(WorldMapLoaded(
          markers: _getFilteredMarkers(),
          selectedContinent: _continentFilter,
        ));
      },
    );
  }

  /// Get filtered markers based on current filters
  List<CountryMapMarker> _getFilteredMarkers() {
    var markers = _allMarkers;

    if (_favoritesOnly) {
      markers = markers.where((m) => m.isFavorite).toList();
    }

    if (_progressFilter != null) {
      markers = markers.where((m) => m.progressLevel == _progressFilter).toList();
    }

    return markers;
  }

  /// Filter by continent
  void filterByContinent(String? continentId) {
    _continentFilter = continentId;
    loadMarkers();
  }

  /// Filter by progress level
  void filterByProgress(ProgressLevel? level) {
    _progressFilter = level;
    if (_allMarkers.isNotEmpty) {
      state = AsyncValue.data(WorldMapLoaded(
        markers: _getFilteredMarkers(),
        selectedContinent: _continentFilter,
      ));
    }
  }

  /// Toggle favorites filter
  void toggleFavoritesFilter() {
    _favoritesOnly = !_favoritesOnly;
    if (_allMarkers.isNotEmpty) {
      state = AsyncValue.data(WorldMapLoaded(
        markers: _getFilteredMarkers(),
        selectedContinent: _continentFilter,
      ));
    }
  }

  /// Clear all filters
  void clearFilters() {
    _continentFilter = null;
    _progressFilter = null;
    _favoritesOnly = false;
    if (_allMarkers.isNotEmpty) {
      state = AsyncValue.data(WorldMapLoaded(
        markers: _allMarkers,
        selectedContinent: null,
      ));
    }
  }

  /// Select a country on the map
  void selectCountry(Country? country) {
    final currentState = state.valueOrNull;
    if (currentState is WorldMapLoaded) {
      state = AsyncValue.data(WorldMapLoaded(
        markers: currentState.markers,
        selectedContinent: currentState.selectedContinent,
        selectedCountry: country,
      ));
    }
  }

  /// Alias for loadMarkers (used by world map screen)
  Future<void> loadMap({bool forceRefresh = false}) async {
    return loadMarkers(forceRefresh: forceRefresh);
  }

  /// Get country by code
  Future<Country?> getCountryByCode(String countryCode) async {
    final result = await _repository.getCountryByCode(countryCode);
    return result.fold(
      (failure) => null,
      (country) => country,
    );
  }
}

/// World map provider
final worldMapProvider =
    StateNotifierProvider<WorldMapNotifier, AsyncValue<WorldMapState>>((ref) {
  final repository = sl<IWorldExplorationRepository>();
  final notifier = WorldMapNotifier(repository);
  notifier.loadMarkers();
  return notifier;
});

/// Map markers provider (convenience)
final mapMarkersProvider = Provider<List<CountryMapMarker>>((ref) {
  final mapState = ref.watch(worldMapProvider);
  final state = mapState.valueOrNull;
  if (state is WorldMapLoaded) {
    return state.markers;
  }
  return [];
});

/// Selected continent provider
final selectedContinentProvider = StateProvider<String?>((ref) => null);

/// Alias for selectedContinentProvider (used by world map screen)
final selectedContinentFilterProvider = selectedContinentProvider;

/// Map filter state
class MapFilterState {
  const MapFilterState({
    this.continentFilter,
    this.progressFilter,
    this.favoritesOnly = false,
  });

  final String? continentFilter;
  final ProgressLevel? progressFilter;
  final bool favoritesOnly;

  MapFilterState copyWith({
    String? continentFilter,
    ProgressLevel? progressFilter,
    bool? favoritesOnly,
  }) {
    return MapFilterState(
      continentFilter: continentFilter ?? this.continentFilter,
      progressFilter: progressFilter ?? this.progressFilter,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  bool get hasActiveFilters =>
      continentFilter != null || progressFilter != null || favoritesOnly;
}

/// Map filter provider
final mapFilterProvider = StateProvider<MapFilterState>((ref) {
  return const MapFilterState();
});

/// Random country provider for "spin the globe"
final spinGlobeCountryProvider = FutureProvider<Country?>((ref) async {
  final repository = sl<IWorldExplorationRepository>();

  final result = await repository.getRandomCountry();
  return result.fold(
    (failure) => null,
    (country) => country,
  );
});

/// Map view mode (normal, 3D terrain)
enum MapViewMode { normal, terrain, satellite, hybrid }

final mapViewModeProvider = StateProvider<MapViewMode>((ref) => MapViewMode.normal);

/// Map progress filter enum
enum MapProgressFilter {
  all,
  completed,
  inProgress,
  notStarted,
}

/// Progress filter provider
final progressFilterProvider = StateProvider<MapProgressFilter>((ref) => MapProgressFilter.all);

/// Show favorites only provider
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

/// Map stats data class
class MapStats {
  const MapStats({
    this.totalCountries = 0,
    this.explored = 0,
    this.favorites = 0,
  });

  final int totalCountries;
  final int explored;
  final int favorites;
}

/// Map stats provider
final mapStatsProvider = Provider<MapStats>((ref) {
  final mapState = ref.watch(worldMapProvider);
  final state = mapState.valueOrNull;

  if (state is WorldMapLoaded) {
    final markers = state.markers;
    final explored = markers.where((m) => m.progressLevel != ProgressLevel.notStarted).length;
    final favorites = markers.where((m) => m.isFavorite).length;

    return MapStats(
      totalCountries: markers.length,
      explored: explored,
      favorites: favorites,
    );
  }

  return const MapStats();
});

/// Is 3D terrain enabled (premium feature)
final is3DTerrainEnabledProvider = StateProvider<bool>((ref) => false);

/// Map search query provider
final mapSearchQueryProvider = StateProvider<String>((ref) => '');

/// Map search results provider
/// Note: This is a synchronous placeholder. Use asyncMapSearchResultsProvider for actual search.
final mapSearchResultsProvider = Provider<List<Country>>((ref) {
  final query = ref.watch(mapSearchQueryProvider);
  if (query.isEmpty) return [];
  // Use asyncMapSearchResultsProvider for actual async search
  return [];
});

/// Async map search results provider
final asyncMapSearchResultsProvider =
    FutureProvider.family<List<Country>, String>((ref, query) async {
  if (query.isEmpty || query.length < 2) return [];

  final repository = sl<IWorldExplorationRepository>();
  final result = await repository.searchCountries(query);
  return result.fold(
    (failure) => [],
    (countries) => countries,
  );
});

/// Random country provider for "spin the globe" feature
final randomCountryProvider = FutureProvider.autoDispose<Country?>((ref) async {
  final repository = sl<IWorldExplorationRepository>();
  final result = await repository.getRandomCountry();
  return result.fold(
    (failure) => null,
    (country) => country,
  );
});
