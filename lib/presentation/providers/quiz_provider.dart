import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/repository_providers.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import 'auth_provider.dart';

/// Quiz state - sealed class for type-safe state representation
sealed class QuizState {
  const QuizState();

  bool get isLoading => this is QuizLoading;
  bool get hasQuiz => this is QuizActive || this is QuizAnswered;
  bool get isCompleted => this is QuizCompleted;

  Quiz? get quiz {
    if (this is QuizActive) {
      return (this as QuizActive).quiz;
    }
    if (this is QuizAnswered) {
      return (this as QuizAnswered).quiz;
    }
    if (this is QuizGameOver) {
      return (this as QuizGameOver).quiz;
    }
    // QuizCompleted doesn't have a Quiz, only QuizResult
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
  const QuizActive(
    this.quiz, {
    this.timeRemaining,
    this.showHint = false,
    this.selectedAnswers = const [],
    this.questionStartTime,
  });

  @override
  final Quiz quiz;
  final int? timeRemaining; // Seconds remaining for timed modes
  final bool showHint;
  final List<String> selectedAnswers; // For multi-select questions
  final DateTime? questionStartTime; // When the current question started

  QuizActive copyWith({
    Quiz? quiz,
    int? timeRemaining,
    bool? showHint,
    List<String>? selectedAnswers,
    DateTime? questionStartTime,
  }) {
    return QuizActive(
      quiz ?? this.quiz,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      showHint: showHint ?? this.showHint,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      questionStartTime: questionStartTime ?? this.questionStartTime,
    );
  }
}

class QuizAnswered extends QuizState {
  const QuizAnswered({
    required this.quiz,
    required this.answer,
    required this.isCorrect,
    this.speedBonus = 1.0,
    this.xpEarned = 0,
  });

  @override
  final Quiz quiz;
  final QuizAnswer answer;
  final bool isCorrect;
  final double speedBonus;
  final int xpEarned;
}

class QuizCompleted extends QuizState {
  const QuizCompleted(this.result);

  final QuizResult result;
}

class QuizGameOver extends QuizState {
  const QuizGameOver({
    required this.quiz,
    required this.reason,
  });

  @override
  final Quiz quiz;
  final String reason; // "lives_depleted", "time_expired", etc.
}

class QuizError extends QuizState {
  const QuizError(this.failure);

  final Failure failure;
}

/// Quiz Session Notifier - Advanced state management for all quiz modes
///
/// SECURITY NOTES:
/// - Timing: Uses monotonic Stopwatch to prevent time manipulation via device clock
/// - Race conditions: Uses _isSubmitting lock to prevent double-submit exploits
/// - Integrity: Validates quiz state before completing to detect tampering
/// - Storage: Uses encrypted Hive boxes to protect saved progress
///
/// KNOWN LIMITATION: Correct answers are present in QuizQuestion objects for client-side
/// validation. A determined user with debugging tools could potentially inspect the state.
/// Complete mitigation would require server-side answer validation, which is not
/// implemented in this offline-capable app. The other security measures provide
/// defense-in-depth to make cheating significantly harder.
class QuizSessionNotifier extends StateNotifier<AsyncValue<QuizState>> {
  QuizSessionNotifier(this._quizRepository, this._getUserId)
      : super(const AsyncValue.data(QuizInitial()));

  final IQuizRepository _quizRepository;
  final String? Function() _getUserId;
  Quiz? _currentQuiz;
  Timer? _questionTimer;
  Timer? _blitzTimer;
  int _timeRemaining = 0;

  // Anti-cheat: Use Stopwatch for monotonic timing (can't be manipulated by changing device time)
  final Stopwatch _questionStopwatch = Stopwatch();

  // Anti-cheat: Submission lock to prevent race conditions
  bool _isSubmitting = false;

  /// Hint cost in XP
  static const int hintXpCost = 5;

