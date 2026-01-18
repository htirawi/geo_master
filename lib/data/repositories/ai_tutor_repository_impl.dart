import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/i_ai_tutor_repository.dart';
import '../datasources/local/chat_local_datasource.dart';
import '../datasources/remote/claude_api_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/subscription_model.dart';

/// AI Tutor repository implementation
class AiTutorRepositoryImpl implements IAiTutorRepository {
  AiTutorRepositoryImpl({
    required IClaudeApiDataSource claudeDataSource,
    required IChatLocalDataSource chatLocalDataSource,
    required SubscriptionTier Function() getCurrentTier,
  })  : _claudeDataSource = claudeDataSource,
        _chatLocalDataSource = chatLocalDataSource,
        _getCurrentTier = getCurrentTier;

  final IClaudeApiDataSource _claudeDataSource;
  final IChatLocalDataSource _chatLocalDataSource;
  final SubscriptionTier Function() _getCurrentTier;
  final _uuid = const Uuid();

  /// Free tier daily message limit
  static const int _freeTierDailyLimit = 5;

  /// Pro tier daily message limit (essentially unlimited)
  static const int _proTierDailyLimit = 100;

  /// Premium tier has unlimited messages
  static const int _premiumTierDailyLimit = 1000;

  @override
  Future<Either<Failure, Stream<String>>> sendMessage({
    required String userId,
    required String message,
    required TutorContext context,
  }) async {
    try {
      // Check if user can send messages
      final canSendResult = await canSendMessage(userId);
      final canSend = canSendResult.fold(
        (failure) => false,
        (can) => can,
      );

      if (!canSend) {
        return Left(AiTutorFailure.messageLimitReached());
      }

      // Get conversation history
      final history = await _chatLocalDataSource.getChatHistory(userId);
      final contextModel = TutorContextModel.fromEntity(context);

      // Save user message
      final userMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: message,
        role: MessageRole.user,
        createdAt: DateTime.now(),
      );
      await _chatLocalDataSource.saveMessage(userId, userMessage);

      // Increment message count
      await _chatLocalDataSource.incrementMessagesSentToday(userId);

      // Create stream controller for response
      final controller = StreamController<String>();

      // Start streaming response in background
      _streamResponse(
        userId: userId,
        message: message,
        context: contextModel,
        history: history,
        controller: controller,
      );

      logger.debug('Sending message to AI tutor', tag: 'AiTutorRepo');
      return Right(controller.stream);
    } on CacheException catch (e) {
      logger.error('Cache error sending message', tag: 'AiTutorRepo', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Error sending message to AI tutor',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AiTutorFailure(message: 'Failed to send message: $e'));
    }
  }

