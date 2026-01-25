import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../domain/entities/user_stats.dart';

/// Provider for the stats repository
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return LocalStatsRepository();
});

/// Provider for user's detailed stats
final userStatsProvider =
    FutureProvider.family<UserStats, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.getUserStats(userId);
});

/// Stream provider for user stats updates
final userStatsStreamProvider =
    StreamProvider.family<UserStats, String>((ref, userId) {
  final repository = ref.read(statsRepositoryProvider);
  return repository.watchUserStats(userId);
});

/// Provider for stats summary
final statsSummaryProvider =
    FutureProvider.family<StatsSummary, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.getStatsSummary(userId);
});

/// Provider for activity history
final activityHistoryProvider =
    FutureProvider.family<List<DailyActivity>, ActivityHistoryKey>(
        (ref, key) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.getActivityHistory(
    key.userId,
    startDate: key.startDate,
    endDate: key.endDate,
    limit: key.limit,
  );
});

/// Provider for weak areas
final weakAreasProvider =
    FutureProvider.family<List<WeakArea>, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.analyzeWeakAreas(userId);
});

/// Provider for strong areas
final strongAreasProvider =
    FutureProvider.family<List<StrongArea>, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.analyzeStrongAreas(userId);
});

/// Key for activity history provider
class ActivityHistoryKey {
  const ActivityHistoryKey({
    required this.userId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityHistoryKey &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      limit.hashCode;
}

/// State notifier for recording stats
class StatsRecorderNotifier extends StateNotifier<AsyncValue<void>> {
  StatsRecorderNotifier(this._repository) : super(const AsyncValue.data(null));

  final StatsRepository _repository;

  Future<void> recordQuizCompletion(
    String userId, {
    required int xpEarned,
    required int questionsAnswered,
    required int correctAnswers,
    required Duration studyTime,
    required String quizType,
    String? continent,
    required bool isPerfectScore,
  }) async {
    try {
      await _repository.recordQuizCompletion(
        userId,
        xpEarned: xpEarned,
        questionsAnswered: questionsAnswered,
        correctAnswers: correctAnswers,
        studyTime: studyTime,
        quizType: quizType,
        continent: continent,
        isPerfectScore: isPerfectScore,
      );

      await _repository.updateStreak(userId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLearnedCountry(String userId, String continent) async {
    try {
      await _repository.addLearnedCountry(userId, continent);
    } catch (_) {
      // Silently ignore
    }
  }
}

/// Provider for stats recorder
final statsRecorderProvider =
    StateNotifierProvider<StatsRecorderNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return StatsRecorderNotifier(repository);
});

/// Provider for current streak
final currentStreakProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final stats = await ref.read(userStatsProvider(userId).future);
  return stats.currentStreak;
});

/// Provider for accuracy
final overallAccuracyProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final stats = await ref.read(userStatsProvider(userId).future);
  return stats.accuracy;
});

/// Provider for total study time
final totalStudyTimeProvider =
    FutureProvider.family<Duration, String>((ref, userId) async {
  final stats = await ref.read(userStatsProvider(userId).future);
  return stats.totalStudyTime;
});

/// Provider for countries learned per continent
final countriesPerContinentProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final stats = await ref.read(userStatsProvider(userId).future);
  return stats.countriesPerContinent;
});

/// Provider for accuracy per continent
final accuracyPerContinentProvider =
    FutureProvider.family<Map<String, double>, String>((ref, userId) async {
  final stats = await ref.read(userStatsProvider(userId).future);
  return stats.accuracyPerContinent;
});

/// Provider for last 7 days activity
final weeklyActivityProvider =
    FutureProvider.family<List<DailyActivity>, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  return repository.getActivityHistory(
    userId,
    startDate: weekAgo,
    endDate: now,
  );
});

/// Provider for last 30 days activity
final monthlyActivityProvider =
    FutureProvider.family<List<DailyActivity>, String>((ref, userId) async {
  final repository = ref.read(statsRepositoryProvider);
  final now = DateTime.now();
  final monthAgo = now.subtract(const Duration(days: 30));
  return repository.getActivityHistory(
    userId,
    startDate: monthAgo,
    endDate: now,
  );
});
