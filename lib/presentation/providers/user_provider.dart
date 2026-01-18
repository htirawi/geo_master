import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_user_repository.dart';
import 'auth_provider.dart';

/// User profile state
sealed class UserProfileState {
  const UserProfileState();

  bool get isLoading => this is UserProfileLoading;
  bool get hasData => this is UserProfileLoaded;

  User? get user {
    if (this is UserProfileLoaded) {
      return (this as UserProfileLoaded).user;
    }
    return null;
  }
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded(this.user);

  @override
  final User user;
}

class UserProfileError extends UserProfileState {
  const UserProfileError(this.failure);

  final Failure failure;
}

/// User profile state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfileState>> {
  UserProfileNotifier(this._userRepository)
      : super(const AsyncValue.data(UserProfileInitial()));

  final IUserRepository _userRepository;

  /// Load user profile from Firestore
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();

    final result = await _userRepository.getCurrentUserData();

    result.fold(
      (failure) => state = AsyncValue.data(UserProfileError(failure)),
      (user) => state = AsyncValue.data(UserProfileLoaded(user)),
    );
  }

  /// Save user profile
  Future<void> saveProfile(User user) async {
    state = const AsyncValue.loading();

    final result = await _userRepository.saveUser(user);

    result.fold(
      (failure) => state = AsyncValue.data(UserProfileError(failure)),
      (_) => state = AsyncValue.data(UserProfileLoaded(user)),
    );
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return;

    final result = await _userRepository.updatePreferences(
      currentUser.id,
      preferences,
    );

    result.fold(
      (failure) => state = AsyncValue.data(UserProfileError(failure)),
      (_) {
        final updatedUser = currentUser.copyWith(preferences: preferences);
        state = AsyncValue.data(UserProfileLoaded(updatedUser));
      },
    );
  }

  /// Add XP to user
  Future<UserProgress?> addXp(int xp) async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return null;

    final result = await _userRepository.addXp(currentUser.id, xp);

    return result.fold(
      (failure) => null,
      (progress) {
        final updatedUser = currentUser.copyWith(progress: progress);
        state = AsyncValue.data(UserProfileLoaded(updatedUser));
        return progress;
      },
    );
  }

  /// Update streak
  Future<void> updateStreak() async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return;

    final result = await _userRepository.updateStreak(currentUser.id);

    result.fold(
      (failure) {},
      (progress) {
        final updatedUser = currentUser.copyWith(progress: progress);
        state = AsyncValue.data(UserProfileLoaded(updatedUser));
      },
    );
  }

  /// Increment quizzes completed
  Future<void> incrementQuizzesCompleted() async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return;

    await _userRepository.incrementQuizzesCompleted(currentUser.id);
  }

  /// Update quiz stats
  Future<void> updateQuizStats({
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return;

    await _userRepository.updateQuizStats(
      currentUser.id,
      questionsAnswered: questionsAnswered,
      correctAnswers: correctAnswers,
    );
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return;

    final result = await _userRepository.unlockAchievement(
      currentUser.id,
      achievementId,
    );

    result.fold(
      (failure) {},
      (_) {
        final updatedAchievements = [
          ...currentUser.progress.unlockedAchievements,
          achievementId,
        ];
        final updatedProgress = currentUser.progress.copyWith(
          unlockedAchievements: updatedAchievements,
        );
        final updatedUser = currentUser.copyWith(progress: updatedProgress);
        state = AsyncValue.data(UserProfileLoaded(updatedUser));
      },
    );
  }

  /// Check and unlock achievements
  Future<List<String>> checkAndUnlockAchievements() async {
    final currentUser = state.valueOrNull?.user;
    if (currentUser == null) return [];

    final result = await _userRepository.checkAndUnlockAchievements(
      currentUser.id,
    );

    return result.fold(
      (failure) => [],
      (newAchievements) {
        if (newAchievements.isNotEmpty) {
          final updatedAchievements = [
            ...currentUser.progress.unlockedAchievements,
            ...newAchievements,
          ];
          final updatedProgress = currentUser.progress.copyWith(
            unlockedAchievements: updatedAchievements,
          );
          final updatedUser = currentUser.copyWith(progress: updatedProgress);
          state = AsyncValue.data(UserProfileLoaded(updatedUser));
        }
        return newAchievements;
      },
    );
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(UserProfileInitial());
  }
}

/// User profile state provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfileState>>(
        (ref) {
  final userRepository = sl<IUserRepository>();
  final notifier = UserProfileNotifier(userRepository);

  // Auto-load when user is authenticated
  final authState = ref.watch(authStateProvider);
  final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;

  if (isAuthenticated) {
    notifier.loadProfile();
  } else {
    notifier.reset();
  }

  return notifier;
});

/// Current user profile provider (convenience)
final userDataProvider = Provider<User?>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.valueOrNull?.user;
});

/// User preferences provider (convenience)
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final user = ref.watch(userDataProvider);
  return user?.preferences ?? const UserPreferences();
});

/// User progress provider (convenience)
final userProgressProvider = Provider<UserProgress>((ref) {
  final user = ref.watch(userDataProvider);
  return user?.progress ?? const UserProgress();
});

/// User level provider
final userLevelProvider = Provider<int>((ref) {
  final progress = ref.watch(userProgressProvider);
  return progress.level;
});

/// User XP provider
final userXpProvider = Provider<int>((ref) {
  final progress = ref.watch(userProgressProvider);
  return progress.totalXp;
});

/// User streak provider
final userStreakProvider = Provider<int>((ref) {
  final progress = ref.watch(userProgressProvider);
  return progress.currentStreak;
});

/// Leaderboard provider
final leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>,
    LeaderboardType>((ref, type) async {
  final userRepository = sl<IUserRepository>();

  final result = await userRepository.getLeaderboard(type: type);
  return result.fold(
    (failure) => [],
    (entries) => entries,
  );
});

/// User rank provider
final userRankProvider = FutureProvider<int>((ref) async {
  final userRepository = sl<IUserRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return 0;

  final result = await userRepository.getUserRank(user.id);
  return result.fold(
    (failure) => 0,
    (rank) => rank,
  );
});

/// Learned countries provider
final learnedCountriesProvider = FutureProvider<List<String>>((ref) async {
  final userRepository = sl<IUserRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  final result = await userRepository.getLearnedCountries(user.id);
  return result.fold(
    (failure) => [],
    (countries) => countries,
  );
});