  Future<void> _streamResponse({
    required String userId,
    required String message,
    required TutorContextModel context,
    required List<ChatMessageModel> history,
    required StreamController<String> controller,
  }) async {
    final responseBuffer = StringBuffer();

    try {
      final stream = _claudeDataSource.sendMessage(
        message: message,
        context: context,
        conversationHistory: history,
      );

      await for (final chunk in stream) {
        responseBuffer.write(chunk);
        controller.add(chunk);
      }

      // Save complete assistant message
      final assistantMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: responseBuffer.toString(),
        role: MessageRole.assistant,
        createdAt: DateTime.now(),
      );
      await _chatLocalDataSource.saveMessage(userId, assistantMessage);

      logger.debug('AI response completed', tag: 'AiTutorRepo');
    } catch (e) {
      logger.error('Error streaming response', tag: 'AiTutorRepo', error: e);
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
    String userId,
  ) async {
    try {
      final history = await _chatLocalDataSource.getChatHistory(userId);
      return Right(history.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      logger.error('Error getting chat history', tag: 'AiTutorRepo', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting chat history',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to get chat history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory(String userId) async {
    try {
      await _chatLocalDataSource.clearChatHistory(userId);
      logger.debug('Chat history cleared for: $userId', tag: 'AiTutorRepo');
      return const Right(null);
    } on CacheException catch (e) {
      logger.error('Error clearing chat history', tag: 'AiTutorRepo', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error clearing chat history',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to clear chat history: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRemainingMessages(String userId) async {
    try {
      final tier = _getCurrentTier();
      final limit = _getDailyLimit(tier);
      final sentToday = await _chatLocalDataSource.getMessagesSentToday(userId);
      final remaining = limit - sentToday;

      return Right(remaining < 0 ? 0 : remaining);
    } on CacheException catch (e) {
      logger.error(
        'Error getting remaining messages',
        tag: 'AiTutorRepo',
        error: e,
      );
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting remaining messages',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to get remaining messages: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canSendMessage(String userId) async {
    try {
      final tier = _getCurrentTier();

      // Premium users always can send
      if (tier == SubscriptionTier.premium) {
        return const Right(true);
      }

      final limit = _getDailyLimit(tier);
      final sentToday = await _chatLocalDataSource.getMessagesSentToday(userId);

      return Right(sentToday < limit);
    } on CacheException catch (e) {
      logger.error(
        'Error checking if can send message',
        tag: 'AiTutorRepo',
        error: e,
      );
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error checking if can send message',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to check message limit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveMessage(
    String userId,
    ChatMessage message,
  ) async {
    try {
      await _chatLocalDataSource.saveMessage(
        userId,
        ChatMessageModel.fromEntity(message),
      );
      return const Right(null);
    } on CacheException catch (e) {
      logger.error('Error saving message', tag: 'AiTutorRepo', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error saving message',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to save message: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SuggestedPrompt>>> getSuggestedPrompts({
    String? currentCountryCode,
    List<String>? recentTopics,
  }) async {
    try {
      // Build context-aware prompts
      final prompts = <SuggestedPrompt>[];

      // Always include some default prompts
      prompts.addAll(SuggestedPrompt.defaults.take(2));

      // Add country-specific prompt if exploring a country
      if (currentCountryCode != null) {
        prompts.add(const SuggestedPrompt(
          text: 'Tell me more about this country\'s culture',
          textArabic: 'أخبرني المزيد عن ثقافة هذه الدولة',
          category: 'country',
        ));
        prompts.add(const SuggestedPrompt(
          text: 'What are the must-visit places here?',
          textArabic: 'ما هي الأماكن التي يجب زيارتها هنا؟',
          category: 'travel',
        ));
      }

      // Add topic-related prompts based on recent quiz topics
      if (recentTopics != null && recentTopics.isNotEmpty) {
        if (recentTopics.contains('capitals')) {
          prompts.add(const SuggestedPrompt(
            text: 'What\'s the story behind naming capital cities?',
            textArabic: 'ما قصة تسمية العواصم؟',
            category: 'capitals',
          ));
        }
        if (recentTopics.contains('flags')) {
          prompts.add(const SuggestedPrompt(
            text: 'Why do some flags look similar?',
            textArabic: 'لماذا تبدو بعض الأعلام متشابهة؟',
            category: 'flags',
          ));
        }
        if (recentTopics.contains('population')) {
          prompts.add(const SuggestedPrompt(
            text: 'Which countries are growing fastest?',
            textArabic: 'ما هي الدول الأسرع نمواً؟',
            category: 'population',
          ));
        }
      }

      // Limit to 5 prompts
      final limitedPrompts = prompts.take(5).toList();

      return Right(limitedPrompts);
    } catch (e, stackTrace) {
      logger.error(
        'Error getting suggested prompts',
        tag: 'AiTutorRepo',
        error: e,
        stackTrace: stackTrace,
      );
      // Return defaults on error
      return Right(SuggestedPrompt.defaults);
    }
  }

  int _getDailyLimit(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return _freeTierDailyLimit;
      case SubscriptionTier.pro:
        return _proTierDailyLimit;
      case SubscriptionTier.premium:
        return _premiumTierDailyLimit;
    }
  }
}
