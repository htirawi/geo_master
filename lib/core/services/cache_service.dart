import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'logger_service.dart';

/// Centralized cache service for managing app-wide caching
class CacheService {
  CacheService({required HiveInterface hive}) : _hive = hive;

  final HiveInterface _hive;

  // Cache box names
  static const String countriesBox = 'countries_cache';
  static const String contentBox = 'country_content_cache';
  static const String progressBox = 'country_progress';
  static const String continentsBox = 'continents_cache';
  static const String mediaBox = 'media_cache';
  static const String settingsBox = 'settings_cache';

  // Default cache durations
  static const Duration shortCache = Duration(hours: 1);
  static const Duration mediumCache = Duration(days: 1);
  static const Duration longCache = Duration(days: 7);
  static const Duration permanentCache = Duration(days: 365);

  /// Open a cache box
  Future<Box<String>> _openBox(String boxName) async {
    if (!_hive.isBoxOpen(boxName)) {
      return await _hive.openBox<String>(boxName);
    }
    return _hive.box<String>(boxName);
  }

  /// Get cached data with expiration check
  Future<T?> get<T>({
    required String boxName,
    required String key,
    Duration? maxAge,
  }) async {
    try {
      final box = await _openBox(boxName);
      final data = box.get(key);
      if (data == null) return null;

      final cacheEntry = jsonDecode(data) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheEntry['timestamp'] as String);
      final cacheDuration = maxAge ?? longCache;

      if (DateTime.now().difference(timestamp) > cacheDuration) {
        await box.delete(key);
        logger.debug('Cache expired for $key', tag: 'CacheService');
        return null;
      }

      return cacheEntry['data'] as T;
    } catch (e) {
      logger.warning('Error reading cache', tag: 'CacheService', error: e);
      return null;
    }
  }

  /// Set cached data with timestamp
  Future<void> set({
    required String boxName,
    required String key,
    required dynamic data,
  }) async {
    try {
      final box = await _openBox(boxName);
      final cacheEntry = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      });
      await box.put(key, cacheEntry);
    } catch (e) {
      logger.warning('Error writing cache', tag: 'CacheService', error: e);
    }
  }

  /// Delete a specific cache entry
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await _openBox(boxName);
      await box.delete(key);
    } catch (e) {
      logger.warning('Error deleting cache', tag: 'CacheService', error: e);
    }
  }

  /// Clear a specific cache box
  Future<void> clearBox(String boxName) async {
    try {
      final box = await _openBox(boxName);
      await box.clear();
      logger.info('Cleared cache box: $boxName', tag: 'CacheService');
    } catch (e) {
      logger.warning('Error clearing cache box', tag: 'CacheService', error: e);
    }
  }

  /// Clear all caches
  Future<void> clearAll() async {
    try {
      await clearBox(countriesBox);
      await clearBox(contentBox);
      await clearBox(mediaBox);
      // Don't clear progress and settings boxes by default
      logger.info('Cleared all content caches', tag: 'CacheService');
    } catch (e) {
      logger.warning('Error clearing all caches', tag: 'CacheService', error: e);
    }
  }

  /// Clear all caches including user data
  Future<void> clearAllIncludingUserData() async {
    try {
      await clearBox(countriesBox);
      await clearBox(contentBox);
      await clearBox(progressBox);
      await clearBox(continentsBox);
      await clearBox(mediaBox);
      await clearBox(settingsBox);
      logger.info('Cleared all caches including user data', tag: 'CacheService');
    } catch (e) {
      logger.warning('Error clearing all caches', tag: 'CacheService', error: e);
    }
  }

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSize() async {
    int totalSize = 0;
    final boxNames = [
      countriesBox,
      contentBox,
      progressBox,
      continentsBox,
      mediaBox,
      settingsBox,
    ];

    for (final name in boxNames) {
      try {
        final box = await _openBox(name);
        for (final key in box.keys) {
          final value = box.get(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      } catch (e) {
        // Ignore errors for individual boxes
      }
    }

    return totalSize;
  }

  /// Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