  /// Generate a new quiz with the specified parameters
  Future<void> generateQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    QuizSessionType sessionType = QuizSessionType.standard,
    String? region,
    String? continent,
    int? questionCount,
  }) async {
    state = const AsyncValue.loading();

    // Get current streak for bonus calculation
    final userId = _getUserId();
    int currentStreak = 0;
    if (userId != null) {
      final statsResult = await _quizRepository.getQuizStatistics(userId);
      statsResult.fold(
        (_) {},
        (stats) => currentStreak = stats.currentStreak,
      );
    }

    final result = await _quizRepository.generateQuiz(
      mode: mode,
      difficulty: difficulty,
      region: region,
      questionCount: questionCount ?? sessionType.questionCount,
      sessionType: sessionType,
      continent: continent,
      currentStreak: currentStreak,
    );

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quiz) {
        _currentQuiz = quiz;
        // Anti-cheat: Use monotonic stopwatch instead of wall clock
        _questionStopwatch
          ..reset()
          ..start();

        // Start timer for timed modes
        if (sessionType == QuizSessionType.timedBlitz) {
          _startBlitzTimer(quiz.difficulty.timeLimitSeconds);
        }

        state = AsyncValue.data(QuizActive(
          quiz,
          timeRemaining: sessionType == QuizSessionType.timedBlitz
              ? quiz.difficulty.timeLimitSeconds
              : null,
          questionStartTime: DateTime.now(), // For display only, not timing
        ));
      },
    );
  }

  /// Start a quick quiz (5 questions, ~3 mins)
  Future<void> startQuickQuiz({
    required QuizDifficulty difficulty,
    QuizMode mode = QuizMode.mixed,
  }) async {
    await generateQuiz(
      mode: mode,
      difficulty: difficulty,
      sessionType: QuizSessionType.quickQuiz,
    );
  }

  /// Start a continent challenge
  Future<void> startContinentChallenge({
    required String continent,
    required QuizDifficulty difficulty,
  }) async {
    await generateQuiz(
      mode: QuizMode.mixed,
      difficulty: difficulty,
      sessionType: QuizSessionType.continentChallenge,
      continent: continent,
    );
  }

  /// Start timed blitz mode
  Future<void> startTimedBlitz({
    required QuizDifficulty difficulty,
    QuizMode mode = QuizMode.mixed,
  }) async {
    await generateQuiz(
      mode: mode,
      difficulty: difficulty,
      sessionType: QuizSessionType.timedBlitz,
    );
  }

  /// Start daily challenge
  Future<void> startDailyChallenge() async {
    state = const AsyncValue.loading();

    final result = await _quizRepository.getDailyChallenge();

    result.fold(
      (failure) => state = AsyncValue.data(QuizError(failure)),
      (quiz) {
        _currentQuiz = quiz.copyWith(
          sessionType: QuizSessionType.dailyChallenge,
        );
        // Anti-cheat: Use monotonic stopwatch instead of wall clock
        _questionStopwatch
          ..reset()
          ..start();
        state = AsyncValue.data(QuizActive(
          _currentQuiz!,
          questionStartTime: DateTime.now(), // For display only
        ));
      },
    );
  }

  /// Start marathon mode
  Future<void> startMarathon({
    required QuizDifficulty difficulty,
  }) async {
    await generateQuiz(
      mode: QuizMode.mixed,
      difficulty: difficulty,
      sessionType: QuizSessionType.marathon,
    );
  }

  /// Start study mode (no XP, shows answers)
  Future<void> startStudyMode({
    required QuizMode mode,
    String? continent,
  }) async {
    await generateQuiz(
      mode: mode,
      difficulty: QuizDifficulty.easy,
      sessionType: QuizSessionType.studyMode,
      continent: continent,
    );
  }

  /// Start blitz timer for timed mode
  void _startBlitzTimer(int seconds) {
    _cancelTimers();
    _timeRemaining = seconds;

    _blitzTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeRemaining--;

      if (_timeRemaining <= 0) {
        timer.cancel();
        _handleTimeExpired();
      } else {
        // Update state with new time
        final currentState = state.valueOrNull;
        if (currentState is QuizActive) {
          state = AsyncValue.data(currentState.copyWith(
            timeRemaining: _timeRemaining,
          ));
        }
      }
    });
  }

  /// Handle time expiration in blitz mode
  void _handleTimeExpired() {
    if (_currentQuiz == null) return;

    // Auto-submit wrong answer
    final currentQuestion = _currentQuiz!.currentQuestion;
    if (currentQuestion != null) {
      _submitAnswerInternal(
        answer: '', // Empty = wrong
        timeTaken: Duration(seconds: _currentQuiz!.difficulty.timeLimitSeconds),
        timedOut: true,
      );
    }
  }

  /// Use a hint (costs XP)
  void useHint() {
    if (_currentQuiz == null) return;

    final currentQuestion = _currentQuiz!.currentQuestion;
    if (currentQuestion == null || !currentQuestion.hasHint) return;

    // Update hints used count
    _currentQuiz = _currentQuiz!.copyWith(
      hintsUsed: _currentQuiz!.hintsUsed + 1,
    );

    final currentState = state.valueOrNull;
    if (currentState is QuizActive) {
      state = AsyncValue.data(currentState.copyWith(
        quiz: _currentQuiz,
        showHint: true,
      ));
    }
  }

  /// Toggle answer selection for multi-select questions
  void toggleAnswerSelection(String answer) {
    final currentState = state.valueOrNull;
    if (currentState is! QuizActive) return;

    final currentQuestion = _currentQuiz?.currentQuestion;
    if (currentQuestion == null || !currentQuestion.isMultiSelect) return;

    final selectedAnswers = List<String>.from(currentState.selectedAnswers);
    if (selectedAnswers.contains(answer)) {
      selectedAnswers.remove(answer);
    } else {
      selectedAnswers.add(answer);
    }

    state = AsyncValue.data(currentState.copyWith(
      selectedAnswers: selectedAnswers,
    ));
  }

  /// Submit multi-select answer
  Future<void> submitMultiSelectAnswer() async {
    // Anti-cheat: Prevent race condition with submission lock
    if (_isSubmitting) return;

    final currentState = state.valueOrNull;
    if (currentState is! QuizActive) return;
    if (currentState.selectedAnswers.isEmpty) return;

    final currentQuestion = _currentQuiz?.currentQuestion;
    if (currentQuestion == null) return;

    // Anti-cheat: Use monotonic stopwatch for timing
    final timeTaken = _questionStopwatch.elapsed;

    await _submitAnswerInternal(
      answer: currentState.selectedAnswers.join(','),
      timeTaken: timeTaken,
      selectedAnswers: currentState.selectedAnswers,
      correctAnswers: currentQuestion.correctAnswers,
    );
  }

  /// Submit an answer
  Future<void> submitAnswer({
    required String answer,
  }) async {
    // Anti-cheat: Prevent race condition with submission lock
    if (_isSubmitting) return;
    if (_currentQuiz == null) return;

    // Anti-cheat: Use monotonic stopwatch for timing
    final timeTaken = _questionStopwatch.elapsed;

    await _submitAnswerInternal(
      answer: answer,
      timeTaken: timeTaken,
    );
  }

  /// Internal answer submission with all parameters
  Future<void> _submitAnswerInternal({
    required String answer,
    required Duration timeTaken,
    bool timedOut = false,
    List<String>? selectedAnswers,
    List<String>? correctAnswers,
  }) async {
    // Anti-cheat: Double-check submission lock (defense in depth)
    if (_isSubmitting) return;
    if (_currentQuiz == null) return;

    // Anti-cheat: Acquire submission lock
    _isSubmitting = true;

    try {
      _cancelTimers();
      _questionStopwatch.stop();

      final currentQuestion = _currentQuiz!.currentQuestion;
      if (currentQuestion == null) return;

      // Calculate speed bonus for timed blitz
      double speedBonus = 1.0;
      if (_currentQuiz!.sessionType == QuizSessionType.timedBlitz && !timedOut) {
        final timeLimit = _currentQuiz!.difficulty.timeLimitSeconds;
        final timeTakenSecs = timeTaken.inSeconds;
        if (timeTakenSecs < timeLimit / 3) {
          speedBonus = 2.0; // Very fast
        } else if (timeTakenSecs < timeLimit / 2) {
          speedBonus = 1.5; // Fast
        } else if (timeTakenSecs < timeLimit * 2 / 3) {
          speedBonus = 1.25; // Good
        }
      }

      // Determine correctness
      // Note: Answer may be in English OR Arabic depending on the UI locale
      // We need to check against both language versions
      bool isCorrect;
      if (selectedAnswers != null && correctAnswers != null) {
        // Multi-select validation - check both English and Arabic correct answers
        final correctSet = correctAnswers.toSet();
        final arabicCorrectAnswers = currentQuestion.correctAnswersArabic;
        final arabicCorrectSet = arabicCorrectAnswers?.toSet();

        isCorrect = (selectedAnswers.toSet().containsAll(correctSet) &&
            selectedAnswers.length == correctAnswers.length) ||
            (arabicCorrectSet != null &&
             selectedAnswers.toSet().containsAll(arabicCorrectSet) &&
             selectedAnswers.length == arabicCorrectSet.length);
      } else {
        // Single answer validation - check both English and Arabic correct answer
        final correctAnswerArabic = currentQuestion.correctAnswerArabic;
        isCorrect = answer == currentQuestion.correctAnswer ||
            (correctAnswerArabic != null && answer == correctAnswerArabic);
      }

      // Calculate XP for this answer
      int answerXp = 0;
      if (_currentQuiz!.sessionType != QuizSessionType.studyMode) {
        if (isCorrect) {
          answerXp = (10 * speedBonus).round();
        }
      }

      // Check hint usage for this question
      final currentState = state.valueOrNull;
      final usedHint = currentState is QuizActive && currentState.showHint;
      if (usedHint) {
        answerXp = (answerXp * 0.5).round(); // 50% XP if hint was used
      }

      // Create the answer
      // Store correctAnswer in the same language as selectedAnswer for proper isCorrect comparison
      final storedCorrectAnswer = (currentQuestion.correctAnswerArabic != null &&
              answer == currentQuestion.correctAnswerArabic)
          ? currentQuestion.correctAnswerArabic!
          : currentQuestion.correctAnswer;

      // For multi-select, determine which language version to store
      List<String>? storedCorrectAnswers;
      if (selectedAnswers != null && currentQuestion.correctAnswersArabic != null) {
        // Check if user selected Arabic answers by comparing first answer
        final isArabicSelection = currentQuestion.correctAnswersArabic!
            .any((arabic) => selectedAnswers.contains(arabic));
        storedCorrectAnswers = isArabicSelection
            ? currentQuestion.correctAnswersArabic
            : (correctAnswers ?? currentQuestion.correctAnswers);
      } else {
        storedCorrectAnswers = correctAnswers ?? currentQuestion.correctAnswers;
      }

      final quizAnswer = QuizAnswer(
        questionId: currentQuestion.id,
        selectedAnswer: answer,
        correctAnswer: storedCorrectAnswer,
        timeTaken: timeTaken,
        answeredAt: DateTime.now(),
        selectedAnswers: selectedAnswers,
        correctAnswers: storedCorrectAnswers,
        usedHint: usedHint,
        speedBonus: speedBonus,
        xpEarned: answerXp,
      );

      // Update quiz with the answer
      int? newLives = _currentQuiz!.livesRemaining;
      if (_currentQuiz!.sessionType == QuizSessionType.marathon && !isCorrect) {
        newLives = (newLives ?? 3) - 1;
      }

      _currentQuiz = _currentQuiz!.copyWith(
        answers: [..._currentQuiz!.answers, quizAnswer],
        currentQuestionIndex: _currentQuiz!.currentQuestionIndex + 1,
        livesRemaining: newLives,
        speedBonusMultiplier: _currentQuiz!.speedBonusMultiplier * speedBonus,
      );

      // Check for game over in marathon mode
      if (_currentQuiz!.hasLost) {
        state = AsyncValue.data(QuizGameOver(
          quiz: _currentQuiz!,
          reason: 'lives_depleted',
        ));
        return;
      }

      state = AsyncValue.data(QuizAnswered(
        quiz: _currentQuiz!,
        answer: quizAnswer,
        isCorrect: isCorrect,
        speedBonus: speedBonus,
        xpEarned: answerXp,
      ));
    } finally {
      // Anti-cheat: Always release submission lock
      _isSubmitting = false;
    }
  }

  /// Move to next question after showing feedback
  void nextQuestion() {
    if (_currentQuiz == null) return;

    // Anti-cheat: Reset submission lock for new question
    _isSubmitting = false;

    if (_currentQuiz!.isCompleted) {
      _completeQuiz();
    } else {
      // Anti-cheat: Reset monotonic stopwatch for new question
      _questionStopwatch
        ..reset()
        ..start();

      // Restart timer for timed blitz
      if (_currentQuiz!.sessionType == QuizSessionType.timedBlitz) {
        _startBlitzTimer(_currentQuiz!.difficulty.timeLimitSeconds);
      }

      state = AsyncValue.data(QuizActive(
        _currentQuiz!,
        timeRemaining: _currentQuiz!.sessionType == QuizSessionType.timedBlitz
            ? _currentQuiz!.difficulty.timeLimitSeconds
            : null,
        questionStartTime: DateTime.now(), // For display only
      ));
    }
  }

  /// Skip to answer in study mode
  void showAnswer() {
    if (_currentQuiz == null) return;
    if (_currentQuiz!.sessionType != QuizSessionType.studyMode) return;

    final currentQuestion = _currentQuiz!.currentQuestion;
    if (currentQuestion == null) return;

    // In study mode, showing answer counts as a correct "view"
    final quizAnswer = QuizAnswer(
      questionId: currentQuestion.id,
      selectedAnswer: currentQuestion.correctAnswer,
      correctAnswer: currentQuestion.correctAnswer,
      timeTaken: Duration.zero,
      answeredAt: DateTime.now(),
    );

    _currentQuiz = _currentQuiz!.copyWith(
      answers: [..._currentQuiz!.answers, quizAnswer],
      currentQuestionIndex: _currentQuiz!.currentQuestionIndex + 1,
    );

    state = AsyncValue.data(QuizAnswered(
      quiz: _currentQuiz!,
      answer: quizAnswer,
      isCorrect: true,
    ));
  }

  /// Complete the quiz
  Future<void> _completeQuiz() async {
    if (_currentQuiz == null) return;
    _cancelTimers();

    // Anti-cheat: Validate quiz state integrity before completing
    if (!_currentQuiz!.isStateValid) {
      state = const AsyncValue.data(QuizError(
        QuizFailure(
          message: 'Quiz state integrity check failed',
          code: 'integrity_error',
        ),
      ));
      return;
    }

    state = const AsyncValue.loading();

    final completedQuiz = _currentQuiz!.copyWith(
      completedAt: DateTime.now(),
    );

    final userId = _getUserId();
    final result = await _quizRepository.completeQuiz(
      completedQuiz,
      userId: userId,
    );

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
    _cancelTimers();
    _currentQuiz = null;
    _questionStopwatch.stop();
    _questionStopwatch.reset();
    _isSubmitting = false;
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
          // Anti-cheat: Reset stopwatch for loaded quiz
          _questionStopwatch
            ..reset()
            ..start();
          _isSubmitting = false;
          state = AsyncValue.data(QuizActive(
            quiz,
            questionStartTime: DateTime.now(), // For display only
          ));
        } else {
          state = const AsyncValue.data(QuizInitial());
        }
      },
    );
  }

  /// Cancel all timers
  void _cancelTimers() {
    _questionTimer?.cancel();
    _questionTimer = null;
    _blitzTimer?.cancel();
    _blitzTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

/// Quiz state provider
final quizStateProvider =
    StateNotifierProvider<QuizSessionNotifier, AsyncValue<QuizState>>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  return QuizSessionNotifier(
    quizRepository,
    () => ref.read(currentUserProvider)?.id,
  );
});

