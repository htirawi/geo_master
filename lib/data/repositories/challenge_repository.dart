import '../../domain/entities/daily_challenge.dart';

/// Repository interface for daily challenges
abstract class ChallengeRepository {
  /// Get today's challenge
  Future<DailyChallenge> getTodaysChallenge();

  /// Get challenge for a specific date
  Future<DailyChallenge> getChallengeForDate(DateTime date);

  /// Get user's progress for a specific challenge
  Future<ChallengeProgress?> getProgress(String userId, String challengeId);

  /// Update user's progress for a challenge
  Future<void> updateProgress(ChallengeProgress progress);

  /// Mark a challenge as completed
  Future<void> completeChallenge(
    String userId,
    String challengeId,
    int xpAwarded,
  );

  /// Get user's challenge streak
  Future<ChallengeStreak> getStreak(String userId);

  /// Update user's streak after completing a challenge
  Future<ChallengeStreak> updateStreak(String userId);

  /// Get challenge history for a user
  Future<List<ChallengeProgress>> getChallengeHistory(
    String userId, {
    int limit = 30,
  });

  /// Watch today's challenge progress in real-time
  Stream<ChallengeProgress?> watchProgress(String userId, String challengeId);

  /// Watch user's streak in real-time
  Stream<ChallengeStreak> watchStreak(String userId);
}

/// Local implementation of challenge repository
class LocalChallengeRepository implements ChallengeRepository {
  LocalChallengeRepository();

  // In-memory storage for demo purposes
  // In production, this would use SharedPreferences or a database
  final Map<String, ChallengeProgress> _progressCache = {};
  final Map<String, ChallengeStreak> _streakCache = {};
  final Map<String, List<ChallengeProgress>> _historyCache = {};

  @override
  Future<DailyChallenge> getTodaysChallenge() async {
    return DailyChallengeGenerator.generateForToday();
  }

  @override
  Future<DailyChallenge> getChallengeForDate(DateTime date) async {
    return DailyChallengeGenerator.generateForDate(date);
  }

  @override
  Future<ChallengeProgress?> getProgress(
      String userId, String challengeId) async {
    final key = '${userId}_$challengeId';
    return _progressCache[key];
  }

  @override
  Future<void> updateProgress(ChallengeProgress progress) async {
    final key = '${progress.userId}_${progress.challengeId}';
    _progressCache[key] = progress;
  }

  @override
  Future<void> completeChallenge(
    String userId,
    String challengeId,
    int xpAwarded,
  ) async {
    final key = '${userId}_$challengeId';
    final existing = _progressCache[key];

    final completedProgress = ChallengeProgress(
      challengeId: challengeId,
      userId: userId,
      currentValue: existing?.currentValue ?? 0,
      isCompleted: true,
      completedAt: DateTime.now(),
      xpAwarded: xpAwarded,
    );

    _progressCache[key] = completedProgress;

    // Add to history
    _historyCache.putIfAbsent(userId, () => []);
    _historyCache[userId]!.insert(0, completedProgress);
  }

  @override
  Future<ChallengeStreak> getStreak(String userId) async {
    return _streakCache[userId] ?? ChallengeStreak.initial(userId);
  }

  @override
  Future<ChallengeStreak> updateStreak(String userId) async {
    final current = _streakCache[userId] ?? ChallengeStreak.initial(userId);
    final now = DateTime.now();

    int newStreak;
    if (current.isStreakActive) {
      // Continue streak
      newStreak = current.currentStreak + 1;
    } else {
      // Start new streak
      newStreak = 1;
    }

    final updated = ChallengeStreak(
      userId: userId,
      currentStreak: newStreak,
      longestStreak:
          newStreak > current.longestStreak ? newStreak : current.longestStreak,
      lastCompletedDate: now,
      totalChallengesCompleted: current.totalChallengesCompleted + 1,
    );

    _streakCache[userId] = updated;
    return updated;
  }

  @override
  Future<List<ChallengeProgress>> getChallengeHistory(
    String userId, {
    int limit = 30,
  }) async {
    final history = _historyCache[userId] ?? [];
    return history.take(limit).toList();
  }

  @override
  Stream<ChallengeProgress?> watchProgress(String userId, String challengeId) {
    // For local implementation, return a simple stream
    return Stream.value(_progressCache['${userId}_$challengeId']);
  }

  @override
  Stream<ChallengeStreak> watchStreak(String userId) {
    // For local implementation, return a simple stream
    return Stream.value(_streakCache[userId] ?? ChallengeStreak.initial(userId));
  }

  /// Increment progress for a challenge (utility method)
  Future<ChallengeProgress> incrementProgress(
    String userId,
    String challengeId, {
    int amount = 1,
  }) async {
    final key = '${userId}_$challengeId';
    final existing =
        _progressCache[key] ?? ChallengeProgress.initial(challengeId, userId);

    final updated = existing.copyWith(
      currentValue: existing.currentValue + amount,
    );

    _progressCache[key] = updated;
    return updated;
  }
}
