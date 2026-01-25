import '../../domain/entities/weekly_goal.dart';

/// Repository interface for weekly goals
abstract class GoalsRepository {
  /// Get current week's goals for a user
  Future<WeeklyGoalsProgress> getCurrentWeekGoals(String userId);

  /// Get goals for a specific week
  Future<WeeklyGoalsProgress> getGoalsForWeek(String userId, DateTime weekStart);

  /// Set goals for the current week
  Future<void> setWeeklyGoals(String userId, List<WeeklyGoal> goals);

  /// Update progress for a specific goal
  Future<void> updateGoalProgress(String userId, String goalId, int newValue);

  /// Mark a goal as completed and award XP
  Future<void> completeGoal(String userId, String goalId, int xpAwarded);

  /// Get goal completion history
  Future<List<WeeklyGoalsProgress>> getGoalHistory(
    String userId, {
    int weekCount = 4,
  });

  /// Watch current week's goals in real-time
  Stream<WeeklyGoalsProgress> watchCurrentWeekGoals(String userId);

  /// Reset goals for a new week
  Future<void> resetForNewWeek(String userId);

  /// Get available goal presets
  Future<List<WeeklyGoalPreset>> getAvailablePresets();
}

/// Local implementation of goals repository
class LocalGoalsRepository implements GoalsRepository {
  LocalGoalsRepository();

  // In-memory storage
  final Map<String, WeeklyGoalsProgress> _progressCache = {};
  final Map<String, List<WeeklyGoalsProgress>> _historyCache = {};

  @override
  Future<WeeklyGoalsProgress> getCurrentWeekGoals(String userId) async {
    final existing = _progressCache[userId];

    if (existing != null) {
      // Check if we need to reset for a new week
      final now = DateTime.now();
      final currentWeekStart = _getWeekStart(now);

      if (existing.weekStart.isBefore(currentWeekStart)) {
        // New week - reset goals
        await resetForNewWeek(userId);
        return _progressCache[userId]!;
      }

      return existing;
    }

    // Initialize with default goals
    final progress = WeeklyGoalsProgress(
      userId: userId,
      goals: WeeklyGoalGenerator.generateDefaultGoals(),
      weekStart: _getWeekStart(DateTime.now()),
      totalGoalsCompleted: 0,
      totalXpEarned: 0,
    );

    _progressCache[userId] = progress;
    return progress;
  }

  @override
  Future<WeeklyGoalsProgress> getGoalsForWeek(
      String userId, DateTime weekStart) async {
    // Check history
    final history = _historyCache[userId] ?? [];
    final match = history.where((p) =>
        p.weekStart.year == weekStart.year &&
        p.weekStart.month == weekStart.month &&
        p.weekStart.day == weekStart.day);

    if (match.isNotEmpty) {
      return match.first;
    }

    // Return empty progress for that week
    return WeeklyGoalsProgress(
      userId: userId,
      goals: const [],
      weekStart: weekStart,
      totalGoalsCompleted: 0,
      totalXpEarned: 0,
    );
  }

  @override
  Future<void> setWeeklyGoals(String userId, List<WeeklyGoal> goals) async {
    final existing =
        _progressCache[userId] ?? WeeklyGoalsProgress.initial(userId);

    _progressCache[userId] = existing.copyWith(goals: goals);
  }

  @override
  Future<void> updateGoalProgress(
      String userId, String goalId, int newValue) async {
    final progress = _progressCache[userId];
    if (progress == null) return;

    final updatedGoals = progress.goals.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(currentValue: newValue);
      }
      return goal;
    }).toList();

    _progressCache[userId] = progress.copyWith(goals: updatedGoals);
  }

  @override
  Future<void> completeGoal(String userId, String goalId, int xpAwarded) async {
    final progress = _progressCache[userId];
    if (progress == null) return;

    final updatedGoals = progress.goals.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(currentValue: goal.targetValue);
      }
      return goal;
    }).toList();

    _progressCache[userId] = progress.copyWith(
      goals: updatedGoals,
      totalGoalsCompleted: progress.totalGoalsCompleted + 1,
      totalXpEarned: progress.totalXpEarned + xpAwarded,
    );
  }

  @override
  Future<List<WeeklyGoalsProgress>> getGoalHistory(
    String userId, {
    int weekCount = 4,
  }) async {
    return _historyCache[userId]?.take(weekCount).toList() ?? [];
  }

  @override
  Stream<WeeklyGoalsProgress> watchCurrentWeekGoals(String userId) async* {
    yield await getCurrentWeekGoals(userId);
  }

  @override
  Future<void> resetForNewWeek(String userId) async {
    final existing = _progressCache[userId];

    // Archive old progress to history
    if (existing != null) {
      _historyCache.putIfAbsent(userId, () => []);
      _historyCache[userId]!.insert(0, existing);

      // Keep only last 12 weeks
      if (_historyCache[userId]!.length > 12) {
        _historyCache[userId] = _historyCache[userId]!.take(12).toList();
      }
    }

    // Create new goals for this week
    final newProgress = WeeklyGoalsProgress(
      userId: userId,
      goals: WeeklyGoalGenerator.generateDefaultGoals(),
      weekStart: _getWeekStart(DateTime.now()),
      totalGoalsCompleted: 0,
      totalXpEarned: 0,
    );

    _progressCache[userId] = newProgress;
  }

  @override
  Future<List<WeeklyGoalPreset>> getAvailablePresets() async {
    return WeeklyGoalPreset.allPresets;
  }

  /// Increment progress for a goal (utility method)
  Future<void> incrementGoalProgress(
    String userId,
    String goalId, {
    int amount = 1,
  }) async {
    final progress = _progressCache[userId];
    if (progress == null) return;

    final goal = progress.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );

    final newValue = goal.currentValue + amount;
    await updateGoalProgress(userId, goalId, newValue);

    // Check if completed
    if (newValue >= goal.targetValue && !goal.isCompleted) {
      await completeGoal(userId, goalId, goal.totalXpReward);
    }
  }

  /// Increment progress by goal type (utility method)
  Future<void> incrementProgressByType(
    String userId,
    WeeklyGoalType type, {
    int amount = 1,
  }) async {
    final progress = _progressCache[userId];
    if (progress == null) return;

    final matchingGoals = progress.goals.where((g) => g.type == type);

    for (final goal in matchingGoals) {
      if (!goal.isCompleted) {
        await incrementGoalProgress(userId, goal.id, amount: amount);
      }
    }
  }

  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }
}
