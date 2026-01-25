import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/explorer_level.dart';
import '../components/celebrations/level_up_overlay.dart';
import '../components/celebrations/streak_celebration.dart';

/// Pending celebration event
sealed class CelebrationEvent {
  const CelebrationEvent();
}

/// Streak milestone reached
class StreakMilestoneEvent extends CelebrationEvent {
  const StreakMilestoneEvent(this.streakDays);
  final int streakDays;
}

/// Level up event
class LevelUpEvent extends CelebrationEvent {
  const LevelUpEvent({
    required this.newLevel,
    required this.previousLevel,
  });
  final ExplorerLevel newLevel;
  final ExplorerLevel previousLevel;
}

/// State for managing pending celebrations
class CelebrationState {
  const CelebrationState({
    this.pendingEvents = const [],
    this.isShowing = false,
  });

  /// Queue of pending celebration events
  final List<CelebrationEvent> pendingEvents;

  /// Whether a celebration is currently showing
  final bool isShowing;

  CelebrationState copyWith({
    List<CelebrationEvent>? pendingEvents,
    bool? isShowing,
  }) {
    return CelebrationState(
      pendingEvents: pendingEvents ?? this.pendingEvents,
      isShowing: isShowing ?? this.isShowing,
    );
  }
}

/// Manages celebration events and displays
class CelebrationNotifier extends StateNotifier<CelebrationState> {
  CelebrationNotifier() : super(const CelebrationState());

  BuildContext? _context;
  Timer? _showTimer;

  /// Set the context for showing overlays
  void setContext(BuildContext context) {
    _context = context;
    // Try to show pending celebrations
    if (state.pendingEvents.isNotEmpty && !state.isShowing) {
      _showNext();
    }
  }

  /// Queue a streak milestone celebration
  void queueStreakMilestone(int streakDays) {
    if (!StreakMilestone.isMilestone(streakDays)) return;

    final event = StreakMilestoneEvent(streakDays);
    state = state.copyWith(
      pendingEvents: [...state.pendingEvents, event],
    );

    if (!state.isShowing) {
      _showNext();
    }
  }

  /// Queue a level up celebration
  void queueLevelUp({
    required ExplorerLevel newLevel,
    required ExplorerLevel previousLevel,
  }) {
    final event = LevelUpEvent(
      newLevel: newLevel,
      previousLevel: previousLevel,
    );
    state = state.copyWith(
      pendingEvents: [...state.pendingEvents, event],
    );

    if (!state.isShowing) {
      _showNext();
    }
  }

  /// Check and queue level up if XP threshold crossed
  void checkLevelUp(int previousXp, int newXp) {
    final previousLevel = ExplorerLevel.fromXp(previousXp);
    final newLevel = ExplorerLevel.fromXp(newXp);

    if (newLevel.index > previousLevel.index) {
      queueLevelUp(newLevel: newLevel, previousLevel: previousLevel);
    }
  }

  /// Check and queue streak milestone if reached
  void checkStreakMilestone(int previousStreak, int newStreak) {
    // Check if we crossed a milestone threshold
    for (final milestone in StreakMilestone.milestones) {
      if (previousStreak < milestone.days && newStreak >= milestone.days) {
        queueStreakMilestone(milestone.days);
        break; // Only show one milestone at a time
      }
    }
  }

  /// Show the next celebration in queue
  Future<void> _showNext() async {
    if (state.pendingEvents.isEmpty || _context == null || !mounted) {
      state = state.copyWith(isShowing: false);
      return;
    }

    // Small delay to ensure context is ready
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted || _context == null || !_context!.mounted) {
      return;
    }

    final events = List<CelebrationEvent>.from(state.pendingEvents);
    final event = events.removeAt(0);

    state = state.copyWith(
      pendingEvents: events,
      isShowing: true,
    );

    try {
      switch (event) {
        case StreakMilestoneEvent(:final streakDays):
          await StreakCelebration.show(
            _context!,
            streakDays: streakDays,
            onDismiss: _scheduleNext,
          );

        case LevelUpEvent(:final newLevel, :final previousLevel):
          await LevelUpOverlay.show(
            _context!,
            newLevel: newLevel,
            previousLevel: previousLevel,
            onDismiss: _scheduleNext,
          );
      }
    } catch (_) {
      // Context may have been disposed
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    _showTimer?.cancel();
    _showTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        state = state.copyWith(isShowing: false);
        _showNext();
      }
    });
  }

  /// Clear all pending celebrations
  void clearAll() {
    _showTimer?.cancel();
    state = const CelebrationState();
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }
}

/// Provider for celebration management
final celebrationProvider =
    StateNotifierProvider<CelebrationNotifier, CelebrationState>((ref) {
  return CelebrationNotifier();
});

/// Widget that sets up the celebration context
class CelebrationListener extends ConsumerWidget {
  const CelebrationListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set context for the notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(celebrationProvider.notifier).setContext(context);
    });

    return child;
  }
}
