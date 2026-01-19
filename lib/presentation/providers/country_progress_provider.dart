import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../domain/entities/country_progress.dart';
import '../../domain/repositories/i_world_exploration_repository.dart';

/// Country progress state
sealed class CountryProgressState {
  const CountryProgressState();
}

class CountryProgressInitial extends CountryProgressState {
  const CountryProgressInitial();
}

class CountryProgressLoading extends CountryProgressState {
  const CountryProgressLoading();
}

class CountryProgressLoaded extends CountryProgressState {
  const CountryProgressLoaded(this.progress);

  final CountryProgress progress;
}

class CountryProgressError extends CountryProgressState {
  const CountryProgressError(this.message);

  final String message;
}

/// Country progress notifier
class CountryProgressNotifier extends StateNotifier<AsyncValue<CountryProgressState>> {
  CountryProgressNotifier(this._repository)
      : super(const AsyncValue.data(CountryProgressInitial()));

  final IWorldExplorationRepository _repository;

  /// Load progress for a country
  Future<void> loadProgress(String countryCode) async {
    state = const AsyncValue.loading();

    final result = await _repository.getCountryProgress(countryCode);

    result.fold(
      (failure) => state = AsyncValue.data(CountryProgressError(failure.message)),
      (progress) => state = AsyncValue.data(CountryProgressLoaded(progress)),
    );
  }

  /// Mark country as visited
  Future<void> markVisited(String countryCode) async {
    final result = await _repository.markCountryVisited(countryCode);

    result.fold(
      (_) {}, // Error handling could be added here
      (progress) => state = AsyncValue.data(CountryProgressLoaded(progress)),
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String countryCode) async {
    final result = await _repository.toggleFavorite(countryCode);

    result.fold(
      (_) {},
      (progress) => state = AsyncValue.data(CountryProgressLoaded(progress)),
    );
  }

  /// Add bookmarked fact
  Future<void> addBookmark(String countryCode, String factId) async {
    await _repository.addBookmarkedFact(countryCode, factId);
    await loadProgress(countryCode);
  }

  /// Remove bookmarked fact
  Future<void> removeBookmark(String countryCode, String factId) async {
    await _repository.removeBookmarkedFact(countryCode, factId);
    await loadProgress(countryCode);
  }

  /// Update progress after quiz
  Future<void> updateAfterQuiz({
    required String countryCode,
    required int correctAnswers,
    required int totalAnswers,
    required int xpEarned,
    required bool passed,
  }) async {
    final progressResult = await _repository.getCountryProgress(countryCode);

    final currentProgress = progressResult.fold(
      (_) => CountryProgress(countryCode: countryCode),
      (p) => p,
    );

    final updatedProgress = currentProgress.copyWith(
      quizzesTaken: currentProgress.quizzesTaken + 1,
      quizzesPassed: currentProgress.quizzesPassed + (passed ? 1 : 0),
      correctAnswers: currentProgress.correctAnswers + correctAnswers,
      totalAnswers: currentProgress.totalAnswers + totalAnswers,
      xpEarned: currentProgress.xpEarned + xpEarned,
    );

    await _repository.updateCountryProgress(updatedProgress);
    state = AsyncValue.data(CountryProgressLoaded(updatedProgress));
  }

  /// Complete a learning module
  Future<void> completeModule(String countryCode, String moduleId) async {
    final progressResult = await _repository.getCountryProgress(countryCode);

    final currentProgress = progressResult.fold(
      (_) => CountryProgress(countryCode: countryCode),
      (p) => p,
    );

    if (!currentProgress.completedModules.contains(moduleId)) {
      final updatedProgress = currentProgress.copyWith(
        completedModules: [...currentProgress.completedModules, moduleId],
      );

      await _repository.updateCountryProgress(updatedProgress);
      state = AsyncValue.data(CountryProgressLoaded(updatedProgress));
    }
  }

  /// Update flashcard progress
  Future<void> updateFlashcardProgress({
    required String countryCode,
    required int reviewed,
    required int mastered,
  }) async {
    final progressResult = await _repository.getCountryProgress(countryCode);

    final currentProgress = progressResult.fold(
      (_) => CountryProgress(countryCode: countryCode),
      (p) => p,
    );

    final updatedProgress = currentProgress.copyWith(
      flashcardsReviewed: currentProgress.flashcardsReviewed + reviewed,
      flashcardsMastered: currentProgress.flashcardsMastered + mastered,
    );

    await _repository.updateCountryProgress(updatedProgress);
    state = AsyncValue.data(CountryProgressLoaded(updatedProgress));
  }

  /// Add time spent
  Future<void> addTimeSpent(String countryCode, int seconds) async {
    final progressResult = await _repository.getCountryProgress(countryCode);

    final currentProgress = progressResult.fold(
      (_) => CountryProgress(countryCode: countryCode),
      (p) => p,
    );

    final updatedProgress = currentProgress.copyWith(
      timeSpentSeconds: currentProgress.timeSpentSeconds + seconds,
    );

    await _repository.updateCountryProgress(updatedProgress);
  }
}

/// Country progress provider (per country)
final countryProgressProvider = StateNotifierProvider.family<
    CountryProgressNotifier, AsyncValue<CountryProgressState>, String>(
  (ref, countryCode) {
    final repository = sl<IWorldExplorationRepository>();
    final notifier = CountryProgressNotifier(repository);
    notifier.loadProgress(countryCode);
    return notifier;
  },
);

/// Get progress for a country
final progressForCountryProvider = FutureProvider.family<CountryProgress, String>(
  (ref, countryCode) async {
    final repository = sl<IWorldExplorationRepository>();

    final result = await repository.getCountryProgress(countryCode);
    return result.fold(
      (_) => CountryProgress(countryCode: countryCode),
      (progress) => progress,
    );
  },
);

/// All country progress provider
final allCountryProgressProvider = FutureProvider<Map<String, CountryProgress>>(
  (ref) async {
    final repository = sl<IWorldExplorationRepository>();

    final result = await repository.getAllCountryProgress();
    return result.fold(
      (_) => {},
      (progress) => progress,
    );
  },
);

/// Favorite country codes provider
final favoriteCountryCodesProvider = FutureProvider<List<String>>(
  (ref) async {
    final repository = sl<IWorldExplorationRepository>();

    final result = await repository.getFavoriteCountryCodes();
    return result.fold(
      (_) => [],
      (codes) => codes,
    );
  },
);

/// Is country favorite provider
final isCountryFavoriteProvider = FutureProvider.family<bool, String>(
  (ref, countryCode) async {
    final repository = sl<IWorldExplorationRepository>();

    final result = await repository.getCountryProgress(countryCode);
    return result.fold(
      (_) => false,
      (progress) => progress.isFavorite,
    );
  },
);

/// Explored countries count provider
final exploredCountriesCountProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(allCountryProgressProvider);

  return progressAsync.when(
    data: (progress) => progress.values.where((p) => p.isExplored).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Completed countries count provider
final completedCountriesCountProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(allCountryProgressProvider);

  return progressAsync.when(
    data: (progress) => progress.values.where((p) => p.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Total XP earned from country progress
final totalCountryXpProvider = Provider<int>((ref) {
  final progressAsync = ref.watch(allCountryProgressProvider);

  return progressAsync.when(
    data: (progress) => progress.values.fold(0, (sum, p) => sum + p.xpEarned),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
