import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../../models/chat_message_model.dart';

/// Chat local data source interface
abstract class IChatLocalDataSource {
  /// Save chat message
  Future<void> saveMessage(String userId, ChatMessageModel message);

  /// Get chat history for user
  Future<List<ChatMessageModel>> getChatHistory(String userId);

  /// Clear chat history for user
  Future<void> clearChatHistory(String userId);

  /// Get messages sent today count
  Future<int> getMessagesSentToday(String userId);

  /// Increment messages sent today
  Future<void> incrementMessagesSentToday(String userId);

  /// Reset daily message count (called at midnight)
  Future<void> resetDailyMessageCount(String userId);

  /// Clear all chat cache
  Future<void> clearCache();

  // Reaction methods

  /// Add reaction to a message
  Future<void> addReaction(String userId, String messageId, String emoji);

  /// Remove reaction from a message
  Future<void> removeReaction(String userId, String messageId, String emoji);

  /// Get reactions for a message
  Future<List<String>> getReactions(String userId, String messageId);

  /// Clear all reactions for a user
  Future<void> clearReactions(String userId);
}

/// Chat local data source implementation using Hive with encryption
/// Security: Chat history is encrypted to protect user privacy
class ChatLocalDataSource implements IChatLocalDataSource {
  ChatLocalDataSource({
    required HiveInterface hive,
    required SharedPreferences sharedPreferences,
    FlutterSecureStorage? secureStorage,
  })  : _hive = hive,
        _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final HiveInterface _hive;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  static const String _chatBoxName = 'chat_history_secure';
  static const String _messageCountPrefix = 'ai_messages_';
  static const String _messageCountDatePrefix = 'ai_messages_date_';
  static const String _encryptionKeyName = 'chat_box_encryption_key';
  static const int _maxMessagesPerConversation = 100;

  HiveCipher? _cipher;

