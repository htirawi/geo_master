import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';
import '../../../../presentation/widgets/error_widgets.dart';
import '../widgets/game/blitz_timer.dart';
import '../widgets/game/hint_widgets.dart';
import '../widgets/game/quiz_feedback.dart';
import '../widgets/game/quiz_game_header.dart';
import '../widgets/game/quiz_options.dart';
import '../widgets/game/quiz_question.dart';

/// Enhanced Quiz game screen with all session types support
class QuizGameScreen extends ConsumerStatefulWidget {
  const QuizGameScreen({
    super.key,
    this.mode,
    this.difficulty,
    this.region,
    this.sessionType,
    this.continent,
  });

  final QuizMode? mode;
  final QuizDifficulty? difficulty;
  final String? region;
  final QuizSessionType? sessionType;
  final String? continent;

  @override
  ConsumerState<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends ConsumerState<QuizGameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _hasAnswered = false;
  String? _selectedAnswer;
  bool _isSubmitting = false;
  bool _hintUsedForCurrentQuestion = false;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScaleAnimation;
  late AnimationController _timerPulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(quizStateProvider.notifier).saveProgress();
    }
  }

  void _initializeQuiz() {
    final currentState = ref.read(quizStateProvider).valueOrNull;

    if (currentState is! QuizActive && currentState is! QuizAnswered) {
      if (widget.sessionType != null) {
        // Session type based initialization is done from QuizScreen
      } else if (widget.mode != null && widget.difficulty != null) {
        ref.read(quizStateProvider.notifier).generateQuiz(
              mode: widget.mode!,
              difficulty: widget.difficulty!,
              region: widget.region,
            );
      }
    }
  }

  void _submitAnswer(String? answer) {
    if (_hasAnswered || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _hasAnswered = true;
      _selectedAnswer = answer;
    });

    _feedbackAnimationController.forward();
    HapticFeedback.mediumImpact();

    ref.read(quizStateProvider.notifier).submitAnswer(answer: answer ?? '');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    });
  }

  void _useHint() {
    if (_hintUsedForCurrentQuestion) return;

    HapticFeedback.lightImpact();
    setState(() => _hintUsedForCurrentQuestion = true);
    ref.read(quizStateProvider.notifier).useHint();
  }

  void _showAnswerStudyMode() {
    HapticFeedback.lightImpact();
    setState(() => _hasAnswered = true);
    ref.read(quizStateProvider.notifier).showAnswer();
  }

  void _nextQuestion() {
    setState(() {
      _hasAnswered = false;
      _selectedAnswer = null;
      _isSubmitting = false;
      _hintUsedForCurrentQuestion = false;
    });
    _feedbackAnimationController.reset();
    ref.read(quizStateProvider.notifier).nextQuestion();
  }

  void _toggleMultiSelect(String answer) {
    HapticFeedback.selectionClick();
    ref.read(quizStateProvider.notifier).toggleAnswerSelection(answer);
  }

  void _submitMultiSelect() {
    setState(() => _hasAnswered = true);
    _feedbackAnimationController.forward();
    HapticFeedback.mediumImpact();
    ref.read(quizStateProvider.notifier).submitMultiSelectAnswer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _feedbackAnimationController.dispose();
    _timerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitConfirmation(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: quizState.when(
            data: (state) =>
                _buildContent(context, state, theme, l10n, isArabic),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context, error, l10n, isArabic),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuizState state,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    if (state is QuizLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuizError) {
      return _buildError(context, state.failure.message, l10n, isArabic);
    }

    if (state is QuizCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.quizResults);
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuizGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('${Routes.quizResults}?gameOver=${state.reason}');
      });
      return const Center(child: CircularProgressIndicator());
    }

    Quiz? quiz;
    bool showFeedback = false;
    bool? isCorrect;
    double? speedBonus;
    int? xpEarned;
    int? timeRemaining;
    bool showHint = false;
    List<String> selectedAnswers = [];

    if (state is QuizActive) {
      quiz = state.quiz;
      timeRemaining = state.timeRemaining;
      showHint = state.showHint;
      selectedAnswers = state.selectedAnswers;
    } else if (state is QuizAnswered) {
      quiz = state.quiz;
      showFeedback = true;
      isCorrect = state.isCorrect;
      speedBonus = state.speedBonus;
      xpEarned = state.xpEarned;
    }

    if (quiz == null) {
      return const Center(child: CircularProgressIndicator());
    }

    QuizQuestion? currentQuestion;
    if (showFeedback && state is QuizAnswered) {
      final prevIndex = quiz.currentQuestionIndex - 1;
      if (prevIndex >= 0 && prevIndex < quiz.questions.length) {
        currentQuestion = quiz.questions[prevIndex];
      } else {
        currentQuestion = quiz.currentQuestion;
      }
    } else {
      currentQuestion = quiz.currentQuestion;
    }

    if (currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progress = quiz.currentQuestionIndex / quiz.totalQuestions;

    return Column(
      children: [
        // Header
        QuizGameHeader(
          quiz: quiz,
          progress: progress,
          isArabic: isArabic,
          onClose: () => _showExitConfirmation(context),
        ),

        // Timer for timed blitz
        if (quiz.sessionType == QuizSessionType.timedBlitz &&
            timeRemaining != null)
          BlitzTimer(
            timeRemaining: timeRemaining,
            totalTime: quiz.difficulty.timeLimitSeconds,
            pulseAnimation: _timerPulseController,
          ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              children: [
                // Question
                QuizQuestionDisplay(
                  question: currentQuestion,
                  isArabic: isArabic,
                ),
                const SizedBox(height: AppDimensions.spacingLG),

                // Hint button
                if (!showFeedback &&
                    currentQuestion.hasHint &&
                    !showHint &&
                    !_hintUsedForCurrentQuestion &&
                    quiz.sessionType != QuizSessionType.studyMode)
                  HintButton(onPressed: _useHint, isArabic: isArabic),

                // Show hint
                if (showHint)
                  HintDisplay(
                    hint: isArabic && currentQuestion.hintArabic != null
                        ? currentQuestion.hintArabic!
                        : currentQuestion.hint ?? '',
                  ),

                // Answer options
                if (currentQuestion.isMultiSelect)
                  QuizOptionsMulti(
                    question: currentQuestion,
                    showFeedback: showFeedback,
                    selectedAnswers: selectedAnswers,
                    onToggleAnswer: _toggleMultiSelect,
                    isArabic: isArabic,
                  )
                else
                  QuizOptionsSingle(
                    question: currentQuestion,
                    showFeedback: showFeedback,
                    selectedAnswer: _selectedAnswer,
                    onAnswerSelected: _submitAnswer,
                    isArabic: isArabic,
                  ),

                // Multi-select submit button
                if (currentQuestion.isMultiSelect &&
                    !showFeedback &&
                    selectedAnswers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingMD),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeightL,
                      child: FilledButton(
                        onPressed: _submitMultiSelect,
                        child: Text(l10n.confirmAnswers),
                      ),
                    ),
                  ),

                // Study mode - show answer button
                if (!showFeedback &&
                    quiz.sessionType == QuizSessionType.studyMode)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingMD),
                    child: TextButton.icon(
                      onPressed: _showAnswerStudyMode,
                      icon: const Icon(Icons.visibility),
                      label: Text(l10n.showAnswer),
                    ),
                  ),

                // Feedback
                if (showFeedback) ...[
                  const SizedBox(height: AppDimensions.spacingXL),
                  QuizFeedbackSection(
                    question: currentQuestion,
                    isCorrect: isCorrect!,
                    speedBonus: speedBonus,
                    xpEarned: xpEarned,
                    scaleAnimation: _feedbackScaleAnimation,
                    isArabic: isArabic,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Next button
        if (showFeedback)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightL,
              child: FilledButton(
                onPressed: _nextQuestion,
                child: Text(
                  quiz.currentQuestionIndex >= quiz.totalQuestions
                      ? l10n.done
                      : l10n.next,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final failure = error is Failure
        ? error
        : QuizFailure(message: error.toString(), code: 'unknown');

    return ErrorStateWidget.fromFailure(
      failure: failure,
      isArabic: isArabic,
      onRetry: _initializeQuiz,
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitQuizTitle),
        content: Text(l10n.exitQuizMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(quizStateProvider.notifier).reset();
              context.go(Routes.quiz);
            },
            child: Text(l10n.exitButton),
          ),
        ],
      ),
    );
  }
}
