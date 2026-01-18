import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';
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
}

/// Chat local data source implementation using Hive and SharedPreferences
class ChatLocalDataSource implements IChatLocalDataSource {
  ChatLocalDataSource({
    required HiveInterface hive,
    required SharedPreferences sharedPreferences,
  })  : _hive = hive,
        _sharedPreferences = sharedPreferences;

  final HiveInterface _hive;
  final SharedPreferences _sharedPreferences;

  static const String _chatBoxName = 'chat_history';
  static const String _messageCountPrefix = 'ai_messages_';
  static const String _messageCountDatePrefix = 'ai_messages_date_';
  static const int _maxMessagesPerConversation = 100;

  Future<Box<String>> get _chatBox async {
    if (!_hive.isBoxOpen(_chatBoxName)) {
      return await _hive.openBox<String>(_chatBoxName);
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
      throw CacheException(message: 'Failed to save chat message: $e');
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

      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get chat history: $e');
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      final box = await _chatBox;
      final key = 'chat_$userId';
      await box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to clear chat history: $e');
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
      throw CacheException(message: 'Failed to get message count: $e');
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
      throw CacheException(message: 'Failed to increment message count: $e');
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
      throw CacheException(message: 'Failed to reset message count: $e');
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
      throw CacheException(message: 'Failed to clear chat cache: $e');
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
