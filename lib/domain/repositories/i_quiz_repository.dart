import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/quiz.dart';

/// Quiz repository interface
abstract class IQuizRepository {
  /// Generate a new quiz
  Future<Either<Failure, Quiz>> generateQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    String? region,
    int questionCount = 10,
  });

  /// Submit an answer
  Future<Either<Failure, QuizAnswer>> submitAnswer({
    required String quizId,
    required String questionId,
    required String answer,
    required Duration timeTaken,
  });

  /// Complete quiz and save result
  Future<Either<Failure, QuizResult>> completeQuiz(Quiz quiz, {String? userId});

  /// Sync local quiz history to cloud (for restore after reinstall)
  Future<Either<Failure, void>> syncQuizHistoryToCloud(String userId);

  /// Restore quiz history from cloud
  Future<Either<Failure, List<QuizResult>>> restoreQuizHistoryFromCloud(
    String userId, {
    int limit = 50,
  });

  /// Get quiz history for user
  Future<Either<Failure, List<QuizResult>>> getQuizHistory({
    required String userId,
    int limit = 50,
  });

  /// Get quiz statistics for user
  Future<Either<Failure, QuizStatistics>> getQuizStatistics(String userId);

  /// Get daily challenge
  Future<Either<Failure, Quiz>> getDailyChallenge();

  /// Check if daily challenge is completed
  Future<Either<Failure, bool>> isDailyChallengeCompleted(String userId);

  /// Save quiz progress (for resuming later)
  Future<Either<Failure, void>> saveQuizProgress(Quiz quiz);

  /// Get saved quiz progress
  Future<Either<Failure, Quiz?>> getSavedQuizProgress(String userId);

  /// Clear saved quiz progress
  Future<Either<Failure, void>> clearSavedQuizProgress(String userId);
}

/// Quiz statistics
class QuizStatistics {
  const QuizStatistics({
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.averageAccuracy,
    required this.totalTimePlayed,
    required this.perfectScores,
    required this.quizzesByMode,
    required this.quizzesByDifficulty,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory QuizStatistics.empty() => const QuizStatistics(
        totalQuizzes: 0,
        totalQuestions: 0,
        correctAnswers: 0,
        averageAccuracy: 0,
        totalTimePlayed: Duration.zero,
        perfectScores: 0,
        quizzesByMode: {},
        quizzesByDifficulty: {},
        currentStreak: 0,
        bestStreak: 0,
      );

  final int totalQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  final double averageAccuracy;
  final Duration totalTimePlayed;
  final int perfectScores;
  final Map<QuizMode, int> quizzesByMode;
  final Map<QuizDifficulty, int> quizzesByDifficulty;
  final int currentStreak;
  final int bestStreak;
}
