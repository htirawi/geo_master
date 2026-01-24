import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:geo_master/core/error/failures.dart';
import 'package:geo_master/domain/entities/quiz.dart';
import 'package:geo_master/domain/entities/user.dart';
import 'package:geo_master/domain/repositories/i_quiz_repository.dart';
import 'package:geo_master/presentation/providers/auth_provider.dart';
import 'package:geo_master/presentation/providers/quiz_provider.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockQuizRepository mockQuizRepository;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late StreamController<User?> authStreamController;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(QuizMode.capitals);
    registerFallbackValue(QuizDifficulty.medium);
    registerFallbackValue(QuizSessionType.standard);
  });

  setUp(() {
    mockQuizRepository = MockQuizRepository();
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

  Quiz createTestQuiz({
    String id = 'quiz-123',
    QuizMode mode = QuizMode.capitals,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    int questionCount = 5,
  }) {
    return Quiz(
      id: id,
      mode: mode,
      difficulty: difficulty,
      questions: List.generate(
        questionCount,
        (index) => QuizQuestion(
          id: 'q-$index',
          mode: mode,
          questionType: QuestionType.multipleChoice,
          question: 'Question $index?',
          questionArabic: 'سؤال $index؟',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
          countryCode: 'US',
        ),
      ),
      startedAt: DateTime.now(),
    );
  }

  QuizStatistics createTestStatistics() {
    return const QuizStatistics(
      totalQuizzes: 10,
      totalQuestions: 100,
      correctAnswers: 80,
      averageAccuracy: 0.8,
      totalTimePlayed: Duration(hours: 2),
      perfectScores: 2,
      quizzesByMode: {},
      quizzesByDifficulty: {},
      currentStreak: 5,
      bestStreak: 10,
    );
  }

  group('QuizSessionNotifier', () {
    group('generateQuiz', () {
      test('successfully generates a quiz', () async {
        // Arrange
        final testQuiz = createTestQuiz();
        when(() => mockQuizRepository.generateQuiz(
              mode: any(named: 'mode'),
              difficulty: any(named: 'difficulty'),
              questionCount: any(named: 'questionCount'),
              sessionType: any(named: 'sessionType'),
              region: any(named: 'region'),
              continent: any(named: 'continent'),
              currentStreak: any(named: 'currentStreak'),
            )).thenAnswer((_) async => Right(testQuiz));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          quizRepo: mockQuizRepository,
          authRepo: mockAuthRepository,
        );

        // Act
        await container.read(quizStateProvider.notifier).generateQuiz(
              mode: QuizMode.capitals,
              difficulty: QuizDifficulty.medium,
            );

        // Assert
        final state = container.read(quizStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<QuizActive>());
        expect((state.value as QuizActive).quiz.id, equals('quiz-123'));
      });

      test('sets error state when quiz generation fails', () async {
        // Arrange
        when(() => mockQuizRepository.generateQuiz(
              mode: any(named: 'mode'),
              difficulty: any(named: 'difficulty'),
              questionCount: any(named: 'questionCount'),
              sessionType: any(named: 'sessionType'),
              region: any(named: 'region'),
              continent: any(named: 'continent'),
              currentStreak: any(named: 'currentStreak'),
            )).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to generate quiz')));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          quizRepo: mockQuizRepository,
          authRepo: mockAuthRepository,
        );

        // Act
        await container.read(quizStateProvider.notifier).generateQuiz(
              mode: QuizMode.capitals,
              difficulty: QuizDifficulty.medium,
            );

        // Assert
        final state = container.read(quizStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<QuizError>());
      });
    });

    group('submitAnswer', () {
      test('records correct answer and moves to next question', () async {
        // Arrange
        final testQuiz = createTestQuiz(questionCount: 3);
        when(() => mockQuizRepository.generateQuiz(
              mode: any(named: 'mode'),
              difficulty: any(named: 'difficulty'),
              questionCount: any(named: 'questionCount'),
              sessionType: any(named: 'sessionType'),
              region: any(named: 'region'),
              continent: any(named: 'continent'),
              currentStreak: any(named: 'currentStreak'),
            )).thenAnswer((_) async => Right(testQuiz));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          quizRepo: mockQuizRepository,
          authRepo: mockAuthRepository,
        );

        await container.read(quizStateProvider.notifier).generateQuiz(
              mode: QuizMode.capitals,
              difficulty: QuizDifficulty.medium,
            );

        // Act - Answer correctly (option A is correct)
        await container.read(quizStateProvider.notifier).submitAnswer(answer: 'A');

        // Assert
        final state = container.read(quizStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<QuizAnswered>());

        final answeredState = state.value as QuizAnswered;
        expect(answeredState.isCorrect, isTrue);
      });

      test('records incorrect answer', () async {
        // Arrange
        final testQuiz = createTestQuiz(questionCount: 3);
        when(() => mockQuizRepository.generateQuiz(
              mode: any(named: 'mode'),
              difficulty: any(named: 'difficulty'),
              questionCount: any(named: 'questionCount'),
              sessionType: any(named: 'sessionType'),
              region: any(named: 'region'),
              continent: any(named: 'continent'),
              currentStreak: any(named: 'currentStreak'),
            )).thenAnswer((_) async => Right(testQuiz));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          quizRepo: mockQuizRepository,
          authRepo: mockAuthRepository,
        );

        await container.read(quizStateProvider.notifier).generateQuiz(
              mode: QuizMode.capitals,
              difficulty: QuizDifficulty.medium,
            );

        // Act - Answer incorrectly (option B, but correct is A)
        await container.read(quizStateProvider.notifier).submitAnswer(answer: 'B');

        // Assert
        final state = container.read(quizStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<QuizAnswered>());

        final answeredState = state.value as QuizAnswered;
        expect(answeredState.isCorrect, isFalse);
      });

      test('moves to next question after feedback', () async {
        // Arrange
        final testQuiz = createTestQuiz(questionCount: 3);
        when(() => mockQuizRepository.generateQuiz(
              mode: any(named: 'mode'),
              difficulty: any(named: 'difficulty'),
              questionCount: any(named: 'questionCount'),
              sessionType: any(named: 'sessionType'),
              region: any(named: 'region'),
              continent: any(named: 'continent'),
              currentStreak: any(named: 'currentStreak'),
            )).thenAnswer((_) async => Right(testQuiz));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          quizRepo: mockQuizRepository,
          authRepo: mockAuthRepository,
        );

        await container.read(quizStateProvider.notifier).generateQuiz(
              mode: QuizMode.capitals,
              difficulty: QuizDifficulty.medium,
            );

        // Submit answer
        await container.read(quizStateProvider.notifier).submitAnswer(answer: 'A');

        // Act - Move to next question
        container.read(quizStateProvider.notifier).nextQuestion();

        // Assert
        final state = container.read(quizStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<QuizActive>());

        final activeState = state.value as QuizActive;
        expect(activeState.quiz.currentQuestionIndex, equals(1));
      });
    });
  });

  group('Quiz Statistics Provider', () {
    test('returns statistics for authenticated user', () async {
      // Arrange
      final testUser = createTestUser();
      final testStats = createTestStatistics();

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockQuizRepository.getQuizStatistics(TestData.testUserId))
          .thenAnswer((_) async => Right(testStats));

      container = createTestContainer(
        quizRepo: mockQuizRepository,
        authRepo: mockAuthRepository,
      );

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Authenticate user
      authStreamController.add(testUser);
      await Future.delayed(const Duration(milliseconds: 50));

      // Act
      final statsAsync = await container.read(quizStatisticsProvider.future);

      // Assert
      expect(statsAsync.totalQuizzes, equals(10));
      expect(statsAsync.currentStreak, equals(5));
      expect(statsAsync.averageAccuracy, equals(0.8));
    });

    test('returns empty statistics when user is not authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        quizRepo: mockQuizRepository,
        authRepo: mockAuthRepository,
      );

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Unauthenticated state
      authStreamController.add(null);
      await Future.delayed(const Duration(milliseconds: 50));

      // Act
      final statsAsync = await container.read(quizStatisticsProvider.future);

      // Assert
      expect(statsAsync.totalQuizzes, equals(0));
    });
  });

  group('Daily Challenge Provider', () {
    test('returns daily challenge quiz', () async {
      // Arrange
      final dailyQuiz = createTestQuiz(id: 'daily-challenge');

      when(() => mockQuizRepository.getDailyChallenge())
          .thenAnswer((_) async => Right(dailyQuiz));
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        quizRepo: mockQuizRepository,
        authRepo: mockAuthRepository,
      );

      // Act
      final quiz = await container.read(dailyChallengeProvider.future);

      // Assert
      expect(quiz, isNotNull);
      expect(quiz!.id, equals('daily-challenge'));
    });

    test('returns null when daily challenge fails to load', () async {
      // Arrange
      when(() => mockQuizRepository.getDailyChallenge())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Not available')));
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        quizRepo: mockQuizRepository,
        authRepo: mockAuthRepository,
      );

      // Act
      final quiz = await container.read(dailyChallengeProvider.future);

      // Assert
      expect(quiz, isNull);
    });
  });

  group('reset', () {
    test('resets quiz state to initial', () async {
      // Arrange
      final testQuiz = createTestQuiz();
      when(() => mockQuizRepository.generateQuiz(
            mode: any(named: 'mode'),
            difficulty: any(named: 'difficulty'),
            questionCount: any(named: 'questionCount'),
            sessionType: any(named: 'sessionType'),
            region: any(named: 'region'),
            continent: any(named: 'continent'),
            currentStreak: any(named: 'currentStreak'),
          )).thenAnswer((_) async => Right(testQuiz));
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        quizRepo: mockQuizRepository,
        authRepo: mockAuthRepository,
      );

      // Start a quiz first
      await container.read(quizStateProvider.notifier).generateQuiz(
            mode: QuizMode.capitals,
            difficulty: QuizDifficulty.medium,
          );

      // Act
      container.read(quizStateProvider.notifier).reset();

      // Assert
      final state = container.read(quizStateProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isA<QuizInitial>());
    });
  });
}
