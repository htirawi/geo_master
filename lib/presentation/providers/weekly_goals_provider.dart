import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goals_repository.dart';
import '../../domain/entities/weekly_goal.dart';

/// Provider for the goals repository
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return LocalGoalsRepository();
});

/// Provider for current week's goals
final weeklyGoalsProvider =
    FutureProvider.family<WeeklyGoalsProgress, String>((ref, userId) async {
  final repository = ref.read(goalsRepositoryProvider);
  return repository.getCurrentWeekGoals(userId);
});

/// Provider for watching weekly goals stream
final weeklyGoalsStreamProvider =
    StreamProvider.family<WeeklyGoalsProgress, String>((ref, userId) {
  final repository = ref.read(goalsRepositoryProvider);
  return repository.watchCurrentWeekGoals(userId);
});

/// Provider for goal history
final goalHistoryProvider =
    FutureProvider.family<List<WeeklyGoalsProgress>, String>(
        (ref, userId) async {
  final repository = ref.read(goalsRepositoryProvider);
  return repository.getGoalHistory(userId);
});

/// Provider for available goal presets
final goalPresetsProvider = FutureProvider<List<WeeklyGoalPreset>>((ref) async {
  final repository = ref.read(goalsRepositoryProvider);
  return repository.getAvailablePresets();
});

/// State notifier for managing weekly goals
class WeeklyGoalsNotifier extends StateNotifier<AsyncValue<WeeklyGoalsProgress>> {
  WeeklyGoalsNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    _loadGoals();
  }

  final GoalsRepository _repository;
  final String _userId;

  Future<void> _loadGoals() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _repository.getCurrentWeekGoals(_userId);
      state = AsyncValue.data(progress);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadGoals();

  Future<void> setGoals(List<WeeklyGoal> goals) async {
    try {
      await _repository.setWeeklyGoals(_userId, goals);
      await _loadGoals();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGoalProgress(String goalId, int newValue) async {
    final currentProgress = state.valueOrNull;
    if (currentProgress == null) return;

    try {
      await _repository.updateGoalProgress(_userId, goalId, newValue);

      // Optimistic update
      final updatedGoals = currentProgress.goals.map((goal) {
        if (goal.id == goalId) {
          return goal.copyWith(currentValue: newValue);
        }
        return goal;
      }).toList();

      state = AsyncValue.data(currentProgress.copyWith(goals: updatedGoals));

      // Check if goal is now completed
      final goal = updatedGoals.firstWhere((g) => g.id == goalId);
      if (goal.isCompleted) {
        await _repository.completeGoal(_userId, goalId, goal.totalXpReward);
        await _loadGoals();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> incrementProgress(String goalId, {int amount = 1}) async {
    final currentProgress = state.valueOrNull;
    if (currentProgress == null) return;

    final goal = currentProgress.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );

    final newValue = goal.currentValue + amount;
    await updateGoalProgress(goalId, newValue);
  }

  Future<void> incrementProgressByType(WeeklyGoalType type,
      {int amount = 1}) async {
    final currentProgress = state.valueOrNull;
    if (currentProgress == null) return;

    final matchingGoals =
        currentProgress.goals.where((g) => g.type == type && !g.isCompleted);

    for (final goal in matchingGoals) {
      await incrementProgress(goal.id, amount: amount);
    }
  }

  Future<void> resetForNewWeek() async {
    try {
      await _repository.resetForNewWeek(_userId);
      await _loadGoals();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCustomGoal(WeeklyGoalPreset preset, GoalDifficulty difficulty) async {
    final currentProgress = state.valueOrNull;
    if (currentProgress == null) return;

    final newGoal = preset.createGoal(
      difficulty: difficulty,
      weekStart: currentProgress.weekStart,
      isCustom: true,
    );

    final updatedGoals = [...currentProgress.goals, newGoal];
    await setGoals(updatedGoals);
  }

  Future<void> removeGoal(String goalId) async {
    final currentProgress = state.valueOrNull;
    if (currentProgress == null) return;

    final updatedGoals = currentProgress.goals.where((g) => g.id != goalId).toList();
    await setGoals(updatedGoals);
  }
}

/// Provider for weekly goals state notifier
final weeklyGoalsNotifierProvider = StateNotifierProvider.family<
    WeeklyGoalsNotifier, AsyncValue<WeeklyGoalsProgress>, String>(
  (ref, userId) {
    final repository = ref.read(goalsRepositoryProvider);
    return WeeklyGoalsNotifier(repository, userId);
  },
);

/// Provider for days remaining in the week
final weekDaysRemainingProvider = Provider<int>((ref) {
  final now = DateTime.now();
  // Week ends on Sunday
  final daysUntilSunday = DateTime.sunday - now.weekday;
  return daysUntilSunday < 0 ? 0 : daysUntilSunday;
});

/// Provider for week progress percentage (how much of the week has passed)
final weekProgressProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final dayOfWeek = now.weekday;
  // Week starts Monday (1) and ends Sunday (7)
  return dayOfWeek / 7;
});

/// Extension for formatting goal statistics
extension GoalStatsExtension on WeeklyGoalsProgress {
  /// Get completion rate as percentage string
  String get completionRateString {
    if (goals.isEmpty) return '0%';
    final rate = (completedGoalsCount / goals.length) * 100;
    return '${rate.round()}%';
  }

  /// Get formatted overall progress
  String getOverallProgressString(bool isArabic) {
    final percent = (overallProgress * 100).round();
    if (isArabic) {
      return '$percent% مكتمل';
    }
    return '$percent% complete';
  }

  /// Check if all goals are completed
  bool get allGoalsCompleted =>
      goals.isNotEmpty && completedGoalsCount == goals.length;

  /// Get goals sorted by completion status
  List<WeeklyGoal> get sortedGoals {
    final sorted = List<WeeklyGoal>.from(goals);
    sorted.sort((a, b) {
      // Incomplete goals first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by progress percentage
      return b.progressPercentage.compareTo(a.progressPercentage);
    });
    return sorted;
  }
}
