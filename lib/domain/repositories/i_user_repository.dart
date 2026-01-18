import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

/// User repository interface
abstract class IUserRepository {
  /// Get user by ID
  Future<Either<Failure, User>> getUserById(String userId);

  /// Get current user's data from Firestore
  Future<Either<Failure, User>> getCurrentUserData();

  /// Create or update user in Firestore
  Future<Either<Failure, void>> saveUser(User user);

  /// Update user preferences
  Future<Either<Failure, void>> updatePreferences(
    String userId,
    UserPreferences preferences,
  );

  /// Update user progress
  Future<Either<Failure, void>> updateProgress(
    String userId,
    UserProgress progress,
  );

  /// Add XP to user
  Future<Either<Failure, UserProgress>> addXp(String userId, int xp);

  /// Update streak
  Future<Either<Failure, UserProgress>> updateStreak(String userId);

  /// Increment countries learned
  Future<Either<Failure, void>> incrementCountriesLearned(
    String userId,
    String countryCode,
  );

  /// Increment quizzes completed
  Future<Either<Failure, void>> incrementQuizzesCompleted(String userId);

  /// Update quiz stats
  Future<Either<Failure, void>> updateQuizStats(
    String userId, {
    required int questionsAnswered,
    required int correctAnswers,
  });

  /// Unlock achievement
  Future<Either<Failure, void>> unlockAchievement(
    String userId,
    String achievementId,
  );

  /// Get user's learned countries
  Future<Either<Failure, List<String>>> getLearnedCountries(String userId);

  /// Check and unlock achievements based on progress
  Future<Either<Failure, List<String>>> checkAndUnlockAchievements(
    String userId,
  );

  /// Get leaderboard
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    LeaderboardType type = LeaderboardType.global,
    int limit = 100,
  });

  /// Get user's rank
  Future<Either<Failure, int>> getUserRank(String userId);
}

/// Leaderboard entry
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.oduserId,
    required this.displayName,
    this.photoUrl,
    required this.totalXp,
    required this.level,
    required this.rank,
    required this.countriesLearned,
  });

  final String oduserId;
  final String displayName;
  final String? photoUrl;
  final int totalXp;
  final int level;
  final int rank;
  final int countriesLearned;
}

/// Leaderboard type
enum LeaderboardType {
  global,
  friends,
  weekly,
  regional,
}
