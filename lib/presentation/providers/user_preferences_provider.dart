import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di/service_locator.dart';

/// Local learning preferences (stored in SharedPreferences)
/// Used for personalization before/without cloud sync
class LocalLearningPreferences {
  const LocalLearningPreferences({
    this.interests = const {},
    this.difficulty = 'medium',
    this.dailyGoal = 'casual',
  });

  final Set<String> interests;
  final String difficulty;
  final String dailyGoal;

  /// Check if user has any interest selected
  bool get hasInterests => interests.isNotEmpty;

  /// Check if user is interested in a specific topic
  bool isInterestedIn(String topic) => interests.contains(topic);

  /// Get difficulty level as integer (1-3)
  int get difficultyLevel {
    switch (difficulty) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 2;
    }
  }

  /// Get daily goal in minutes
  int get dailyGoalMinutes {
    switch (dailyGoal) {
      case 'casual':
        return 5;
      case 'regular':
        return 10;
      case 'serious':
        return 15;
      case 'intense':
        return 30;
      default:
        return 5;
    }
  }

  LocalLearningPreferences copyWith({
    Set<String>? interests,
    String? difficulty,
    String? dailyGoal,
  }) {
    return LocalLearningPreferences(
      interests: interests ?? this.interests,
      difficulty: difficulty ?? this.difficulty,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  String toString() =>
      'LocalLearningPreferences(interests: $interests, difficulty: $difficulty, dailyGoal: $dailyGoal)';
}

/// Local learning preferences state notifier
class LocalLearningPreferencesNotifier extends StateNotifier<LocalLearningPreferences> {
  LocalLearningPreferencesNotifier(this._prefs) : super(const LocalLearningPreferences()) {
    _loadPreferences();
  }

  static const _keyInterests = 'user_interests';
  static const _keyDifficulty = 'user_difficulty';
  static const _keyDailyGoal = 'user_daily_goal';

  final SharedPreferences _prefs;

  void _loadPreferences() {
    final interestsList = _prefs.getStringList(_keyInterests) ?? [];
    final difficulty = _prefs.getString(_keyDifficulty) ?? 'medium';
    final dailyGoal = _prefs.getString(_keyDailyGoal) ?? 'casual';

    state = LocalLearningPreferences(
      interests: interestsList.toSet(),
      difficulty: difficulty,
      dailyGoal: dailyGoal,
    );
  }

  /// Save all preferences at once (from personalization screen)
  Future<void> savePreferences({
    required Set<String> interests,
    required String difficulty,
    required String dailyGoal,
  }) async {
    await _prefs.setStringList(_keyInterests, interests.toList());
    await _prefs.setString(_keyDifficulty, difficulty);
    await _prefs.setString(_keyDailyGoal, dailyGoal);

    state = LocalLearningPreferences(
      interests: interests,
      difficulty: difficulty,
      dailyGoal: dailyGoal,
    );
  }

  /// Toggle a single interest
  Future<void> toggleInterest(String interest) async {
    final newInterests = Set<String>.from(state.interests);
    if (newInterests.contains(interest)) {
      newInterests.remove(interest);
    } else {
      newInterests.add(interest);
    }

    await _prefs.setStringList(_keyInterests, newInterests.toList());
    state = state.copyWith(interests: newInterests);
  }

  /// Update difficulty
  Future<void> setDifficulty(String difficulty) async {
    await _prefs.setString(_keyDifficulty, difficulty);
    state = state.copyWith(difficulty: difficulty);
  }

  /// Update daily goal
  Future<void> setDailyGoal(String dailyGoal) async {
    await _prefs.setString(_keyDailyGoal, dailyGoal);
    state = state.copyWith(dailyGoal: dailyGoal);
  }

  /// Reset preferences (for testing)
  Future<void> reset() async {
    await _prefs.remove(_keyInterests);
    await _prefs.remove(_keyDifficulty);
    await _prefs.remove(_keyDailyGoal);

    state = const LocalLearningPreferences();
  }
}

/// Local learning preferences provider
final localLearningPreferencesProvider =
    StateNotifierProvider<LocalLearningPreferencesNotifier, LocalLearningPreferences>((ref) {
  final prefs = sl<SharedPreferences>();
  return LocalLearningPreferencesNotifier(prefs);
});

/// Streak data for gamification
class StreakData {
  const StreakData({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActivityDate,
    this.totalXp = 0,
    this.totalQuizzes = 0,
    this.perfectQuizzes = 0,
  });

  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActivityDate;
  final int totalXp;
  final int totalQuizzes;
  final int perfectQuizzes;

  /// Check if streak is active today
  bool get isActiveToday {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    return today.difference(lastDate).inDays == 0;
  }

  /// Check if streak is still valid (active today or yesterday)
  bool get isStreakValid {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    return today.difference(lastDate).inDays <= 1;
  }

  /// Get streak bonus multiplier based on current streak
  double get streakBonusMultiplier {
    if (currentStreak >= 30) return 2.0; // +100%
    if (currentStreak >= 14) return 1.5; // +50%
    if (currentStreak >= 7) return 1.25; // +25%
    if (currentStreak >= 3) return 1.1; // +10%
    return 1.0;
  }

  /// Get streak bonus percentage for display
  int get streakBonusPercent {
    return ((streakBonusMultiplier - 1.0) * 100).round();
  }

  StreakData copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActivityDate,
    int? totalXp,
    int? totalQuizzes,
    int? perfectQuizzes,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalXp: totalXp ?? this.totalXp,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      perfectQuizzes: perfectQuizzes ?? this.perfectQuizzes,
    );
  }
}

