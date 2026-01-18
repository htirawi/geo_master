import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/error/exceptions.dart';
import '../../models/quiz_model.dart';

/// Local quiz data source interface
abstract class IQuizLocalDataSource {
  /// Save quiz progress
  Future<void> saveQuizProgress(QuizModel quiz);

  /// Get saved quiz progress
  Future<QuizModel?> getSavedQuizProgress(String oderId);

  /// Clear saved quiz progress
  Future<void> clearSavedQuizProgress(String userId);

  /// Save quiz result
  Future<void> saveQuizResult(QuizResultModel result);

  /// Get quiz history
  Future<List<QuizResultModel>> getQuizHistory(String userId, {int limit = 50});

  /// Save daily challenge completion
  Future<void> saveDailyChallengeCompletion(String oderId, DateTime date);

  /// Check if daily challenge is completed
  Future<bool> isDailyChallengeCompleted(String userId, DateTime date);

  /// Clear all quiz cache
  Future<void> clearCache();
}

/// Local quiz data source implementation using Hive
class QuizLocalDataSource implements IQuizLocalDataSource {
  QuizLocalDataSource({required HiveInterface hive}) : _hive = hive;

  final HiveInterface _hive;

  static const String _progressBoxName = 'quiz_progress';
  static const String _historyBoxName = 'quiz_history';
  static const String _dailyChallengeBoxName = 'daily_challenge';

  Future<Box<String>> get _progressBox async {
    if (!_hive.isBoxOpen(_progressBoxName)) {
      return await _hive.openBox<String>(_progressBoxName);
    }
    return _hive.box<String>(_progressBoxName);
  }

  Future<Box<String>> get _historyBox async {
    if (!_hive.isBoxOpen(_historyBoxName)) {
      return await _hive.openBox<String>(_historyBoxName);
    }
    return _hive.box<String>(_historyBoxName);
  }

  Future<Box<String>> get _dailyChallengeBox async {
    if (!_hive.isBoxOpen(_dailyChallengeBoxName)) {
      return await _hive.openBox<String>(_dailyChallengeBoxName);
    }
    return _hive.box<String>(_dailyChallengeBoxName);
  }

  @override
  Future<void> saveQuizProgress(QuizModel quiz) async {
    try {
      final box = await _progressBox;
      final key = 'progress_${quiz.id}';
      await box.put(key, jsonEncode(quiz.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save quiz progress: $e');
    }
  }

  @override
  Future<QuizModel?> getSavedQuizProgress(String userId) async {
    try {
      final box = await _progressBox;
      // Find the most recent progress for this user
      final keys = box.keys.where((k) => k.toString().startsWith('progress_'));
      if (keys.isEmpty) return null;

      // Get the most recent quiz progress
      for (final key in keys) {
        final data = box.get(key);
        if (data != null) {
          final quiz =
              QuizModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
          // Return the first incomplete quiz found
          if (quiz.completedAt == null) {
            return quiz;
          }
        }
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get quiz progress: $e');
    }
  }

  @override
  Future<void> clearSavedQuizProgress(String userId) async {
    try {
      final box = await _progressBox;
      final keysToDelete = box.keys
          .where((k) => k.toString().startsWith('progress_'))
          .toList();
      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear quiz progress: $e');
    }
  }

  @override
  Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      final box = await _historyBox;
      final key = 'result_${result.userId}_${result.completedAt.millisecondsSinceEpoch}';
      await box.put(key, jsonEncode(result.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save quiz result: $e');
    }
  }

  @override
  Future<List<QuizResultModel>> getQuizHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final box = await _historyBox;
      final results = <QuizResultModel>[];

      // Get all results for this user
      final keys = box.keys
          .where((k) => k.toString().startsWith('result_$userId'))
          .toList();

      for (final key in keys) {
        final data = box.get(key);
        if (data != null) {
          results.add(
            QuizResultModel.fromJson(jsonDecode(data) as Map<String, dynamic>),
          );
        }
      }

      // Sort by completion date (most recent first) and limit
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return results.take(limit).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get quiz history: $e');
    }
  }

  @override
  Future<void> saveDailyChallengeCompletion(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = await _dailyChallengeBox;
      final key = _getDailyChallengeKey(userId, date);
      await box.put(key, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(
        message: 'Failed to save daily challenge completion: $e',
      );
    }
  }

  @override
  Future<bool> isDailyChallengeCompleted(String userId, DateTime date) async {
    try {
      final box = await _dailyChallengeBox;
      final key = _getDailyChallengeKey(userId, date);
      return box.containsKey(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check daily challenge status: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final progressBox = await _progressBox;
      final historyBox = await _historyBox;
      final dailyChallengeBox = await _dailyChallengeBox;

      await progressBox.clear();
      await historyBox.clear();
      await dailyChallengeBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear quiz cache: $e');
    }
  }

  String _getDailyChallengeKey(String userId, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'daily_${userId}_$dateStr';
  }
}
