import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/i_ai_tutor_repository.dart';
import 'auth_provider.dart';
import 'country_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// AI Tutor chat state
sealed class AiTutorState {
  const AiTutorState();

  bool get isLoading => this is AiTutorLoading;
  bool get isStreaming => this is AiTutorStreaming;
  bool get hasMessages => messages.isNotEmpty;

  List<ChatMessage> get messages {
    if (this is AiTutorLoaded) {
      return (this as AiTutorLoaded).messages;
    }
    if (this is AiTutorStreaming) {
      return (this as AiTutorStreaming).messages;
    }
    return [];
  }
}

class AiTutorInitial extends AiTutorState {
  const AiTutorInitial();
}

class AiTutorLoading extends AiTutorState {
  const AiTutorLoading();
}

class AiTutorLoaded extends AiTutorState {
  const AiTutorLoaded({
    required this.messages,
    required this.remainingMessages,
    required this.suggestedPrompts,
  });

  @override
  final List<ChatMessage> messages;
  final int remainingMessages;
  final List<SuggestedPrompt> suggestedPrompts;
}

class AiTutorStreaming extends AiTutorState {
  const AiTutorStreaming({
    required this.messages,
    required this.streamingMessageId,
  });

  @override
  final List<ChatMessage> messages;
  final String streamingMessageId;
}

class AiTutorError extends AiTutorState {
  const AiTutorError(this.failure);

  final Failure failure;
}

/// AI Tutor state notifier
class AiTutorNotifier extends StateNotifier<AsyncValue<AiTutorState>> {
  AiTutorNotifier(this._aiTutorRepository)
      : super(const AsyncValue.data(AiTutorInitial()));

  final IAiTutorRepository _aiTutorRepository;
  StreamSubscription<String>? _streamSubscription;
  List<ChatMessage> _messages = [];
  int _remainingMessages = 0;
  List<SuggestedPrompt> _suggestedPrompts = [];

  /// Initialize chat - load history and suggested prompts
  Future<void> initialize(String userId) async {
    state = const AsyncValue.loading();

    // Load chat history
    final historyResult = await _aiTutorRepository.getChatHistory(userId);
    historyResult.fold(
      (failure) {},
      (history) => _messages = history,
    );

    // Get remaining messages
    final remainingResult = await _aiTutorRepository.getRemainingMessages(userId);
    remainingResult.fold(
      (failure) {},
      (remaining) => _remainingMessages = remaining,
    );

    // Get suggested prompts
    final promptsResult = await _aiTutorRepository.getSuggestedPrompts();
    promptsResult.fold(
      (failure) {},
      (prompts) => _suggestedPrompts = prompts,
    );

    state = AsyncValue.data(AiTutorLoaded(
      messages: _messages,
      remainingMessages: _remainingMessages,
      suggestedPrompts: _suggestedPrompts,
    ));
  }

  /// Send a message to the AI tutor
  Future<void> sendMessage({
    required String userId,
    required String message,
    required TutorContext context,
  }) async {
    // Check if can send message
    final canSendResult = await _aiTutorRepository.canSendMessage(userId);
    final canSend = canSendResult.fold(
      (failure) => false,
      (can) => can,
    );

    if (!canSend) {
      state = AsyncValue.data(AiTutorError(AiTutorFailure.messageLimitReached()));
      return;
    }

    // Add user message immediately
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: message,
      role: MessageRole.user,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, userMessage];

    // Create streaming assistant message placeholder
    final assistantMessageId = _uuid.v4();
    final assistantMessage = ChatMessage(
      id: assistantMessageId,
      content: '',
      role: MessageRole.assistant,
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    _messages = [..._messages, assistantMessage];

    state = AsyncValue.data(AiTutorStreaming(
      messages: _messages,
      streamingMessageId: assistantMessageId,
    ));

    // Send message and stream response
    final result = await _aiTutorRepository.sendMessage(
      userId: userId,
      message: message,
      context: context,
    );

    result.fold(
      (failure) {
        // Remove the streaming message on error
        _messages = _messages.where((m) => m.id != assistantMessageId).toList();
        state = AsyncValue.data(AiTutorError(failure));
      },
      (stream) {
        final contentBuffer = StringBuffer();

        _streamSubscription?.cancel();
        _streamSubscription = stream.listen(
          (chunk) {
            contentBuffer.write(chunk);

            // Update the streaming message
            _messages = _messages.map((m) {
              if (m.id == assistantMessageId) {
                return m.copyWith(content: contentBuffer.toString());
              }
              return m;
            }).toList();

            state = AsyncValue.data(AiTutorStreaming(
              messages: _messages,
              streamingMessageId: assistantMessageId,
            ));
          },
          onDone: () {
            // Mark message as no longer streaming
            _messages = _messages.map((m) {
              if (m.id == assistantMessageId) {
                return m.copyWith(isStreaming: false);
              }
              return m;
            }).toList();

            _remainingMessages = (_remainingMessages - 1).clamp(0, 1000);

            state = AsyncValue.data(AiTutorLoaded(
              messages: _messages,
              remainingMessages: _remainingMessages,
              suggestedPrompts: _suggestedPrompts,
            ));
          },
          onError: (Object error) {
            // Remove the streaming message on error
            _messages =
                _messages.where((m) => m.id != assistantMessageId).toList();
            state = AsyncValue.data(
              AiTutorError(AiTutorFailure(message: error.toString())),
            );
          },
        );
      },
    );
  }

