import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../../models/bookmark_model.dart';

/// Bookmarks local data source interface
abstract class IBookmarksLocalDataSource {
  /// Save a bookmark
  Future<void> saveBookmark(String userId, BookmarkModel bookmark);

  /// Get all bookmarks for user
  Future<List<BookmarkModel>> getBookmarks(String userId);

  /// Delete a bookmark
  Future<void> deleteBookmark(String userId, String bookmarkId);

  /// Check if a message is bookmarked
  Future<bool> isMessageBookmarked(String userId, String messageId);

  /// Get bookmark by message ID
  Future<BookmarkModel?> getBookmarkByMessageId(String userId, String messageId);

  /// Update bookmark (e.g., add note or tags)
  Future<void> updateBookmark(String userId, BookmarkModel bookmark);

  /// Search bookmarks by content
  Future<List<BookmarkModel>> searchBookmarks(String userId, String query);

  /// Get bookmarks by tag
  Future<List<BookmarkModel>> getBookmarksByTag(String userId, String tag);

  /// Clear all bookmarks
  Future<void> clearBookmarks(String userId);
}

/// Bookmarks local data source implementation using Hive with encryption
class BookmarksLocalDataSource implements IBookmarksLocalDataSource {
  BookmarksLocalDataSource({
    required HiveInterface hive,
    FlutterSecureStorage? secureStorage,
  })  : _hive = hive,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final HiveInterface _hive;
  final FlutterSecureStorage _secureStorage;

  static const String _bookmarksBoxName = 'bookmarks_secure';
  static const String _encryptionKeyName = 'bookmarks_encryption_key';
  static const int _maxBookmarks = 500;

  HiveCipher? _cipher;

  /// Get or create the encryption cipher for Hive boxes
  Future<HiveCipher> _getOrCreateCipher() async {
    if (_cipher != null) return _cipher!;

    try {
      var keyString = await _secureStorage.read(key: _encryptionKeyName);

      Uint8List encryptionKey;
      if (keyString != null) {
        encryptionKey = base64Decode(keyString);
      } else {
        encryptionKey = Uint8List.fromList(Hive.generateSecureKey());
        keyString = base64Encode(encryptionKey);
        await _secureStorage.write(key: _encryptionKeyName, value: keyString);
        logger.debug(
          'Generated new bookmarks encryption key',
          tag: 'BookmarksLocalDS',
        );
      }

      _cipher = HiveAesCipher(encryptionKey);
      return _cipher!;
    } catch (e) {
      logger.warning(
        'Failed to create encryption cipher, using unencrypted storage',
        tag: 'BookmarksLocalDS',
      );
      rethrow;
    }
  }

  Future<Box<String>> get _bookmarksBox async {
    if (!_hive.isBoxOpen(_bookmarksBoxName)) {
      try {
        final cipher = await _getOrCreateCipher();
        return await _hive.openBox<String>(
          _bookmarksBoxName,
          encryptionCipher: cipher,
        );
      } catch (e) {
        // Security: Do NOT fall back to unencrypted storage for sensitive data
        logger.error(
          'SECURITY: Failed to open encrypted bookmarks box - refusing unencrypted storage',
          tag: 'BookmarksLocalDS',
        );
        throw CacheException(
          message: 'Unable to securely store bookmarks. Please restart the app.',
        );
      }
    }
    return _hive.box<String>(_bookmarksBoxName);
  }

  @override
  Future<void> saveBookmark(String userId, BookmarkModel bookmark) async {
    try {
      final box = await _bookmarksBox;
      final key = 'bookmarks_$userId';

      final bookmarks = await _getBookmarksList(box, key);

      // Check if already bookmarked
      final existingIndex = bookmarks.indexWhere(
        (b) => b.messageId == bookmark.messageId,
      );
      if (existingIndex != -1) {
        return; // Already bookmarked
      }

      bookmarks.insert(0, bookmark);

      // Limit bookmarks
      if (bookmarks.length > _maxBookmarks) {
        bookmarks.removeRange(_maxBookmarks, bookmarks.length);
      }

      await box.put(key, jsonEncode(bookmarks.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException(message: 'Failed to save bookmark');
    }
  }

  @override
  Future<List<BookmarkModel>> getBookmarks(String userId) async {
    try {
      final box = await _bookmarksBox;
      final key = 'bookmarks_$userId';
      return _getBookmarksList(box, key);
    } catch (e) {
      throw CacheException(message: 'Failed to get bookmarks');
    }
  }

  @override
  Future<void> deleteBookmark(String userId, String bookmarkId) async {
    try {
      final box = await _bookmarksBox;
      final key = 'bookmarks_$userId';

      final bookmarks = await _getBookmarksList(box, key);
      bookmarks.removeWhere((b) => b.id == bookmarkId);

      await box.put(key, jsonEncode(bookmarks.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException(message: 'Failed to delete bookmark');
    }
  }

  @override
  Future<bool> isMessageBookmarked(String userId, String messageId) async {
    try {
      final bookmarks = await getBookmarks(userId);
      return bookmarks.any((b) => b.messageId == messageId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<BookmarkModel?> getBookmarkByMessageId(
    String userId,
    String messageId,
  ) async {
    try {
      final bookmarks = await getBookmarks(userId);
      final index = bookmarks.indexWhere((b) => b.messageId == messageId);
      if (index != -1) {
        return bookmarks[index];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateBookmark(String userId, BookmarkModel bookmark) async {
    try {
      final box = await _bookmarksBox;
      final key = 'bookmarks_$userId';

      final bookmarks = await _getBookmarksList(box, key);
      final index = bookmarks.indexWhere((b) => b.id == bookmark.id);

      if (index != -1) {
        bookmarks[index] = bookmark;
        await box.put(
          key,
          jsonEncode(bookmarks.map((b) => b.toJson()).toList()),
        );
      }
    } catch (e) {
      throw CacheException(message: 'Failed to update bookmark');
    }
  }

  @override
  Future<List<BookmarkModel>> searchBookmarks(
    String userId,
    String query,
  ) async {
    try {
      final bookmarks = await getBookmarks(userId);
      final lowerQuery = query.toLowerCase();
      return bookmarks.where((b) {
        return b.content.toLowerCase().contains(lowerQuery) ||
            (b.note?.toLowerCase().contains(lowerQuery) ?? false) ||
            b.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to search bookmarks');
    }
  }

  @override
  Future<List<BookmarkModel>> getBookmarksByTag(
    String userId,
    String tag,
  ) async {
    try {
      final bookmarks = await getBookmarks(userId);
      return bookmarks.where((b) => b.tags.contains(tag)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get bookmarks by tag');
    }
  }

  @override
  Future<void> clearBookmarks(String userId) async {
    try {
      final box = await _bookmarksBox;
      final key = 'bookmarks_$userId';
      await box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to clear bookmarks');
    }
  }

  Future<List<BookmarkModel>> _getBookmarksList(
    Box<String> box,
    String key,
  ) async {
    final data = box.get(key);
    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((m) => BookmarkModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}
