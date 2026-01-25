import '../../domain/entities/user_stats.dart';

/// Repository interface for user statistics
abstract class StatsRepository {
  /// Get user's detailed stats
  Future<UserStats> getUserStats(String userId);

  /// Get stats summary
  Future<StatsSummary> getStatsSummary(String userId);

  /// Get activity history for date range
  Future<List<DailyActivity>> getActivityHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Update stats after quiz completion
  Future<void> recordQuizCompletion(
    String userId, {
    required int xpEarned,
    required int questionsAnswered,
    required int correctAnswers,
    required Duration studyTime,
    required String quizType,
    required String? continent,
    required bool isPerfectScore,
  });

  /// Update streak
  Future<void> updateStreak(String userId);

  /// Add country to learned countries
  Future<void> addLearnedCountry(String userId, String continent);

  /// Get weak areas analysis
  Future<List<WeakArea>> analyzeWeakAreas(String userId);

  /// Get strong areas
  Future<List<StrongArea>> analyzeStrongAreas(String userId);

  /// Watch user stats in real-time
  Stream<UserStats> watchUserStats(String userId);

  /// Reset stats (for testing)
  Future<void> resetStats(String userId);
}

/// Local implementation of stats repository
class LocalStatsRepository implements StatsRepository {
  LocalStatsRepository();

  // In-memory storage
  final Map<String, UserStats> _statsCache = {};
  final Map<String, List<DailyActivity>> _activityCache = {};

  @override
  Future<UserStats> getUserStats(String userId) async {
    if (_statsCache.containsKey(userId)) {
      return _statsCache[userId]!;
    }

    // Initialize with default stats
    final stats = UserStats.initial(userId);
    _statsCache[userId] = stats;
    return stats;
  }

  @override
  Future<StatsSummary> getStatsSummary(String userId) async {
    final stats = await getUserStats(userId);
    return StatsSummary.fromUserStats(stats);
  }

  @override
  Future<List<DailyActivity>> getActivityHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final history = _activityCache[userId] ?? [];

