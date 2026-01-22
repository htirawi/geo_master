import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/error/exceptions.dart';
import '../../models/quiz_model.dart';
import '../../models/user_model.dart';

/// Firestore user data source interface
abstract class IFirestoreUserDataSource {
  /// Get user by ID
  Future<UserModel?> getUserById(String userId);

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Create or update user
  Future<void> saveUser(UserModel user);

  /// Update user preferences
  Future<void> updatePreferences(String userId, UserPreferencesModel preferences);

  /// Update user progress
  Future<void> updateProgress(String userId, UserProgressModel progress);

  /// Add XP and return updated progress
  Future<UserProgressModel> addXp(String userId, int xp);

  /// Update streak and return updated progress
  Future<UserProgressModel> updateStreak(String userId);

  /// Increment countries learned
  Future<void> incrementCountriesLearned(String userId, String countryCode);

  /// Increment quizzes completed
  Future<void> incrementQuizzesCompleted(String userId);

  /// Update quiz stats
  Future<void> updateQuizStats(
    String userId, {
    required int questionsAnswered,
    required int correctAnswers,
  });

  /// Unlock achievement
  Future<void> unlockAchievement(String userId, String achievementId);

  /// Get learned countries
  Future<List<String>> getLearnedCountries(String userId);

  /// Get leaderboard
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String type = 'global',
    int limit = 100,
  });

  /// Get user rank
  Future<int> getUserRank(String userId);

  // ============================================
  // QUIZ HISTORY SYNC METHODS
  // ============================================

  /// Save quiz result to Firestore for cloud backup
  Future<void> saveQuizResult(String userId, QuizResultModel result);

  /// Get quiz history from Firestore
  Future<List<QuizResultModel>> getQuizHistory(String userId, {int limit = 50});

  /// Sync local quiz history to Firestore (for migration/restore)
  Future<void> syncQuizHistory(String userId, List<QuizResultModel> results);
}

/// Firestore user data source implementation
class FirestoreUserDataSource implements IFirestoreUserDataSource {
  FirestoreUserDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _learnedCountriesCollection(
          String userId) =>
      _usersCollection.doc(userId).collection('learned_countries');