  /// Clear chat history
  Future<void> clearHistory(String userId) async {
    state = const AsyncValue.loading();

    final result = await _aiTutorRepository.clearChatHistory(userId);

    result.fold(
      (failure) => state = AsyncValue.data(AiTutorError(failure)),
      (_) {
        _messages = [];
        state = AsyncValue.data(AiTutorLoaded(
          messages: _messages,
          remainingMessages: _remainingMessages,
          suggestedPrompts: _suggestedPrompts,
        ));
      },
    );
  }

  /// Update suggested prompts based on context
  Future<void> updateSuggestedPrompts({
    String? currentCountryCode,
    List<String>? recentTopics,
  }) async {
    final result = await _aiTutorRepository.getSuggestedPrompts(
      currentCountryCode: currentCountryCode,
      recentTopics: recentTopics,
    );

    result.fold(
      (failure) {},
      (prompts) {
        _suggestedPrompts = prompts;
        if (state.valueOrNull is AiTutorLoaded) {
          state = AsyncValue.data(AiTutorLoaded(
            messages: _messages,
            remainingMessages: _remainingMessages,
            suggestedPrompts: _suggestedPrompts,
          ));
        }
      },
    );
  }

  /// Reset state
  void reset() {
    _streamSubscription?.cancel();
    _messages = [];
    _remainingMessages = 0;
    _suggestedPrompts = [];
    state = const AsyncValue.data(AiTutorInitial());
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

/// AI Tutor state provider
final aiTutorProvider =
    StateNotifierProvider<AiTutorNotifier, AsyncValue<AiTutorState>>((ref) {
  final aiTutorRepository = sl<IAiTutorRepository>();
  final notifier = AiTutorNotifier(aiTutorRepository);

  // Auto-initialize when user is authenticated
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    notifier.initialize(user.id);
  } else {
    notifier.reset();
  }

  return notifier;
});

/// Chat messages provider (convenience)
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final aiTutorState = ref.watch(aiTutorProvider);
  return aiTutorState.valueOrNull?.messages ?? [];
});

/// Is streaming provider
final isStreamingProvider = Provider<bool>((ref) {
  final aiTutorState = ref.watch(aiTutorProvider);
  return aiTutorState.valueOrNull?.isStreaming ?? false;
});

/// Remaining messages provider
final remainingMessagesProvider = Provider<int>((ref) {
  final aiTutorState = ref.watch(aiTutorProvider);
  final state = aiTutorState.valueOrNull;
  if (state is AiTutorLoaded) {
    return state.remainingMessages;
  }
  return 0;
});

/// Suggested prompts provider
final suggestedPromptsProvider = Provider<List<SuggestedPrompt>>((ref) {
  final aiTutorState = ref.watch(aiTutorProvider);
  final state = aiTutorState.valueOrNull;
  if (state is AiTutorLoaded) {
    return state.suggestedPrompts;
  }
  return SuggestedPrompt.defaults;
});

/// Current tutor context provider
final tutorContextProvider = Provider<TutorContext>((ref) {
  final selectedCountry = ref.watch(selectedCountryProvider);
  final userProgress = ref.watch(userProgressProvider);
  final userPreferences = ref.watch(userPreferencesProvider);

  return TutorContext(
    currentCountryCode: selectedCountry?.code,
    currentCountryName: selectedCountry?.name,
    recentQuizTopics: const [], // Could be populated from quiz history
    userLevel: userProgress.level,
    userInterests: userPreferences.interests,
    preferredLanguage: userPreferences.language,
  );
});

/// Can send message provider
final canSendMessageProvider = FutureProvider<bool>((ref) async {
  final aiTutorRepository = sl<IAiTutorRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return false;

  final result = await aiTutorRepository.canSendMessage(user.id);
  return result.fold(
    (failure) => false,
    (canSend) => canSend,
  );
});