    var filtered = history.where((a) {
      if (startDate != null && a.date.isBefore(startDate)) return false;
      if (endDate != null && a.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit < filtered.length) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  @override
  Future<void> recordQuizCompletion(
    String userId, {
    required int xpEarned,
    required int questionsAnswered,
    required int correctAnswers,
    required Duration studyTime,
    required String quizType,
    required String? continent,
    required bool isPerfectScore,
  }) async {
    final stats = await getUserStats(userId);

    // Update total stats
    final newTotalQuestions = stats.totalQuestions + questionsAnswered;
    final newCorrectAnswers = stats.correctAnswers + correctAnswers;
    final newAccuracy =
        newTotalQuestions > 0 ? newCorrectAnswers / newTotalQuestions : 0.0;

    final newTotalQuizzes = stats.totalQuizzes + 1;
    final newPerfectScores =
        isPerfectScore ? stats.perfectScores + 1 : stats.perfectScores;
    final currentScore =
        questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;
    final newAverageScore =
        ((stats.averageScore * stats.totalQuizzes) + currentScore) /
            newTotalQuizzes;

    // Update quiz type accuracy
    final newAccuracyPerQuizType =
        Map<String, double>.from(stats.accuracyPerQuizType);
    newAccuracyPerQuizType[quizType] = _updateRunningAverage(
      newAccuracyPerQuizType[quizType] ?? 0,
      currentScore,
      newTotalQuizzes,
    );

    // Update continent accuracy if applicable
    final newAccuracyPerContinent =
        Map<String, double>.from(stats.accuracyPerContinent);
    if (continent != null) {
      newAccuracyPerContinent[continent] = _updateRunningAverage(
        newAccuracyPerContinent[continent] ?? 0,
        currentScore,
        newTotalQuizzes,
      );
    }

    // Update daily activity
    await _updateDailyActivity(
      userId,
      xpEarned: xpEarned,
      quizzesCompleted: 1,
      questionsAnswered: questionsAnswered,
      correctAnswers: correctAnswers,
      studyTime: studyTime,
      perfectScores: isPerfectScore ? 1 : 0,
    );

    // Get updated activity history
    final activityHistory = _activityCache[userId] ?? [];

    _statsCache[userId] = stats.copyWith(
      totalXp: stats.totalXp + xpEarned,
      totalQuizzes: newTotalQuizzes,
      perfectScores: newPerfectScores,
      averageScore: newAverageScore,
      totalQuestions: newTotalQuestions,
      correctAnswers: newCorrectAnswers,
      accuracy: newAccuracy,
      totalStudyTime: stats.totalStudyTime + studyTime,
      accuracyPerQuizType: newAccuracyPerQuizType,
      accuracyPerContinent: newAccuracyPerContinent,
      activityHistory: activityHistory,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _updateDailyActivity(
    String userId, {
    required int xpEarned,
    required int quizzesCompleted,
    required int questionsAnswered,
    required int correctAnswers,
    required Duration studyTime,
    required int perfectScores,
  }) async {
    _activityCache.putIfAbsent(userId, () => []);

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingIndex = _activityCache[userId]!.indexWhere(
      (a) =>
          a.date.year == todayStart.year &&
          a.date.month == todayStart.month &&
          a.date.day == todayStart.day,
    );

    if (existingIndex >= 0) {
      final existing = _activityCache[userId]![existingIndex];
      _activityCache[userId]![existingIndex] = DailyActivity(
        date: existing.date,
        xpEarned: existing.xpEarned + xpEarned,
        quizzesCompleted: existing.quizzesCompleted + quizzesCompleted,
        questionsAnswered: existing.questionsAnswered + questionsAnswered,
        correctAnswers: existing.correctAnswers + correctAnswers,
        studyTime: existing.studyTime + studyTime,
        perfectScores: existing.perfectScores + perfectScores,
      );
    } else {
      _activityCache[userId]!.add(DailyActivity(
        date: todayStart,
        xpEarned: xpEarned,
        quizzesCompleted: quizzesCompleted,
        questionsAnswered: questionsAnswered,
        correctAnswers: correctAnswers,
        studyTime: studyTime,
        perfectScores: perfectScores,
      ));
    }

    // Keep only last 365 days
    _activityCache[userId]!.removeWhere(
      (a) => today.difference(a.date).inDays > 365,
    );
  }

  double _updateRunningAverage(
      double currentAvg, double newValue, int count) {
    if (count <= 1) return newValue;
    return ((currentAvg * (count - 1)) + newValue) / count;
  }

  @override
  Future<void> updateStreak(String userId) async {
    final stats = await getUserStats(userId);
    final activity = _activityCache[userId] ?? [];

    if (activity.isEmpty) {
      _statsCache[userId] = stats.copyWith(
        currentStreak: 1,
        longestStreak: 1,
      );
      return;
    }

    // Sort by date descending
    activity.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (final day in activity) {
      final dayStart = DateTime(day.date.year, day.date.month, day.date.day);

      if (dayStart == checkDate || dayStart == checkDate.subtract(const Duration(days: 1))) {
        if (day.xpEarned > 0) {
          streak++;
          checkDate = dayStart.subtract(const Duration(days: 1));
        }
      } else if (dayStart.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }

    final newLongestStreak =
        streak > stats.longestStreak ? streak : stats.longestStreak;

    _statsCache[userId] = stats.copyWith(
      currentStreak: streak,
      longestStreak: newLongestStreak,
    );
  }

  @override
  Future<void> addLearnedCountry(String userId, String continent) async {
    final stats = await getUserStats(userId);
    final countriesPerContinent =
        Map<String, int>.from(stats.countriesPerContinent);

    countriesPerContinent[continent] =
        (countriesPerContinent[continent] ?? 0) + 1;

    _statsCache[userId] = stats.copyWith(
      countriesPerContinent: countriesPerContinent,
    );
  }

  @override
  Future<List<WeakArea>> analyzeWeakAreas(String userId) async {
    final stats = await getUserStats(userId);
    final weakAreas = <WeakArea>[];

    // Analyze continent accuracy
    for (final entry in stats.accuracyPerContinent.entries) {
      if (entry.value < 0.6) {
        // Below 60% is considered weak
        weakAreas.add(WeakArea(
          areaType: 'continent',
          areaId: entry.key,
          nameEn: _getContinentNameEn(entry.key),
          nameAr: _getContinentNameAr(entry.key),
          accuracy: entry.value,
          questionsAttempted: 10, // Approximate
          recommendationEn: 'Practice more ${_getContinentNameEn(entry.key)} quizzes to improve!',
          recommendationAr: 'تدرب أكثر على اختبارات ${_getContinentNameAr(entry.key)} للتحسين!',
        ));
      }
    }

    // Analyze quiz type accuracy
    for (final entry in stats.accuracyPerQuizType.entries) {
      if (entry.value < 0.6) {
        weakAreas.add(WeakArea(
          areaType: 'quiz_type',
          areaId: entry.key,
          nameEn: _getQuizTypeNameEn(entry.key),
          nameAr: _getQuizTypeNameAr(entry.key),
          accuracy: entry.value,
          questionsAttempted: 10,
          recommendationEn: 'Focus on ${_getQuizTypeNameEn(entry.key)} questions!',
          recommendationAr: 'ركز على أسئلة ${_getQuizTypeNameAr(entry.key)}!',
        ));
      }
    }

    // Sort by accuracy (lowest first)
    weakAreas.sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return weakAreas.take(5).toList();
  }

  @override
  Future<List<StrongArea>> analyzeStrongAreas(String userId) async {
    final stats = await getUserStats(userId);
    final strongAreas = <StrongArea>[];

    // Analyze continent accuracy
    for (final entry in stats.accuracyPerContinent.entries) {
      if (entry.value >= 0.8) {
        // 80% or above is strong
        strongAreas.add(StrongArea(
          areaType: 'continent',
          areaId: entry.key,
          nameEn: _getContinentNameEn(entry.key),
          nameAr: _getContinentNameAr(entry.key),
          accuracy: entry.value,
          questionsAttempted: 10,
        ));
      }
    }

    // Analyze quiz type accuracy
    for (final entry in stats.accuracyPerQuizType.entries) {
      if (entry.value >= 0.8) {
        strongAreas.add(StrongArea(
          areaType: 'quiz_type',
          areaId: entry.key,
          nameEn: _getQuizTypeNameEn(entry.key),
          nameAr: _getQuizTypeNameAr(entry.key),
          accuracy: entry.value,
          questionsAttempted: 10,
        ));
      }
    }

    // Sort by accuracy (highest first)
    strongAreas.sort((a, b) => b.accuracy.compareTo(a.accuracy));

    return strongAreas.take(5).toList();
  }

  String _getContinentNameEn(String id) {
    const names = {
      'africa': 'Africa',
      'asia': 'Asia',
      'europe': 'Europe',
      'north_america': 'North America',
      'south_america': 'South America',
      'oceania': 'Oceania',
      'antarctica': 'Antarctica',
    };
    return names[id] ?? id;
  }

  String _getContinentNameAr(String id) {
    const names = {
      'africa': 'أفريقيا',
      'asia': 'آسيا',
      'europe': 'أوروبا',
      'north_america': 'أمريكا الشمالية',
      'south_america': 'أمريكا الجنوبية',
      'oceania': 'أوقيانوسيا',
      'antarctica': 'القارة القطبية الجنوبية',
    };
    return names[id] ?? id;
  }

  String _getQuizTypeNameEn(String id) {
    const names = {
      'flags': 'Flags',
      'capitals': 'Capitals',
      'countries': 'Countries',
      'mixed': 'Mixed',
    };
    return names[id] ?? id;
  }

  String _getQuizTypeNameAr(String id) {
    const names = {
      'flags': 'الأعلام',
      'capitals': 'العواصم',
      'countries': 'الدول',
      'mixed': 'مختلط',
    };
    return names[id] ?? id;
  }

  @override
  Stream<UserStats> watchUserStats(String userId) async* {
    yield await getUserStats(userId);
  }

  @override
  Future<void> resetStats(String userId) async {
    _statsCache[userId] = UserStats.initial(userId);
    _activityCache[userId] = [];
  }
}
