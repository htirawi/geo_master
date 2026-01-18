import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';

/// Quiz game screen - displays questions and handles answers
class QuizGameScreen extends ConsumerStatefulWidget {
  const QuizGameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    this.region,
  });

  final QuizMode mode;
  final QuizDifficulty difficulty;
  final String? region;

  @override
  ConsumerState<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends ConsumerState<QuizGameScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _timeRemaining = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  late AnimationController _timerAnimationController;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScaleAnimation;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.difficulty.timeLimitSeconds),
    );
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

    // Generate quiz on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuiz();
    });
  }

  void _generateQuiz() {
    ref.read(quizStateProvider.notifier).generateQuiz(
          mode: widget.mode,
          difficulty: widget.difficulty,
          region: widget.region,
        );
  }

  void _startTimer() {
    _timeRemaining = widget.difficulty.timeLimitSeconds;
    _timerAnimationController.forward(from: 0);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            _timer?.cancel();
            if (!_hasAnswered) {
              _submitAnswer(null); // Time's up, submit no answer
            }
          }
        });
      }
    });
  }

  void _submitAnswer(String? answer) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
    });

    _timer?.cancel();
    _feedbackAnimationController.forward();

    // Haptic feedback
    if (answer != null) {
      final quiz = ref.read(currentQuizProvider);
      final isCorrect = quiz?.currentQuestion?.correctAnswer == answer;
      HapticFeedback.mediumImpact();
      if (isCorrect) {
        HapticFeedback.lightImpact();
      }
    }

    // Submit to provider
    final timeTaken = Duration(
      seconds: widget.difficulty.timeLimitSeconds - _timeRemaining,
    );
    ref.read(quizStateProvider.notifier).submitAnswer(
          answer: answer ?? '',
          timeTaken: timeTaken,
        );
  }

  void _nextQuestion() {
    setState(() {
      _hasAnswered = false;
      _selectedAnswer = null;
    });
    _feedbackAnimationController.reset();
    ref.read(quizStateProvider.notifier).nextQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: quizState.when(
            data: (state) => _buildContent(context, state, theme, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context, error, l10n),
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
  ) {
    if (state is QuizLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuizError) {
      return _buildError(context, state.failure.message, l10n);
    }

    if (state is QuizCompleted) {
      // Navigate to results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.quizResults);
      });
      return const Center(child: CircularProgressIndicator());
    }

    Quiz? quiz;
    bool showFeedback = false;
    bool? isCorrect;

    if (state is QuizActive) {
      quiz = state.quiz;
      if (!_hasAnswered && _timer == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startTimer();
        });
      }
    } else if (state is QuizAnswered) {
      quiz = state.quiz;
      showFeedback = true;
      isCorrect = state.isCorrect;
    }

    if (quiz == null || quiz.currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = quiz.currentQuestion!;
    final progress = (quiz.currentQuestionIndex + 1) / quiz.totalQuestions;

    return Column(
      children: [
        // Header with progress and close button
        _buildHeader(context, quiz, progress, theme, l10n),

        // Timer
        _buildTimer(theme),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              children: [
                // Question
                _buildQuestion(question, theme, l10n),
                const SizedBox(height: AppDimensions.spacingXL),

                // Answer options
                _buildOptions(question, theme, showFeedback),

                // Feedback
                if (showFeedback) ...[
                  const SizedBox(height: AppDimensions.spacingXL),
                  _buildFeedback(question, isCorrect!, theme, l10n),
                ],
              ],
            ),
          ),
        ),

        // Next button (shown after answering)
        if (showFeedback)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightL,
              child: FilledButton(
                onPressed: _nextQuestion,
                child: Text(
                  quiz.currentQuestionIndex + 1 >= quiz.totalQuestions
                      ? l10n.done
                      : l10n.next,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Quiz quiz,
    double progress,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmation(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.questionNumber(
                    quiz.currentQuestionIndex + 1,
                    quiz.totalQuestions,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.progressBarHeight / 2,
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    minHeight: AppDimensions.progressBarHeight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildTimer(ThemeData theme) {
    final isLow = _timeRemaining <= 5;
    final color = isLow ? AppColors.error : theme.colorScheme.primary;

    return Container(
      width: AppDimensions.quizTimerSize,
      height: AppDimensions.quizTimerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Text(
          '$_timeRemaining',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(
    QuizQuestion question,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final questionText = question.getDisplayQuestion(isArabic: isArabic);

    return Column(
      children: [
        // Flag image for flag quiz
        if (question.mode == QuizMode.flags && question.imageUrl != null) ...[
          Container(
            height: 120,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              question.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.flag, size: 48),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLG),
        ],

        // Question text
        Text(
          questionText,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptions(
    QuizQuestion question,
    ThemeData theme,
    bool showFeedback,
  ) {
    return Column(
      children: question.options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrect = question.correctAnswer == option;

        Color? backgroundColor;
        Color? borderColor;
        Color? textColor;

        if (showFeedback) {
          if (isCorrect) {
            backgroundColor = AppColors.quizCorrect.withValues(alpha: 0.1);
            borderColor = AppColors.quizCorrect;
            textColor = AppColors.quizCorrect;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.quizIncorrect.withValues(alpha: 0.1);
            borderColor = AppColors.quizIncorrect;
            textColor = AppColors.quizIncorrect;
          }
        } else if (isSelected) {
          backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
          borderColor = theme.colorScheme.primary;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
          child: Material(
            color: backgroundColor ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            child: InkWell(
              onTap: showFeedback ? null : () => _submitAnswer(option),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor ??
                        theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected || (showFeedback && isCorrect) ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (showFeedback && isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.quizCorrect,
                      )
                    else if (showFeedback && isSelected && !isCorrect)
                      const Icon(
                        Icons.cancel,
                        color: AppColors.quizIncorrect,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(
    QuizQuestion question,
    bool isCorrect,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ScaleTransition(
      scale: _feedbackScaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: (isCorrect ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.celebration : Icons.info_outline,
              color: isCorrect ? AppColors.success : AppColors.error,
              size: 32,
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? l10n.correct : l10n.incorrect,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                  if (!isCorrect)
                    Text(
                      l10n.theAnswerWas(question.correctAnswer),
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            FilledButton(
              onPressed: _generateQuiz,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
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
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