/// Current quiz provider
final currentQuizProvider = Provider<Quiz?>((ref) {
  final quizState = ref.watch(quizStateProvider);
  final state = quizState.valueOrNull;
  if (state is QuizActive) return state.quiz;
  if (state is QuizAnswered) return state.quiz;
  return null;
});

/// Current question provider
final currentQuestionProvider = Provider<QuizQuestion?>((ref) {
  final quiz = ref.watch(currentQuizProvider);
  return quiz?.currentQuestion;
});

/// Time remaining provider (for timed blitz)
final timeRemainingProvider = Provider<int?>((ref) {
  final quizState = ref.watch(quizStateProvider);
  final state = quizState.valueOrNull;
  if (state is QuizActive) return state.timeRemaining;
  return null;
});

/// Lives remaining provider (for marathon mode)
final livesRemainingProvider = Provider<int?>((ref) {
  final quiz = ref.watch(currentQuizProvider);
  return quiz?.livesRemaining;
});

/// Selected answers provider (for multi-select)
final selectedAnswersProvider = Provider<List<String>>((ref) {
  final quizState = ref.watch(quizStateProvider);
  final state = quizState.valueOrNull;
  if (state is QuizActive) return state.selectedAnswers;
  return [];
});

/// Hint visibility provider
final showHintProvider = Provider<bool>((ref) {
  final quizState = ref.watch(quizStateProvider);
  final state = quizState.valueOrNull;
  if (state is QuizActive) return state.showHint;
  return false;
});

