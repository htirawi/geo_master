import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/firestore_user_datasource.dart';
import '../models/user_model.dart';

/// User repository implementation
class UserRepositoryImpl implements IUserRepository {
  UserRepositoryImpl({
    required IFirestoreUserDataSource firestoreDataSource,
  }) : _firestoreDataSource = firestoreDataSource;

  final IFirestoreUserDataSource _firestoreDataSource;

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      final userModel = await _firestoreDataSource.getUserById(userId);
      if (userModel == null) {
        return const Left(ServerFailure(message: 'User not found'));
      }
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      logger.error('Error getting user', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting user',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to get user'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUserData() async {
    try {
      final userModel = await _firestoreDataSource.getCurrentUser();
      if (userModel == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      logger.error('Error getting current user', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting current user',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      await _firestoreDataSource.saveUser(UserModel.fromEntity(user));
      logger.debug('User saved: ${user.id}', tag: 'UserRepo');
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error saving user', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error saving user',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to save user'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      await _firestoreDataSource.updatePreferences(
        userId,
        UserPreferencesModel.fromEntity(preferences),
      );
      logger.debug('Preferences updated for: $userId', tag: 'UserRepo');
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error updating preferences', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error updating preferences',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to update preferences'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProgress(
    String userId,
    UserProgress progress,
  ) async {
    try {
      await _firestoreDataSource.updateProgress(
        userId,
        UserProgressModel.fromEntity(progress),
      );
      logger.debug('Progress updated for: $userId', tag: 'UserRepo');
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error updating progress', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error updating progress',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to update progress'));
    }
  }

  @override
  Future<Either<Failure, UserProgress>> addXp(String userId, int xp) async {
    try {
      final progressModel = await _firestoreDataSource.addXp(userId, xp);
      logger.info('Added $xp XP to user: $userId', tag: 'UserRepo');
      return Right(progressModel.toEntity());
    } on ServerException catch (e) {
      logger.error('Error adding XP', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error adding XP',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to add XP'));
    }
  }

  @override
  Future<Either<Failure, UserProgress>> updateStreak(String userId) async {
    try {
      final progressModel = await _firestoreDataSource.updateStreak(userId);
      logger.debug('Streak updated for: $userId', tag: 'UserRepo');
      return Right(progressModel.toEntity());
    } on ServerException catch (e) {
      logger.error('Error updating streak', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error updating streak',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to update streak'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementCountriesLearned(
    String userId,
    String countryCode,
  ) async {
    try {
      await _firestoreDataSource.incrementCountriesLearned(userId, countryCode);
      logger.debug(
        'Countries learned incremented for: $userId',
        tag: 'UserRepo',
      );
      return const Right(null);
    } on ServerException catch (e) {
      logger.error(
        'Error incrementing countries learned',
        tag: 'UserRepo',
        error: e,
      );
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error incrementing countries learned',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(
        ServerFailure(message: 'Failed to increment countries learned'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> incrementQuizzesCompleted(String userId) async {
    try {
      await _firestoreDataSource.incrementQuizzesCompleted(userId);
      logger.debug(
        'Quizzes completed incremented for: $userId',
        tag: 'UserRepo',
      );
      return const Right(null);
    } on ServerException catch (e) {
      logger.error(
        'Error incrementing quizzes completed',
        tag: 'UserRepo',
        error: e,
      );
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error incrementing quizzes completed',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(
        ServerFailure(message: 'Failed to increment quizzes completed'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateQuizStats(
    String userId, {
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    try {
      await _firestoreDataSource.updateQuizStats(
        userId,
        questionsAnswered: questionsAnswered,
        correctAnswers: correctAnswers,
      );
      logger.debug('Quiz stats updated for: $userId', tag: 'UserRepo');
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error updating quiz stats', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error updating quiz stats',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to update quiz stats'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockAchievement(
    String userId,
    String achievementId,
  ) async {
    try {
      await _firestoreDataSource.unlockAchievement(userId, achievementId);
      logger.info(
        'Achievement unlocked: $achievementId for user: $userId',
        tag: 'UserRepo',
      );
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error unlocking achievement', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error unlocking achievement',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to unlock achievement'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLearnedCountries(
    String userId,
  ) async {
    try {
      final countries = await _firestoreDataSource.getLearnedCountries(userId);
      return Right(countries);
    } on ServerException catch (e) {
      logger.error('Error getting learned countries', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting learned countries',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(
        ServerFailure(message: 'Failed to get learned countries'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> checkAndUnlockAchievements(
    String userId,
  ) async {
    // Security: Achievement validation is performed using progress data
    // fetched from Firestore (server-side source of truth), not client-side
    // values. This prevents achievement manipulation by modifying local data.
    // For additional security, consider implementing achievement validation
    // in Firebase Cloud Functions to ensure server-side verification.
    try {
      // Get current user progress from Firestore (server-side validation)
      final userResult = await getUserById(userId);

      return userResult.fold(
        Left.new,
        (user) async {
          final progress = user.progress;
          final unlockedAchievements = <String>[];

          // Check each achievement
          for (final achievement in Achievements.all) {
            if (progress.unlockedAchievements.contains(achievement.id)) {
              continue; // Already unlocked
            }

            var shouldUnlock = false;

            switch (achievement.category) {
              case AchievementCategory.learning:
                // Countries learned achievements
                if (achievement.id.startsWith('countries_')) {
                  shouldUnlock =
                      progress.countriesLearned >= achievement.requiredValue;
                } else if (achievement.id == 'first_country') {
                  shouldUnlock = progress.countriesLearned >= 1;
                }
                break;

              case AchievementCategory.quiz:
                // Quiz achievements
                if (achievement.id == 'first_quiz') {
                  shouldUnlock = progress.quizzesCompleted >= 1;
                } else if (achievement.id.startsWith('quizzes_')) {
                  shouldUnlock =
                      progress.quizzesCompleted >= achievement.requiredValue;
                }
                // Note: perfect_quiz needs special handling from quiz completion
                break;

              case AchievementCategory.streak:
                // Streak achievements
                if (achievement.id.startsWith('streak_')) {
                  shouldUnlock =
                      progress.currentStreak >= achievement.requiredValue ||
                          progress.longestStreak >= achievement.requiredValue;
                }
                break;

              case AchievementCategory.exploration:
                // Region-specific achievements
                final regionProgress = progress.regionProgress;
                if (achievement.id == 'africa_complete') {
                  shouldUnlock = (regionProgress['Africa'] ?? 0) >=
                      achievement.requiredValue;
                } else if (achievement.id == 'europe_complete') {
                  shouldUnlock = (regionProgress['Europe'] ?? 0) >=
                      achievement.requiredValue;
                } else if (achievement.id == 'asia_complete') {
                  shouldUnlock =
                      (regionProgress['Asia'] ?? 0) >= achievement.requiredValue;
                }
                break;

              case AchievementCategory.social:
              case AchievementCategory.special:
                // These require special handling
                break;
            }

            if (shouldUnlock) {
              await unlockAchievement(userId, achievement.id);
              unlockedAchievements.add(achievement.id);

              // Award XP for achievement
              await addXp(userId, achievement.xpReward);
            }
          }

          return Right(unlockedAchievements);
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        'Error checking achievements',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to check achievements'));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    LeaderboardType type = LeaderboardType.global,
    int limit = 100,
  }) async {
    try {
      final entries = await _firestoreDataSource.getLeaderboard(
        type: type.name,
        limit: limit,
      );

      return Right(
        entries
            .map((e) => LeaderboardEntry(
                  oduserId: e.userId,
                  displayName: e.displayName,
                  photoUrl: e.photoUrl,
                  totalXp: e.totalXp,
                  level: e.level,
                  rank: e.rank,
                  countriesLearned: e.countriesLearned,
                ))
            .toList(),
      );
    } on ServerException catch (e) {
      logger.error('Error getting leaderboard', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting leaderboard',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to get leaderboard'));
    }
  }

  @override
  Future<Either<Failure, int>> getUserRank(String userId) async {
    try {
      final rank = await _firestoreDataSource.getUserRank(userId);
      return Right(rank);
    } on ServerException catch (e) {
      logger.error('Error getting user rank', tag: 'UserRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting user rank',
        tag: 'UserRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(ServerFailure(message: 'Failed to get user rank'));
    }
  }
}
