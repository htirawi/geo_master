import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/bookmark.dart';
import '../entities/chat_message.dart';

/// AI Tutor repository interface
abstract class IAiTutorRepository {
  /// Send a message to the AI tutor and get streaming response
  Future<Either<Failure, Stream<String>>> sendMessage({
    required String userId,
    required String message,
    required TutorContext context,
  });

  /// Send a message with image for vision analysis
  Future<Either<Failure, Stream<String>>> sendMessageWithImage({
    required String userId,
    required String message,
    required TutorContext context,
    required Uint8List imageData,
    required String mimeType,
  });

  /// Get chat history for user
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String userId);

  /// Clear chat history
  Future<Either<Failure, void>> clearChatHistory(String userId);

  /// Get remaining AI messages for today (rate limiting)
  Future<Either<Failure, int>> getRemainingMessages(String userId);

  /// Check if user can send messages
  Future<Either<Failure, bool>> canSendMessage(String userId);

  /// Save message to history
  Future<Either<Failure, void>> saveMessage(
    String userId,
    ChatMessage message,
  );

  /// Get suggested prompts based on context
  Future<Either<Failure, List<SuggestedPrompt>>> getSuggestedPrompts({
    String? currentCountryCode,
    List<String>? recentTopics,
  });

  // Bookmark methods

  /// Save a bookmark
  Future<Either<Failure, void>> saveBookmark(String userId, Bookmark bookmark);

  /// Get all bookmarks for user
  Future<Either<Failure, List<Bookmark>>> getBookmarks(String userId);

  /// Delete a bookmark
  Future<Either<Failure, void>> deleteBookmark(String userId, String bookmarkId);

  /// Check if a message is bookmarked
  Future<Either<Failure, bool>> isMessageBookmarked(
    String userId,
    String messageId,
  );

  /// Toggle bookmark for a message
  Future<Either<Failure, bool>> toggleBookmark(
    String userId,
    ChatMessage message,
  );

  /// Search bookmarks
  Future<Either<Failure, List<Bookmark>>> searchBookmarks(
    String userId,
    String query,
  );

  // Reaction methods

  /// Add reaction to a message
  Future<Either<Failure, void>> addReaction(
    String userId,
    String messageId,
    String emoji,
  );

  /// Remove reaction from a message
  Future<Either<Failure, void>> removeReaction(
    String userId,
    String messageId,
    String emoji,
  );

  /// Get reactions for a message
  Future<Either<Failure, List<String>>> getReactions(
    String userId,
    String messageId,
  );
}