/// Quiz progress provider
final quizProgressProvider = Provider<double>((ref) {
  final quiz = ref.watch(currentQuizProvider);
  if (quiz == null || quiz.totalQuestions == 0) return 0.0;
  return quiz.currentQuestionIndex / quiz.totalQuestions;
});

/// Quiz score provider
final quizScoreProvider = Provider<int>((ref) {
  final quiz = ref.watch(currentQuizProvider);
  return quiz?.score ?? 0;
});

/// Quiz history provider
final quizHistoryProvider = FutureProvider<List<QuizResult>>((ref) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
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
  final quizRepository = ref.watch(quizRepositoryProvider);
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
  final quizRepository = ref.watch(quizRepositoryProvider);

  final result = await quizRepository.getDailyChallenge();
  return result.fold(
    (failure) => null,
    (quiz) => quiz,
  );
});

/// Is daily challenge completed provider
final isDailyChallengeCompletedProvider = FutureProvider<bool>((ref) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return false;

  final result = await quizRepository.isDailyChallengeCompleted(user.id);
  return result.fold(
    (failure) => false,
    (isCompleted) => isCompleted,
  );
});

/// Quiz history restore provider
/// Automatically restores quiz history from Firestore when user logs in
final quizHistoryRestoreProvider = FutureProvider<void>((ref) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null || user.isAnonymous) return;

  // Restore quiz history from cloud
  await quizRepository.restoreQuizHistoryFromCloud(user.id);
});

/// Sync quiz history to cloud provider
/// Call this to manually sync local quiz history to Firestore
final syncQuizHistoryProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
  await quizRepository.syncQuizHistoryToCloud(userId);
});

/// Current streak provider
final currentStreakProvider = Provider<int>((ref) {
  final stats = ref.watch(quizStatisticsProvider);
  return stats.valueOrNull?.currentStreak ?? 0;
});

/// Best streak provider
final bestStreakProvider = Provider<int>((ref) {
  final stats = ref.watch(quizStatisticsProvider);
  return stats.valueOrNull?.bestStreak ?? 0;
});

/// Streak bonus multiplier provider
final streakBonusMultiplierProvider = Provider<double>((ref) {
  final streak = ref.watch(currentStreakProvider);
  if (streak >= 30) return 2.0; // 100% bonus
  if (streak >= 14) return 1.5; // 50% bonus
  if (streak >= 7) return 1.25; // 25% bonus
  if (streak >= 3) return 1.1; // 10% bonus
  return 1.0;
});
