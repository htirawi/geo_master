import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import 'auth_provider.dart';

/// Quiz state
sealed class QuizState {
  const QuizState();

  bool get isLoading => this is QuizLoading;
  bool get hasQuiz => this is QuizActive;
  bool get isCompleted => this is QuizCompleted;

  Quiz? get quiz {
    if (this is QuizActive) {
      return (this as QuizActive).quiz;
    }
    if (this is QuizCompleted) {
      return (this as QuizCompleted).result.quizId as Quiz?;
    }
    return null;
  }
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizActive extends QuizState {
  const QuizActive(this.quiz);

  @override
  final Quiz quiz;
}

class QuizAnswered extends QuizState {
  const QuizAnswered({
    required this.quiz,
    required this.answer,
    required this.isCorrect,
  });

  @override
  final Quiz quiz;
  final QuizAnswer answer;
  final bool isCorrect;
}

class QuizCompleted extends QuizState {
  const QuizCompleted(this.result);

  final QuizResult result;
}

class QuizError extends QuizState {
  const QuizError(this.failure);

  final Failure failure;
}

/// Quiz state notifier
class QuizStateNotifier extends StateNotifier<AsyncValue<QuizState>> {
  QuizStateNotifier(this._quizRepository)
      : super(const AsyncValue.data(QuizInitial()));

  final IQuizRepository _quizRepository;
  Quiz? _currentQuiz;

  /// Generate a new quiz
  Future<void> generateQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    String? region,
    int questionCount = 10,
  }) async {
    state = const AsyncValue.loading();

    final result = await _quizRepository.generateQuiz(
      mode: mode,
      difficulty: difficulty,
      region: region,
      questionCount: questionCount,
    );

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quiz) {
        _currentQuiz = quiz;
        state = AsyncValue.data(QuizActive(quiz));
      },
    );
  }

  /// Submit an answer
  Future<void> submitAnswer({
    required String answer,
    required Duration timeTaken,
  }) async {
    if (_currentQuiz == null) return;

    final currentQuestion = _currentQuiz!.currentQuestion;
    if (currentQuestion == null) return;

    final result = await _quizRepository.submitAnswer(
      quizId: _currentQuiz!.id,
      questionId: currentQuestion.id,
      answer: answer,
      timeTaken: timeTaken,
    );

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quizAnswer) {
        // Update current quiz with the answer
        _currentQuiz = _currentQuiz!.copyWith(
          answers: [..._currentQuiz!.answers, quizAnswer],
          currentQuestionIndex: _currentQuiz!.currentQuestionIndex + 1,
        );

        state = AsyncValue.data(QuizAnswered(
          quiz: _currentQuiz!,
          answer: quizAnswer,
          isCorrect: quizAnswer.isCorrect,
        ));
      },
    );
  }

  /// Move to next question after showing feedback
  void nextQuestion() {
    if (_currentQuiz == null) return;

    if (_currentQuiz!.isCompleted) {
      _completeQuiz();
    } else {
      state = AsyncValue.data(QuizActive(_currentQuiz!));
    }
  }

  /// Complete the quiz
  Future<void> _completeQuiz() async {
    if (_currentQuiz == null) return;

    state = const AsyncValue.loading();

    final completedQuiz = _currentQuiz!.copyWith(
      completedAt: DateTime.now(),
    );

    final result = await _quizRepository.completeQuiz(completedQuiz);

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quizResult) {
        _currentQuiz = null;
        state = AsyncValue.data(QuizCompleted(quizResult));
      },
    );
  }

  /// Reset quiz state
  void reset() {
    _currentQuiz = null;
    state = const AsyncValue.data(QuizInitial());
  }

  /// Save current progress
  Future<void> saveProgress() async {
    if (_currentQuiz == null) return;
    await _quizRepository.saveQuizProgress(_currentQuiz!);
  }

  /// Load saved progress
  Future<void> loadSavedProgress(String userId) async {
    state = const AsyncValue.loading();

    final result = await _quizRepository.getSavedQuizProgress(userId);

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quiz) {
        if (quiz != null) {
          _currentQuiz = quiz;
          state = AsyncValue.data(QuizActive(quiz));
        } else {
          state = const AsyncValue.data(QuizInitial());
        }
      },
    );
  }
}

/// Quiz state provider
final quizStateProvider =
    StateNotifierProvider<QuizStateNotifier, AsyncValue<QuizState>>((ref) {
  final quizRepository = sl<IQuizRepository>();
  return QuizStateNotifier(quizRepository);
});

/// Current quiz provider
final currentQuizProvider = Provider<Quiz?>((ref) {
  final quizState = ref.watch(quizStateProvider);
  final state = quizState.valueOrNull;
  if (state is QuizActive) return state.quiz;
  if (state is QuizAnswered) return state.quiz;
  return null;
});

/// Quiz history provider
final quizHistoryProvider = FutureProvider<List<QuizResult>>((ref) async {
  final quizRepository = sl<IQuizRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  final result = await quizRepository.getQuizHistory(userId: user.id);
  return result.fold(
    (failure) => [],
    (history) => history,
  );
});

/// Quiz statistics provider
final quizStatisticsProvider = FutureProvider<QuizStatistics>((ref) async {
  final quizRepository = sl<IQuizRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return QuizStatistics.empty();

  final result = await quizRepository.getQuizStatistics(user.id);
  return result.fold(
    (failure) => QuizStatistics.empty(),
    (stats) => stats,
  );
});

/// Daily challenge provider
final dailyChallengeProvider = FutureProvider<Quiz?>((ref) async {
  final quizRepository = sl<IQuizRepository>();

  final result = await quizRepository.getDailyChallenge();
  return result.fold(
    (failure) => null,
    (quiz) => quiz,
  );
});

/// Is daily challenge completed provider
final isDailyChallengeCompletedProvider = FutureProvider<bool>((ref) async {
  final quizRepository = sl<IQuizRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return false;

  final result = await quizRepository.isDailyChallengeCompleted(user.id);
  return result.fold(
    (failure) => false,
    (isCompleted) => isCompleted,
  );
});
