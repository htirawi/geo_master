import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/continent.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';

/// Continent list state
sealed class ContinentListState {
  const ContinentListState();

  bool get isLoading => this is ContinentListLoading;
  bool get hasData => this is ContinentListLoaded;

  List<Continent> get continents {
    if (this is ContinentListLoaded) {
      return (this as ContinentListLoaded).continents;
    }
    return [];
  }
}

class ContinentListInitial extends ContinentListState {
  const ContinentListInitial();
}

class ContinentListLoading extends ContinentListState {
  const ContinentListLoading();
}

class ContinentListLoaded extends ContinentListState {
  const ContinentListLoaded(this.continents);

  @override
  final List<Continent> continents;
}

class ContinentListError extends ContinentListState {
  const ContinentListError(this.failure);

  final Failure failure;
}

/// Continent list state notifier
class ContinentListNotifier extends StateNotifier<AsyncValue<ContinentListState>> {
  ContinentListNotifier(this._repository)
      : super(const AsyncValue.data(ContinentListInitial()));

  final IWorldExplorationRepository _repository;

  List<Continent> _allContinents = [];

  /// Load all continents
  Future<void> loadContinents({bool forceRefresh = false}) async {
    if (_allContinents.isNotEmpty && !forceRefresh) {
      state = AsyncValue.data(ContinentListLoaded(_allContinents));
      return;
    }

    state = const AsyncValue.loading();

    final result = await _repository.getAllContinents();

    result.fold(
      (failure) => state = AsyncValue.data(ContinentListError(failure)),
      (continents) {
        _allContinents = continents;
        // Sort by country count (descending)
        _allContinents.sort((a, b) => b.countryCount.compareTo(a.countryCount));
        state = AsyncValue.data(ContinentListLoaded(_allContinents));
      },
    );
  }

  /// Refresh continents data
  Future<void> refresh() async {
    await loadContinents(forceRefresh: true);
  }
}

/// Continent list provider
final continentListProvider =
    StateNotifierProvider<ContinentListNotifier, AsyncValue<ContinentListState>>((ref) {
  final repository = sl<IWorldExplorationRepository>();
  final notifier = ContinentListNotifier(repository);
  notifier.loadContinents();
  return notifier;
});

/// All continents provider (convenience)
final allContinentsProvider = Provider<List<Continent>>((ref) {
  final continentState = ref.watch(continentListProvider);
  return continentState.valueOrNull?.continents ?? [];
});

/// Continent by ID provider
final continentByIdProvider =
    FutureProvider.family<Continent?, String>((ref, id) async {
  final repository = sl<IWorldExplorationRepository>();

  final result = await repository.getContinentById(id);
  return result.fold(
    (failure) => null,
    (continent) => continent,
  );
});

/// Countries by continent provider
final countriesByContinentProvider =
    FutureProvider.family<List<Country>, String>((ref, continentId) async {
  final repository = sl<IWorldExplorationRepository>();

  final result = await repository.getCountriesByContinent(continentId);
  return result.fold(
    (failure) => [],
    (countries) => countries,
  );
});

/// Selected continent for detail view
final selectedContinentDetailProvider = StateProvider<Continent?>((ref) => null);

/// Continent progress stats
class ContinentStats {
  const ContinentStats({
    required this.totalCountries,
    required this.exploredCountries,
    required this.completedCountries,
    required this.totalXp,
    this.favoriteCountries = 0,
  });

  final int totalCountries;
  final int exploredCountries;
  final int completedCountries;
  final int totalXp;
  final int favoriteCountries;

  double get explorationProgress {
    if (totalCountries == 0) return 0;
    return exploredCountries / totalCountries * 100;
  }

  double get completionProgress {
    if (totalCountries == 0) return 0;
    return completedCountries / totalCountries * 100;
  }
}

/// Continent stats provider
final continentStatsProvider =
    FutureProvider.family<ContinentStats, String>((ref, continentId) async {
  final repository = sl<IWorldExplorationRepository>();

  final continentResult = await repository.getContinentById(continentId);
  final progressResult = await repository.getContinentProgress(continentId);

  final continent = continentResult.fold((_) => null, (c) => c);
  final progress = progressResult.fold((_) => const ContinentProgress(), (p) => p);

  return ContinentStats(
    totalCountries: continent?.countryCount ?? 0,
    exploredCountries: progress.countriesExplored,
    completedCountries: progress.countriesCompleted,
    totalXp: progress.totalXpEarned,
  );
});

/// View mode for continent explorer
enum ContinentViewMode { grid, list }

final continentViewModeProvider = StateProvider<ContinentViewMode>((ref) {
  return ContinentViewMode.grid;
});

/// Sort mode for continent list
enum ContinentSortMode { byCountries, byProgress, alphabetical }

final continentSortModeProvider = StateProvider<ContinentSortMode>((ref) {
  return ContinentSortMode.byCountries;
});

/// Sorted continents provider
final sortedContinentsProvider = Provider<List<Continent>>((ref) {
  final continents = ref.watch(allContinentsProvider);
  final sortMode = ref.watch(continentSortModeProvider);

  final sorted = List<Continent>.from(continents);

  switch (sortMode) {
    case ContinentSortMode.byCountries:
      sorted.sort((a, b) => b.countryCount.compareTo(a.countryCount));
    case ContinentSortMode.byProgress:
      sorted.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    case ContinentSortMode.alphabetical:
      sorted.sort((a, b) => a.name.compareTo(b.name));
  }

  return sorted;
});
