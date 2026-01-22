import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';
import '../../../../presentation/widgets/error_widgets.dart';

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
  bool _isSubmitting = false; // Prevent double-tap cheating
  bool _hintUsedForCurrentQuestion = false; // Track hint usage per question
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScaleAnimation;
  late AnimationController _timerPulseController;

  @override
  void initState() {
    super.initState();
    // Register for app lifecycle events
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

    // Generate quiz on first load if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Anti-cheat: Save progress and handle timer when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Save current progress
      ref.read(quizStateProvider.notifier).saveProgress();
      // Note: Timer continues running - this is intentional for anti-cheat
      // User can't pause time by backgrounding the app
    }
  }

  void _initializeQuiz() {
    final currentState = ref.read(quizStateProvider).valueOrNull;

    // Only generate if not already active
    if (currentState is! QuizActive && currentState is! QuizAnswered) {
      if (widget.sessionType != null) {
        // Session type based initialization is done from QuizScreen
        // Just verify the state
      } else if (widget.mode != null && widget.difficulty != null) {
        // Standard quiz initialization
        ref.read(quizStateProvider.notifier).generateQuiz(
              mode: widget.mode!,
              difficulty: widget.difficulty!,
              region: widget.region,
            );
      }
    }
  }

  void _submitAnswer(String? answer) {
    // Anti-cheat: Prevent double-tap and rapid submission
    if (_hasAnswered || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _hasAnswered = true;
      _selectedAnswer = answer;
    });

    _feedbackAnimationController.forward();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Submit to provider
    ref.read(quizStateProvider.notifier).submitAnswer(
          answer: answer ?? '',
        );

    // Reset submitting flag after a delay to prevent issues
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }

  void _useHint() {
    // Prevent multiple hint uses for the same question
    if (_hintUsedForCurrentQuestion) return;

    HapticFeedback.lightImpact();
    setState(() {
      _hintUsedForCurrentQuestion = true;
    });
    ref.read(quizStateProvider.notifier).useHint();
  }

  void _showAnswerStudyMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _hasAnswered = true;
    });
    ref.read(quizStateProvider.notifier).showAnswer();
  }

  void _nextQuestion() {
    setState(() {
      _hasAnswered = false;
      _selectedAnswer = null;
      _isSubmitting = false;
      _hintUsedForCurrentQuestion = false; // Reset hint for new question
    });
    _feedbackAnimationController.reset();
    ref.read(quizStateProvider.notifier).nextQuestion();
  }

  void _toggleMultiSelect(String answer) {
    HapticFeedback.selectionClick();
    ref.read(quizStateProvider.notifier).toggleAnswerSelection(answer);
  }

  void _submitMultiSelect() {
    setState(() {
      _hasAnswered = true;
    });
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
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: quizState.when(
            data: (state) => _buildContent(context, state, theme, l10n, isArabic),
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
      // Navigate to results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.quizResults);
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuizGameOver) {
      // Navigate to results with game over reason
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

    // Get previous question for feedback (with bounds check to prevent crash)
    QuizQuestion? currentQuestion;
    if (showFeedback && state is QuizAnswered) {
      // Safe bounds check: ensure index is valid before accessing
      final prevIndex = quiz.currentQuestionIndex - 1;
      if (prevIndex >= 0 && prevIndex < quiz.questions.length) {
        currentQuestion = quiz.questions[prevIndex];
      } else {
        // Fallback to current question if index is invalid
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
        // Header with progress, lives, and close button
        _buildHeader(context, quiz, progress, theme, l10n, isArabic),

        // Timer for timed blitz
        if (quiz.sessionType == QuizSessionType.timedBlitz && timeRemaining != null)
          _buildBlitzTimer(timeRemaining, quiz.difficulty.timeLimitSeconds, theme),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              children: [
                // Question
                _buildQuestion(currentQuestion, theme, l10n, isArabic),
                const SizedBox(height: AppDimensions.spacingLG),

                // Hint button (if available and not used)
                if (!showFeedback &&
                    currentQuestion.hasHint &&
                    !showHint &&
                    !_hintUsedForCurrentQuestion &&
                    quiz.sessionType != QuizSessionType.studyMode)
                  _buildHintButton(theme, l10n, isArabic),

                // Show hint
                if (showHint)
                  _buildHintDisplay(currentQuestion, theme, isArabic),

                // Answer options
                if (currentQuestion.isMultiSelect)
                  _buildMultiSelectOptions(
                    currentQuestion,
                    theme,
                    showFeedback,
                    selectedAnswers,
                    isArabic,
                  )
                else
                  _buildOptions(currentQuestion, theme, showFeedback, isArabic),

                // Multi-select submit button
                if (currentQuestion.isMultiSelect && !showFeedback && selectedAnswers.isNotEmpty)
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
                if (!showFeedback && quiz.sessionType == QuizSessionType.studyMode)
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
                  _buildFeedback(
                    currentQuestion,
                    isCorrect!,
                    speedBonus,
                    xpEarned,
                    theme,
                    l10n,
                    isArabic,
                  ),
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

  Widget _buildHeader(
    BuildContext context,
    Quiz quiz,
    double progress,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showExitConfirmation(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    // Session type badge
                    if (quiz.sessionType != QuizSessionType.standard)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _getSessionTypeColor(quiz.sessionType)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getSessionTypeName(quiz.sessionType, isArabic),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getSessionTypeColor(quiz.sessionType),
                          ),
                        ),
                      ),
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
              // Lives display for marathon mode
              if (quiz.sessionType == QuizSessionType.marathon &&
                  quiz.livesRemaining != null)
                _buildLivesDisplay(quiz.livesRemaining!, theme),
              // Score display
              if (quiz.sessionType != QuizSessionType.studyMode)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.xpGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.score}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xpGold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivesDisplay(int lives, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final hasLife = index < lives;
          return Icon(
            hasLife ? Icons.favorite : Icons.favorite_border,
            color: hasLife ? AppColors.error : Colors.grey,
            size: 20,
          );
        }),
      ),
    );
  }

  Widget _buildBlitzTimer(int timeRemaining, int totalTime, ThemeData theme) {
    final progress = timeRemaining / totalTime;
    final isLow = timeRemaining <= 5;
    final color = isLow ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _timerPulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isLow ? 1.0 + (_timerPulseController.value * 0.1) : 1.0,
                    child: Icon(
                      Icons.timer,
                      color: color,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '$timeRemaining',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                's',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildHintButton(ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: OutlinedButton.icon(
        onPressed: _useHint,
        icon: const Icon(Icons.lightbulb_outline, size: 18),
        label: Text(
          l10n.useHint,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.xpGold,
          side: const BorderSide(color: AppColors.xpGold),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildHintDisplay(QuizQuestion question, ThemeData theme, bool isArabic) {
    final hint = isArabic && question.hintArabic != null
        ? question.hintArabic!
        : question.hint ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.xpGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppColors.xpGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hint,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.xpGold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuestion(
    QuizQuestion question,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final questionText = question.getDisplayQuestion(isArabic: isArabic);

    return Column(
      children: [
        // Flag image for flag quiz
        if ((question.mode == QuizMode.flags ||
                question.mode == QuizMode.reverseFlags) &&
            question.imageUrl != null) ...[
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
            child: CachedNetworkImage(
              imageUrl: question.imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.flag, size: 48),
              ),
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          const SizedBox(height: AppDimensions.spacingLG),
        ],

        // Question text
        Text(
          questionText,
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),

        // Multi-select indicator
        if (question.isMultiSelect) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.selectAnswersCount(question.correctAnswers?.length ?? 0),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptions(
    QuizQuestion question,
    ThemeData theme,
    bool showFeedback,
    bool isArabic,
  ) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
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
                    // Option letter
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (borderColor ?? theme.colorScheme.outline)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: borderColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 15,
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
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }

  Widget _buildMultiSelectOptions(
    QuizQuestion question,
    ThemeData theme,
    bool showFeedback,
    List<String> selectedAnswers,
    bool isArabic,
  ) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswers.contains(option);
        final isCorrect = question.correctAnswers?.contains(option) ?? false;

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
              onTap: showFeedback ? null : () => _toggleMultiSelect(option),
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
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (borderColor ?? theme.colorScheme.primary)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: borderColor ??
                              theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
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
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }

  Widget _buildFeedback(
    QuizQuestion question,
    bool isCorrect,
    double? speedBonus,
    int? xpEarned,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final explanation = isArabic && question.explanationArabic != null
        ? question.explanationArabic!
        : question.explanation;
    final funFact = isArabic && question.funFactArabic != null
        ? question.funFactArabic!
        : question.funFact;

    return ScaleTransition(
      scale: _feedbackScaleAnimation,
      child: Column(
        children: [
          // Correct/Incorrect banner
          Container(
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
                      Row(
                        children: [
                          Text(
                            isCorrect ? l10n.correct : l10n.incorrect,
                            style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                          // Speed bonus badge
                          if (isCorrect && speedBonus != null && speedBonus > 1.0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.xpGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${speedBonus.toStringAsFixed(1)}x',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isCorrect)
                        Text(
                          l10n.theAnswerWas(question.correctAnswer),
                          style: theme.textTheme.bodyMedium,
                        ),
                      // XP earned
                      if (xpEarned != null && xpEarned > 0)
                        Text(
                          '+$xpEarned XP',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.xpGold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Explanation
          if (explanation != null) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.explanation,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Fun fact
          if (funFact != null) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.didYouKnow,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    funFact,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    // Convert error to Failure if possible
    final failure = error is Failure
        ? error
        : QuizFailure(
            message: error.toString(),
            code: 'unknown',
          );

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

  Color _getSessionTypeColor(QuizSessionType sessionType) {
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return const Color(0xFF2196F3);
      case QuizSessionType.continentChallenge:
        return const Color(0xFF4CAF50);
      case QuizSessionType.timedBlitz:
        return const Color(0xFFF44336);
      case QuizSessionType.dailyChallenge:
        return const Color(0xFFFF6D00);
      case QuizSessionType.marathon:
        return const Color(0xFF9C27B0);
      case QuizSessionType.studyMode:
        return const Color(0xFF607D8B);
      case QuizSessionType.standard:
        return AppColors.primary;
    }
  }

  String _getSessionTypeName(QuizSessionType sessionType, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return l10n.sessionTypeQuickQuiz;
      case QuizSessionType.continentChallenge:
        return l10n.sessionTypeContinentChallenge;
      case QuizSessionType.timedBlitz:
        return l10n.sessionTypeTimedBlitz;
      case QuizSessionType.dailyChallenge:
        return l10n.sessionTypeDailyChallenge;
      case QuizSessionType.marathon:
        return l10n.sessionTypeMarathon;
      case QuizSessionType.studyMode:
        return l10n.sessionTypeStudyMode;
      case QuizSessionType.standard:
        return l10n.sessionTypeStandard;
    }
  }
}