  CollectionReference<Map<String, dynamic>> _quizHistoryCollection(
          String userId) =>
      _usersCollection.doc(userId).collection('quiz_history');

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to get user: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error getting user');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return getUserById(currentUser.uid);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(
            user.toJson()..remove('id'),
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to save user: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error saving user');
    }
  }

  @override
  Future<void> updatePreferences(
    String userId,
    UserPreferencesModel preferences,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'preferences': preferences.toJson(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          message: 'Failed to update preferences: ${e.message}');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error updating preferences');
    }
  }

  @override
  Future<void> updateProgress(
    String userId,
    UserProgressModel progress,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'progress': progress.toJson(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to update progress: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error updating progress');
    }
  }

  @override
  Future<UserProgressModel> addXp(String userId, int xp) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'User not found');
      }

      final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      var progress = user.progress;

      // Add XP
      final newTotalXp = progress.totalXp + xp;
      var newLevel = progress.level;

      // Check for level up
      while (newTotalXp >= _xpForLevel(newLevel + 1)) {
        newLevel++;
      }

      progress = UserProgressModel(
        totalXp: newTotalXp,
        level: newLevel,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        lastActiveDate: DateTime.now(),
        countriesLearned: progress.countriesLearned,
        quizzesCompleted: progress.quizzesCompleted,
        questionsAnswered: progress.questionsAnswered,
        correctAnswers: progress.correctAnswers,
        unlockedAchievements: progress.unlockedAchievements,
        regionProgress: progress.regionProgress,
      );

      await updateProgress(userId, progress);
      return progress;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to add XP: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error adding XP');
    }
  }

  @override
  Future<UserProgressModel> updateStreak(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'User not found');
      }

      final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      var progress = user.progress;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      var newStreak = progress.currentStreak;
      var longestStreak = progress.longestStreak;

      if (progress.lastActiveDate != null) {
        final lastActive = DateTime(
          progress.lastActiveDate!.year,
          progress.lastActiveDate!.month,
          progress.lastActiveDate!.day,
        );

        final difference = today.difference(lastActive).inDays;

        if (difference == 0) {
          // Already active today, no change
        } else if (difference == 1) {
          // Consecutive day, increment streak
          newStreak++;
        } else {
          // Streak broken, reset to 1
          newStreak = 1;
        }
      } else {
        // First activity
        newStreak = 1;
      }

      if (newStreak > longestStreak) {
        longestStreak = newStreak;
      }

      progress = UserProgressModel(
        totalXp: progress.totalXp,
        level: progress.level,
        currentStreak: newStreak,
        longestStreak: longestStreak,
        lastActiveDate: now,
        countriesLearned: progress.countriesLearned,
        quizzesCompleted: progress.quizzesCompleted,
        questionsAnswered: progress.questionsAnswered,
        correctAnswers: progress.correctAnswers,
        unlockedAchievements: progress.unlockedAchievements,
        regionProgress: progress.regionProgress,
      );

      await updateProgress(userId, progress);
      return progress;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to update streak: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error updating streak');
    }
  }

  @override
  Future<void> incrementCountriesLearned(
    String userId,
    String countryCode,
  ) async {
    try {
      // Check if already learned
      final learnedDoc =
          await _learnedCountriesCollection(userId).doc(countryCode).get();

      if (!learnedDoc.exists) {
        // Add to learned countries
        await _learnedCountriesCollection(userId).doc(countryCode).set({
          'learnedAt': FieldValue.serverTimestamp(),
        });

        // Increment count
        await _usersCollection.doc(userId).update({
          'progress.countriesLearned': FieldValue.increment(1),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to increment countries learned: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error incrementing countries learned',
      );
    }
  }

  @override
  Future<void> incrementQuizzesCompleted(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'progress.quizzesCompleted': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to increment quizzes completed: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error incrementing quizzes completed',
      );
    }
  }

  @override
  Future<void> updateQuizStats(
    String userId, {
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'progress.questionsAnswered': FieldValue.increment(questionsAnswered),
        'progress.correctAnswers': FieldValue.increment(correctAnswers),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update quiz stats: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating quiz stats',
      );
    }
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await _usersCollection.doc(userId).update({
        'progress.unlockedAchievements': FieldValue.arrayUnion([achievementId]),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to unlock achievement: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error unlocking achievement',
      );
    }
  }

  @override
  Future<List<String>> getLearnedCountries(String userId) async {
    try {
      final snapshot = await _learnedCountriesCollection(userId).get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get learned countries: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting learned countries',
      );
    }
  }

  @override
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String type = 'global',
    int limit = 100,
  }) async {
    try {
      final query = _usersCollection
          .orderBy('progress.totalXp', descending: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        final data = doc.data();

        return LeaderboardEntryModel(
          userId: doc.id,
          displayName: data['displayName'] as String? ?? 'Anonymous',
          photoUrl: data['photoUrl'] as String?,
          totalXp: (data['progress']?['totalXp'] as num?)?.toInt() ?? 0,
          level: (data['progress']?['level'] as num?)?.toInt() ?? 1,
          rank: index + 1,
          countriesLearned:
              (data['progress']?['countriesLearned'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get leaderboard: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting leaderboard',
      );
    }
  }

  @override
  Future<int> getUserRank(String userId) async {
    try {
      // Get the user's XP
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        throw const ServerException(message: 'User not found');
      }

      final userXp =
          (userDoc.data()!['progress']?['totalXp'] as num?)?.toInt() ?? 0;

      // Count users with higher XP
      final higherXpCount = await _usersCollection
          .where('progress.totalXp', isGreaterThan: userXp)
          .count()
          .get();

      return (higherXpCount.count ?? 0) + 1;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to get user rank: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error getting user rank');
    }
  }

  // ============================================
  // QUIZ HISTORY SYNC IMPLEMENTATION
  // ============================================

  @override
  Future<void> saveQuizResult(String userId, QuizResultModel result) async {
    try {
      // Use the result ID as the document ID for deduplication
      await _quizHistoryCollection(userId).doc(result.id).set(
            result.toJson()..remove('userId'), // userId is in the path
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to save quiz result: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error saving quiz result',
      );
    }
  }

  @override
  Future<List<QuizResultModel>> getQuizHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _quizHistoryCollection(userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add back userId since we removed it when saving
        return QuizResultModel.fromJson({
          ...data,
          'id': doc.id,
          'userId': userId,
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get quiz history: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting quiz history',
      );
    }
  }

  @override
  Future<void> syncQuizHistory(
    String userId,
    List<QuizResultModel> results,
  ) async {
    try {
      // Use batched writes for efficiency (max 500 operations per batch)
      final batches = <WriteBatch>[];
      var currentBatch = _firestore.batch();
      var operationCount = 0;

      for (final result in results) {
        final docRef = _quizHistoryCollection(userId).doc(result.id);
        currentBatch.set(
          docRef,
          result.toJson()..remove('userId'),
          SetOptions(merge: true),
        );
        operationCount++;

        // Firestore batch limit is 500 operations
        if (operationCount >= 500) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
      }

      // Add the last batch if it has any operations
      if (operationCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches
      for (final batch in batches) {
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to sync quiz history: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error syncing quiz history',
      );
    }
  }

  /// Calculate total XP required to reach a specific level
  int _xpForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += (100 * _pow(1.2, i)).round();
    }
    return total;
  }

  /// Simple power function to avoid dart:math import issues
  double _pow(double base, int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

/// Leaderboard entry model
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.totalXp,
    required this.level,
    required this.rank,
    required this.countriesLearned,
  });

  final String userId;
  final String displayName;
  final String? photoUrl;
  final int totalXp;
  final int level;
  final int rank;
  final int countriesLearned;
}
