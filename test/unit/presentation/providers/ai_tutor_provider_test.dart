import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:geo_master/core/error/failures.dart';
import 'package:geo_master/domain/entities/chat_message.dart';
import 'package:geo_master/domain/entities/user.dart';
import 'package:geo_master/presentation/providers/ai_tutor_provider.dart';
import 'package:geo_master/presentation/providers/auth_provider.dart';

import '../../../helpers/test_helpers.dart';

// Register fallback values for mocktail
class FakeTutorContext extends Fake implements TutorContext {}

void main() {
  late MockAiTutorRepository mockAiTutorRepository;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late StreamController<User?> authStreamController;

  setUpAll(() {
    registerFallbackValue(FakeTutorContext());
  });

  setUp(() {
    mockAiTutorRepository = MockAiTutorRepository();
    mockAuthRepository = MockAuthRepository();
    authStreamController = StreamController<User?>.broadcast();
  });

  tearDown(() {
    container.dispose();
    authStreamController.close();
  });

  User createTestUser() {
    return User(
      id: TestData.testUserId,
      email: TestData.testEmail,
      displayName: TestData.testDisplayName,
      createdAt: DateTime.now(),
    );
  }

  ChatMessage createTestMessage({
    required String id,
    required String content,
    required MessageRole role,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  group('AiTutorNotifier', () {
    group('initialize', () {
      test('loads chat history on initialization', () async {
        // Arrange
        final testUser = createTestUser();
        final messages = [
          createTestMessage(
            id: 'msg-1',
            content: 'Hello',
            role: MessageRole.user,
          ),
          createTestMessage(
            id: 'msg-2',
            content: 'Hi! How can I help?',
            role: MessageRole.assistant,
          ),
        ];

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockAiTutorRepository.getChatHistory(any()))
            .thenAnswer((_) async => Right(messages));
        when(() => mockAiTutorRepository.getRemainingMessages(any()))
            .thenAnswer((_) async => const Right(10));
        when(() => mockAiTutorRepository.getSuggestedPrompts(
              currentCountryCode: any(named: 'currentCountryCode'),
              recentTopics: any(named: 'recentTopics'),
            )).thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getBookmarks(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getReactions(any(), any()))
            .thenAnswer((_) async => const Right([]));

        container = createTestContainer(
          aiTutorRepo: mockAiTutorRepository,
          authRepo: mockAuthRepository,
        );

        // Act - initialize through the notifier
        await container.read(aiTutorProvider.notifier).initialize(testUser.id);

        // Assert
        verify(() => mockAiTutorRepository.getChatHistory(TestData.testUserId)).called(1);

        final state = container.read(aiTutorProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AiTutorLoaded>());

        final loadedState = state.value as AiTutorLoaded;
        expect(loadedState.messages.length, equals(2));
      });
    });

    group('sendMessage', () {
      test('successfully sends message and streams AI response', () async {
        // Arrange
        final testUser = createTestUser();
        final streamController = StreamController<String>();

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockAiTutorRepository.getChatHistory(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getRemainingMessages(any()))
            .thenAnswer((_) async => const Right(10));
        when(() => mockAiTutorRepository.getSuggestedPrompts(
              currentCountryCode: any(named: 'currentCountryCode'),
              recentTopics: any(named: 'recentTopics'),
            )).thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getBookmarks(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.canSendMessage(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockAiTutorRepository.sendMessage(
              userId: any(named: 'userId'),
              message: any(named: 'message'),
              context: any(named: 'context'),
            )).thenAnswer((_) async => Right(streamController.stream));

        container = createTestContainer(
          aiTutorRepo: mockAiTutorRepository,
          authRepo: mockAuthRepository,
        );

        // Initialize first
        await container.read(aiTutorProvider.notifier).initialize(testUser.id);

        // Act
        final context = TutorContext(userLevel: 1);
        await container.read(aiTutorProvider.notifier).sendMessage(
              userId: testUser.id,
              message: 'Hello!',
              context: context,
            );

        // Simulate streaming response
        streamController.add('Hello! ');
        streamController.add('I can help you learn about geography.');
        await streamController.close();

        // Allow stream to process
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        verify(() => mockAiTutorRepository.sendMessage(
              userId: TestData.testUserId,
              message: 'Hello!',
              context: any(named: 'context'),
            )).called(1);

        final state = container.read(aiTutorProvider);
        expect(state.hasValue, isTrue);
      });

      test('handles error when sending message fails', () async {
        // Arrange
        final testUser = createTestUser();

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockAiTutorRepository.getChatHistory(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getRemainingMessages(any()))
            .thenAnswer((_) async => const Right(10));
        when(() => mockAiTutorRepository.getSuggestedPrompts(
              currentCountryCode: any(named: 'currentCountryCode'),
              recentTopics: any(named: 'recentTopics'),
            )).thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getBookmarks(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.canSendMessage(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockAiTutorRepository.sendMessage(
              userId: any(named: 'userId'),
              message: any(named: 'message'),
              context: any(named: 'context'),
            )).thenAnswer((_) async => const Left(ServerFailure(message: 'AI service unavailable')));

        container = createTestContainer(
          aiTutorRepo: mockAiTutorRepository,
          authRepo: mockAuthRepository,
        );

        // Initialize first
        await container.read(aiTutorProvider.notifier).initialize(testUser.id);

        // Act
        final context = TutorContext(userLevel: 1);
        await container.read(aiTutorProvider.notifier).sendMessage(
              userId: testUser.id,
              message: 'Hello!',
              context: context,
            );

        // Assert
        final state = container.read(aiTutorProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AiTutorError>());
      });
    });

    group('clearHistory', () {
      test('clears chat history successfully', () async {
        // Arrange
        final testUser = createTestUser();

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockAiTutorRepository.getChatHistory(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getRemainingMessages(any()))
            .thenAnswer((_) async => const Right(10));
        when(() => mockAiTutorRepository.getSuggestedPrompts(
              currentCountryCode: any(named: 'currentCountryCode'),
              recentTopics: any(named: 'recentTopics'),
            )).thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.getBookmarks(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockAiTutorRepository.clearChatHistory(any()))
            .thenAnswer((_) async => const Right(null));

        container = createTestContainer(
          aiTutorRepo: mockAiTutorRepository,
          authRepo: mockAuthRepository,
        );

        // Initialize first
        await container.read(aiTutorProvider.notifier).initialize(testUser.id);

        // Act
        await container.read(aiTutorProvider.notifier).clearHistory(testUser.id);

        // Assert
        verify(() => mockAiTutorRepository.clearChatHistory(TestData.testUserId)).called(1);

        final state = container.read(aiTutorProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AiTutorLoaded>());
        expect((state.value as AiTutorLoaded).messages, isEmpty);
      });
    });
  });

  group('canSendMessageProvider', () {
    test('returns true when user can send messages', () async {
      // Arrange
      final testUser = createTestUser();

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockAiTutorRepository.canSendMessage(TestData.testUserId))
          .thenAnswer((_) async => const Right(true));
      when(() => mockAiTutorRepository.getChatHistory(any()))
          .thenAnswer((_) async => const Right([]));
      when(() => mockAiTutorRepository.getRemainingMessages(any()))
          .thenAnswer((_) async => const Right(10));
      when(() => mockAiTutorRepository.getSuggestedPrompts(
            currentCountryCode: any(named: 'currentCountryCode'),
            recentTopics: any(named: 'recentTopics'),
          )).thenAnswer((_) async => const Right([]));
      when(() => mockAiTutorRepository.getBookmarks(any()))
          .thenAnswer((_) async => const Right([]));

      container = createTestContainer(
        aiTutorRepo: mockAiTutorRepository,
        authRepo: mockAuthRepository,
      );

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Simulate authenticated user
      authStreamController.add(testUser);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Act
      final canSend = await container.read(canSendMessageProvider.future);

      // Assert
      expect(canSend, isTrue);
    });

    test('returns false when user has reached message limit', () async {
      // Arrange
      final testUser = createTestUser();

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockAiTutorRepository.canSendMessage(TestData.testUserId))
          .thenAnswer((_) async => const Right(false));
      when(() => mockAiTutorRepository.getChatHistory(any()))
          .thenAnswer((_) async => const Right([]));
      when(() => mockAiTutorRepository.getRemainingMessages(any()))
          .thenAnswer((_) async => const Right(0));
      when(() => mockAiTutorRepository.getSuggestedPrompts(
            currentCountryCode: any(named: 'currentCountryCode'),
            recentTopics: any(named: 'recentTopics'),
          )).thenAnswer((_) async => const Right([]));
      when(() => mockAiTutorRepository.getBookmarks(any()))
          .thenAnswer((_) async => const Right([]));

      container = createTestContainer(
        aiTutorRepo: mockAiTutorRepository,
        authRepo: mockAuthRepository,
      );

      // Simulate authenticated user
      authStreamController.add(testUser);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Act
      final canSend = await container.read(canSendMessageProvider.future);

      // Assert
      expect(canSend, isFalse);
    });

    test('returns false when user is not authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        aiTutorRepo: mockAiTutorRepository,
        authRepo: mockAuthRepository,
      );

      // Simulate unauthenticated state
      authStreamController.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Act
      final canSend = await container.read(canSendMessageProvider.future);

      // Assert
      expect(canSend, isFalse);
    });
  });
}
