import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/services/logger_service.dart';
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

/// Local quiz data source implementation using Hive with encryption
class QuizLocalDataSource implements IQuizLocalDataSource {
  QuizLocalDataSource({
    required HiveInterface hive,
    FlutterSecureStorage? secureStorage,
  })  : _hive = hive,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final HiveInterface _hive;
  final FlutterSecureStorage _secureStorage;

  static const String _progressBoxName = 'quiz_progress_secure';
  static const String _historyBoxName = 'quiz_history_secure';
  static const String _dailyChallengeBoxName = 'daily_challenge_secure';
  static const String _encryptionKeyName = 'quiz_box_encryption_key';

  HiveCipher? _cipher;

  /// Get or create the encryption cipher for Hive boxes
  /// Anti-cheat: Uses secure storage to protect encryption key
  Future<HiveCipher> _getOrCreateCipher() async {
    if (_cipher != null) return _cipher!;

    try {
      // Try to read existing key from secure storage
      var keyString = await _secureStorage.read(key: _encryptionKeyName);

      Uint8List encryptionKey;
      if (keyString != null) {
        // Decode existing key
        encryptionKey = base64Decode(keyString);
      } else {
        // Generate new random key (32 bytes for AES-256)
        encryptionKey = Uint8List.fromList(Hive.generateSecureKey());
        keyString = base64Encode(encryptionKey);
        // Store in secure storage
        await _secureStorage.write(key: _encryptionKeyName, value: keyString);
        logger.debug(
          'Generated new quiz encryption key',
          tag: 'QuizLocalDS',
        );
      }

      _cipher = HiveAesCipher(encryptionKey);
      return _cipher!;
    } catch (e) {
      logger.warning(
        'Failed to create encryption cipher, using unencrypted storage',
        tag: 'QuizLocalDS',
      );
      // Fallback: return a dummy cipher that doesn't encrypt
      // This should only happen in rare cases (secure storage unavailable)
      rethrow;
    }
  }

  Future<Box<String>> get _progressBox async {
    if (!_hive.isBoxOpen(_progressBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _progressBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage for user data
        logger.error(
          'SECURITY: Failed to open encrypted progress box - refusing unencrypted storage',
          tag: 'QuizLocalDS',
        );
        throw CacheException(
          message: 'Unable to securely store quiz progress. Please restart the app.',
        );
      }
    }
    return _hive.box<String>(_progressBoxName);
  }

  Future<Box<String>> get _historyBox async {
    if (!_hive.isBoxOpen(_historyBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _historyBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage for user data
        logger.error(
          'SECURITY: Failed to open encrypted history box - refusing unencrypted storage',
          tag: 'QuizLocalDS',
        );
        throw CacheException(
          message: 'Unable to securely store quiz history. Please restart the app.',
        );
      }
    }
    return _hive.box<String>(_historyBoxName);
  }

  Future<Box<String>> get _dailyChallengeBox async {
    if (!_hive.isBoxOpen(_dailyChallengeBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _dailyChallengeBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage for user data
        logger.error(
          'SECURITY: Failed to open encrypted daily challenge box - refusing unencrypted storage',
          tag: 'QuizLocalDS',
        );
        throw CacheException(
          message: 'Unable to securely store daily challenges. Please restart the app.',
        );
      }
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
      throw CacheException(message: 'Failed to save quiz progress');
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
      throw CacheException(message: 'Failed to get quiz progress');
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
      throw CacheException(message: 'Failed to clear quiz progress');
    }
  }

  @override
  Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      final box = await _historyBox;
      final key = 'result_${result.userId}_${result.completedAt.millisecondsSinceEpoch}';
      await box.put(key, jsonEncode(result.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save quiz result');
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
          try {
            results.add(
              QuizResultModel.fromJson(jsonDecode(data) as Map<String, dynamic>),
            );
          } catch (parseError) {
            // Skip corrupted entries but preserve valid ones
            logger.warning(
              'Skipping corrupted quiz result: $key',
              tag: 'QuizLocalDS',
              error: parseError,
            );
            // Remove corrupted entry
            await box.delete(key);
          }
        }
      }

      // Sort by completion date (most recent first) and limit
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return results.take(limit).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get quiz history');
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
        message: 'Failed to save daily challenge completion',
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
        message: 'Failed to check daily challenge status',
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
      throw CacheException(message: 'Failed to clear quiz cache');
    }
  }

  String _getDailyChallengeKey(String userId, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'daily_${userId}_$dateStr';
  }
}
