import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/chat_message.dart';

/// AI Tutor repository interface
abstract class IAiTutorRepository {
  /// Send a message to the AI tutor and get streaming response
  Future<Either<Failure, Stream<String>>> sendMessage({
    required String userId,
    required String message,
    required TutorContext context,
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
}
