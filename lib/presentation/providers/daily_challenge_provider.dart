import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_repository.dart';
import '../../domain/entities/daily_challenge.dart';

/// Provider for the challenge repository
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return LocalChallengeRepository();
});

/// Provider for today's daily challenge
final dailyChallengeProvider = FutureProvider<DailyChallenge>((ref) async {
  final repository = ref.read(challengeRepositoryProvider);
  return repository.getTodaysChallenge();
});

/// Provider for challenge progress
final challengeProgressProvider =
    FutureProvider.family<ChallengeProgress?, String>((ref, userId) async {
  final repository = ref.read(challengeRepositoryProvider);
  final challenge = await ref.watch(dailyChallengeProvider.future);
  return repository.getProgress(userId, challenge.id);
});

/// Provider for watching challenge progress stream
final challengeProgressStreamProvider =
    StreamProvider.family<ChallengeProgress?, String>((ref, userId) {
  final repository = ref.read(challengeRepositoryProvider);
  final challengeAsync = ref.watch(dailyChallengeProvider);

  return challengeAsync.when(
    data: (challenge) => repository.watchProgress(userId, challenge.id),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// Provider for challenge streak
final challengeStreakProvider =
    FutureProvider.family<ChallengeStreak, String>((ref, userId) async {
  final repository = ref.read(challengeRepositoryProvider);
  return repository.getStreak(userId);
});

/// Provider for watching streak stream
final challengeStreakStreamProvider =
    StreamProvider.family<ChallengeStreak, String>((ref, userId) {
  final repository = ref.read(challengeRepositoryProvider);
  return repository.watchStreak(userId);
});

/// Provider for challenge history
final challengeHistoryProvider =
    FutureProvider.family<List<ChallengeProgress>, String>((ref, userId) async {
  final repository = ref.read(challengeRepositoryProvider);
  return repository.getChallengeHistory(userId);
});

/// State notifier for managing challenge progress
class ChallengeProgressNotifier extends StateNotifier<AsyncValue<ChallengeProgress?>> {
  ChallengeProgressNotifier(this._repository, this._userId, this._challengeId)
      : super(const AsyncValue.loading()) {
    _loadProgress();
  }

  final ChallengeRepository _repository;
  final String _userId;
  final String _challengeId;

  Future<void> _loadProgress() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _repository.getProgress(_userId, _challengeId);
      state = AsyncValue.data(progress);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> incrementProgress({int amount = 1}) async {
    final currentProgress = state.valueOrNull ??
        ChallengeProgress.initial(_challengeId, _userId);

    final updated = currentProgress.copyWith(
      currentValue: currentProgress.currentValue + amount,
    );

    await _repository.updateProgress(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> completeChallenge(int xpAwarded) async {
    await _repository.completeChallenge(_userId, _challengeId, xpAwarded);
    await _repository.updateStreak(_userId);

    final completed = ChallengeProgress(
      challengeId: _challengeId,
      userId: _userId,
      currentValue: state.valueOrNull?.currentValue ?? 0,
      isCompleted: true,
      completedAt: DateTime.now(),
      xpAwarded: xpAwarded,
    );

    state = AsyncValue.data(completed);
  }
}

/// Provider for challenge progress notifier
final challengeProgressNotifierProvider = StateNotifierProvider.family<
    ChallengeProgressNotifier, AsyncValue<ChallengeProgress?>, ChallengeUserKey>(
  (ref, key) {
    final repository = ref.read(challengeRepositoryProvider);
    return ChallengeProgressNotifier(repository, key.userId, key.challengeId);
  },
);

/// Key for challenge progress provider
class ChallengeUserKey {
  const ChallengeUserKey({
    required this.userId,
    required this.challengeId,
  });

  final String userId;
  final String challengeId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeUserKey &&
        other.userId == userId &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

/// Provider for time remaining until challenge expires
final challengeTimeRemainingProvider = StreamProvider<Duration>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final remaining = endOfDay.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  });
});

/// Extension for formatting duration
extension DurationFormatting on Duration {
  String toFormattedString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String toFullFormattedString(bool isArabic) {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (isArabic) {
      if (hours > 0) {
        return '$hours ساعة و $minutes دقيقة';
      } else if (minutes > 0) {
        return '$minutes دقيقة و $seconds ثانية';
      } else {
        return '$seconds ثانية';
      }
    } else {
      if (hours > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
      } else if (minutes > 0) {
        return '$minutes minute${minutes > 1 ? 's' : ''} and $seconds second${seconds > 1 ? 's' : ''}';
      } else {
        return '$seconds second${seconds > 1 ? 's' : ''}';
      }
    }
  }
}
