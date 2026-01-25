import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement.dart';
import '../components/celebrations/achievement_popup.dart';

/// State for achievement notifications
class AchievementNotificationState {
  const AchievementNotificationState({
    this.pendingAchievements = const [],
    this.currentlyShowing,
    this.isShowing = false,
  });

  /// Queue of achievements waiting to be shown
  final List<Achievement> pendingAchievements;

  /// Achievement currently being displayed
  final Achievement? currentlyShowing;

  /// Whether a popup is currently visible
  final bool isShowing;

  AchievementNotificationState copyWith({
    List<Achievement>? pendingAchievements,
    Achievement? currentlyShowing,
    bool? isShowing,
  }) {
    return AchievementNotificationState(
      pendingAchievements: pendingAchievements ?? this.pendingAchievements,
      currentlyShowing: currentlyShowing ?? this.currentlyShowing,
      isShowing: isShowing ?? this.isShowing,
    );
  }
}

/// Notifier for managing achievement notification queue
class AchievementNotificationNotifier
    extends StateNotifier<AchievementNotificationState> {
  AchievementNotificationNotifier()
      : super(const AchievementNotificationState());

  final Queue<Achievement> _queue = Queue<Achievement>();
  BuildContext? _context;
  Timer? _autoShowTimer;

  /// Set the context for showing popups
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Queue an achievement to be shown
  void queueAchievement(Achievement achievement) {
    _queue.add(achievement);
    state = state.copyWith(
      pendingAchievements: _queue.toList(),
    );

    // If not currently showing, start showing
    if (!state.isShowing) {
      _showNext();
    }
  }

  /// Queue multiple achievements
  void queueAchievements(List<Achievement> achievements) {
    for (final achievement in achievements) {
      _queue.add(achievement);
    }
    state = state.copyWith(
      pendingAchievements: _queue.toList(),
    );

    if (!state.isShowing) {
      _showNext();
    }
  }

  /// Show the next achievement in queue
  Future<void> _showNext() async {
    if (_queue.isEmpty || _context == null || !mounted) {
      state = state.copyWith(
        isShowing: false,
        currentlyShowing: null,
      );
      return;
    }

    final achievement = _queue.removeFirst();
    state = state.copyWith(
      isShowing: true,
      currentlyShowing: achievement,
      pendingAchievements: _queue.toList(),
    );

    // Show the popup
    if (_context != null && _context!.mounted) {
      await AchievementPopup.show(
        _context!,
        achievement: achievement,
        onDismiss: () {
          // Small delay before showing next
          _autoShowTimer?.cancel();
          _autoShowTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showNext();
            }
          });
        },
      );
    } else {
      _showNext();
    }
  }

  /// Clear all pending achievements
  void clearQueue() {
    _queue.clear();
    _autoShowTimer?.cancel();
    state = const AchievementNotificationState();
  }

  /// Check and trigger achievements based on user progress
  void checkAndTriggerAchievements({
    int? quizzesCompleted,
    int? perfectQuizzes,
    int? streakDays,
    int? countriesLearned,
  }) {
    final achievements = <Achievement>[];

    // Quiz achievements
    if (quizzesCompleted != null) {
      if (quizzesCompleted == 1) {
        final achievement = Achievements.getById('first_quiz');
        if (achievement != null) achievements.add(achievement);
      }
      if (quizzesCompleted == 50) {
        final achievement = Achievements.getById('quizzes_50');
        if (achievement != null) achievements.add(achievement);
      }
    }

    // Perfect quiz achievement
    if (perfectQuizzes != null && perfectQuizzes == 1) {
      final achievement = Achievements.getById('perfect_quiz');
      if (achievement != null) achievements.add(achievement);
    }

    // Streak achievements
    if (streakDays != null) {
      if (streakDays == 3) {
        final achievement = Achievements.getById('streak_3');
        if (achievement != null) achievements.add(achievement);
      }
      if (streakDays == 7) {
        final achievement = Achievements.getById('streak_7');
        if (achievement != null) achievements.add(achievement);
      }
      if (streakDays == 30) {
        final achievement = Achievements.getById('streak_30');
        if (achievement != null) achievements.add(achievement);
      }
      if (streakDays == 100) {
        final achievement = Achievements.getById('streak_100');
        if (achievement != null) achievements.add(achievement);
      }
    }

    // Countries learned achievements
    if (countriesLearned != null) {
      if (countriesLearned == 1) {
        final achievement = Achievements.getById('first_country');
        if (achievement != null) achievements.add(achievement);
      }
      if (countriesLearned == 10) {
        final achievement = Achievements.getById('countries_10');
        if (achievement != null) achievements.add(achievement);
      }
      if (countriesLearned == 50) {
        final achievement = Achievements.getById('countries_50');
        if (achievement != null) achievements.add(achievement);
      }
      if (countriesLearned == 100) {
        final achievement = Achievements.getById('countries_100');
        if (achievement != null) achievements.add(achievement);
      }
      if (countriesLearned == 195) {
        final achievement = Achievements.getById('countries_all');
        if (achievement != null) achievements.add(achievement);
      }
    }

    if (achievements.isNotEmpty) {
      queueAchievements(achievements);
    }
  }

  @override
  void dispose() {
    _autoShowTimer?.cancel();
    super.dispose();
  }
}

/// Provider for achievement notifications
final achievementNotificationProvider = StateNotifierProvider<
    AchievementNotificationNotifier, AchievementNotificationState>((ref) {
  return AchievementNotificationNotifier();
});

/// Widget that sets up the achievement notification context
class AchievementNotificationListener extends ConsumerWidget {
  const AchievementNotificationListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set context for the notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(achievementNotificationProvider.notifier).setContext(context);
    });

    return child;
  }
}