  /// Get or create the encryption cipher for Hive boxes
  /// Security: Uses secure storage to protect encryption key
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
          'Generated new chat encryption key',
          tag: 'ChatLocalDS',
        );
      }

      _cipher = HiveAesCipher(encryptionKey);
      return _cipher!;
    } catch (e) {
      logger.warning(
        'Failed to create encryption cipher, using unencrypted storage',
        tag: 'ChatLocalDS',
      );
      rethrow;
    }
  }

  Future<Box<String>> get _chatBox async {
    if (!_hive.isBoxOpen(_chatBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _chatBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage for sensitive data
        // Log critical error and rethrow to prevent data exposure
        logger.error(
          'SECURITY: Failed to open encrypted chat box - refusing to store data unencrypted',
          tag: 'ChatLocalDS',
        );
        throw const CacheException(
          message: 'Unable to securely store chat data. Please restart the app.',
        );
      }
    }
    return _hive.box<String>(_chatBoxName);
  }

  @override
  Future<void> saveMessage(String userId, ChatMessageModel message) async {
    try {
      final box = await _chatBox;
      final key = 'chat_$userId';

      // Get existing messages
      final existingData = box.get(key);
      final messages = <Map<String, dynamic>>[];

      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List<dynamic>;
        messages.addAll(decoded.cast<Map<String, dynamic>>());
      }

      // Add new message
      messages.add(message.toJson());

      // Keep only the last N messages
      if (messages.length > _maxMessagesPerConversation) {
        messages.removeRange(0, messages.length - _maxMessagesPerConversation);
      }

      await box.put(key, jsonEncode(messages));
    } catch (e) {
      throw const CacheException(message: 'Failed to save chat message');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(String userId) async {
    try {
      final box = await _chatBox;
      final key = 'chat_$userId';
      final data = box.get(key);

      if (data == null) {
        return [];
      }

      // Parse with error recovery for data integrity
      try {
        final decoded = jsonDecode(data) as List<dynamic>;
        final messages = <ChatMessageModel>[];

        for (final item in decoded) {
          try {
            messages.add(ChatMessageModel.fromJson(item as Map<String, dynamic>));
          } catch (parseError) {
            // Skip corrupted individual messages but preserve valid ones
            logger.warning(
              'Skipping corrupted chat message during parsing',
              tag: 'ChatLocalDS',
              error: parseError,
            );
          }
        }

        return messages;
      } on FormatException catch (e) {
        // JSON is completely corrupted - clear and start fresh
        logger.error(
          'Chat history JSON corrupted, clearing data',
          tag: 'ChatLocalDS',
          error: e,
        );
        await box.delete(key);
        return [];
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw const CacheException(message: 'Failed to get chat history');
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      final box = await _chatBox;
      final key = 'chat_$userId';
      await box.delete(key);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear chat history');
    }
  }

  @override
  Future<int> getMessagesSentToday(String userId) async {
    try {
      // Check if we need to reset (new day)
      final today = _getTodayString();
      final storedDate = _sharedPreferences.getString(
        '$_messageCountDatePrefix$userId',
      );

      if (storedDate != today) {
        // Reset count for new day
        await resetDailyMessageCount(userId);
        return 0;
      }

      return _sharedPreferences.getInt('$_messageCountPrefix$userId') ?? 0;
    } catch (e) {
      throw const CacheException(message: 'Failed to get message count');
    }
  }

  @override
  Future<void> incrementMessagesSentToday(String userId) async {
    try {
      final today = _getTodayString();
      final currentCount = await getMessagesSentToday(userId);

      await _sharedPreferences.setInt(
        '$_messageCountPrefix$userId',
        currentCount + 1,
      );
      await _sharedPreferences.setString(
        '$_messageCountDatePrefix$userId',
        today,
      );
    } catch (e) {
      throw const CacheException(message: 'Failed to increment message count');
    }
  }

  @override
  Future<void> resetDailyMessageCount(String userId) async {
    try {
      final today = _getTodayString();
      await _sharedPreferences.setInt('$_messageCountPrefix$userId', 0);
      await _sharedPreferences.setString(
        '$_messageCountDatePrefix$userId',
        today,
      );
    } catch (e) {
      throw const CacheException(message: 'Failed to reset message count');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await _chatBox;
      await box.clear();

      // Clear all message counts
      final keys = _sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_messageCountPrefix) ||
            key.startsWith(_messageCountDatePrefix)) {
          await _sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw const CacheException(message: 'Failed to clear chat cache');
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Reaction methods

  static const String _reactionsBoxName = 'reactions_secure';

  Future<Box<String>> get _reactionsBox async {
    if (!_hive.isBoxOpen(_reactionsBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _reactionsBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage
        logger.error(
          'SECURITY: Failed to open encrypted reactions box - refusing unencrypted storage',
          tag: 'ChatLocalDS',
        );
        throw const CacheException(
          message: 'Unable to securely store reactions. Please restart the app.',
        );
      }
    }
    return _hive.box<String>(_reactionsBoxName);
  }

  @override
  Future<void> addReaction(
    String userId,
    String messageId,
    String emoji,
  ) async {
    try {
      final box = await _reactionsBox;
      final key = 'reactions_${userId}_$messageId';

      final existingData = box.get(key);
      final reactions = <String>[];

      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List<dynamic>;
        reactions.addAll(decoded.cast<String>());
      }

      if (!reactions.contains(emoji)) {
        reactions.add(emoji);
        await box.put(key, jsonEncode(reactions));
      }
    } catch (e) {
      throw const CacheException(message: 'Failed to add reaction');
    }
  }

  @override
  Future<void> removeReaction(
    String userId,
    String messageId,
    String emoji,
  ) async {
    try {
      final box = await _reactionsBox;
      final key = 'reactions_${userId}_$messageId';

      final existingData = box.get(key);
      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List<dynamic>;
        final reactions = decoded.cast<String>().where((e) => e != emoji).toList();
        await box.put(key, jsonEncode(reactions));
      }
    } catch (e) {
      throw const CacheException(message: 'Failed to remove reaction');
    }
  }

  @override
  Future<List<String>> getReactions(String userId, String messageId) async {
    try {
      final box = await _reactionsBox;
      final key = 'reactions_${userId}_$messageId';

      final existingData = box.get(key);
      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List<dynamic>;
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearReactions(String userId) async {
    try {
      final box = await _reactionsBox;
      final keysToDelete = box.keys
          .where((key) => key.toString().startsWith('reactions_$userId'))
          .toList();

      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      throw const CacheException(message: 'Failed to clear reactions');
    }
  }
}