/// Streak data state notifier with persistence
class StreakDataNotifier extends StateNotifier<StreakData> {
  StreakDataNotifier(this._prefs) : super(const StreakData()) {
    _loadStreakData();
  }

  static const _keyCurrentStreak = 'streak_current';
  static const _keyBestStreak = 'streak_best';
  static const _keyLastActivity = 'streak_last_activity';
  static const _keyTotalXp = 'user_total_xp';
  static const _keyTotalQuizzes = 'user_total_quizzes';
  static const _keyPerfectQuizzes = 'user_perfect_quizzes';

  final SharedPreferences _prefs;

  void _loadStreakData() {
    final currentStreak = _prefs.getInt(_keyCurrentStreak) ?? 0;
    final bestStreak = _prefs.getInt(_keyBestStreak) ?? 0;
    final lastActivityStr = _prefs.getString(_keyLastActivity);
    final totalXp = _prefs.getInt(_keyTotalXp) ?? 0;
    final totalQuizzes = _prefs.getInt(_keyTotalQuizzes) ?? 0;
    final perfectQuizzes = _prefs.getInt(_keyPerfectQuizzes) ?? 0;

    DateTime? lastActivity;
    if (lastActivityStr != null) {
      lastActivity = DateTime.tryParse(lastActivityStr);
    }

    // Check if streak should be reset (more than 1 day since last activity)
    int adjustedStreak = currentStreak;
    if (lastActivity != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final daysSinceActivity = today.difference(lastDate).inDays;

      if (daysSinceActivity > 1) {
        // Streak is broken
        adjustedStreak = 0;
        _prefs.setInt(_keyCurrentStreak, 0);
      }
    }

    state = StreakData(
      currentStreak: adjustedStreak,
      bestStreak: bestStreak,
      lastActivityDate: lastActivity,
      totalXp: totalXp,
      totalQuizzes: totalQuizzes,
      perfectQuizzes: perfectQuizzes,
    );
  }

  /// Record a quiz completion and update streak
  Future<void> recordQuizCompletion({
    required int xpEarned,
    required bool isPerfect,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newCurrentStreak = state.currentStreak;

    // Check if this is a new day
    if (state.lastActivityDate != null) {
      final lastDate = DateTime(
        state.lastActivityDate!.year,
        state.lastActivityDate!.month,
        state.lastActivityDate!.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 1) {
        // Consecutive day - increment streak
        newCurrentStreak = state.currentStreak + 1;
      } else if (daysDiff > 1) {
        // Streak broken - reset to 1
        newCurrentStreak = 1;
      }
      // If daysDiff == 0, same day - keep current streak
    } else {
      // First activity ever
      newCurrentStreak = 1;
    }

    final newBestStreak = newCurrentStreak > state.bestStreak
        ? newCurrentStreak
        : state.bestStreak;

    // Save to preferences
    await _prefs.setInt(_keyCurrentStreak, newCurrentStreak);
    await _prefs.setInt(_keyBestStreak, newBestStreak);
    await _prefs.setString(_keyLastActivity, now.toIso8601String());
    await _prefs.setInt(_keyTotalXp, state.totalXp + xpEarned);
    await _prefs.setInt(_keyTotalQuizzes, state.totalQuizzes + 1);
    if (isPerfect) {
      await _prefs.setInt(_keyPerfectQuizzes, state.perfectQuizzes + 1);
    }

    state = state.copyWith(
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      lastActivityDate: now,
      totalXp: state.totalXp + xpEarned,
      totalQuizzes: state.totalQuizzes + 1,
      perfectQuizzes: isPerfect ? state.perfectQuizzes + 1 : null,
    );
  }

  /// Reset streak data (for testing or account reset)
  Future<void> resetStreakData() async {
    await _prefs.remove(_keyCurrentStreak);
    await _prefs.remove(_keyBestStreak);
    await _prefs.remove(_keyLastActivity);
    await _prefs.remove(_keyTotalXp);
    await _prefs.remove(_keyTotalQuizzes);
    await _prefs.remove(_keyPerfectQuizzes);

    state = const StreakData();
  }
}

/// Streak data provider
final streakDataProvider = StateNotifierProvider<StreakDataNotifier, StreakData>((ref) {
  final prefs = sl<SharedPreferences>();
  return StreakDataNotifier(prefs);
});

