import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/celebrations/celebration_overlay.dart';
import '../../../../presentation/components/mascot/mascot.dart';
import '../../../../presentation/providers/audio_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/celebration_provider.dart';
import '../../../../presentation/providers/quiz_provider.dart';
import '../../../../presentation/providers/user_preferences_provider.dart';
import '../widgets/results/achievements_section.dart';
import '../widgets/results/bonuses_section.dart';
import '../widgets/results/grade_badge.dart';
import '../widgets/results/perfect_score_banner.dart';
import '../widgets/results/performance_analysis_section.dart';
import '../widgets/results/result_action_buttons.dart';
import '../widgets/results/result_icon_display.dart';
import '../widgets/results/result_score_card.dart';
import '../widgets/results/result_stats_row.dart';
import '../widgets/results/session_type_badge.dart';
import '../widgets/results/star_rating_display.dart';
import '../widgets/results/xp_earned_card.dart';

/// Enhanced Quiz results screen with comprehensive analytics
class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({
    super.key,
    this.gameOverReason,
  });

  final String? gameOverReason;

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _xpAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _starsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );
    _xpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      // Check for perfect score
      final state = ref.read(quizStateProvider).valueOrNull;
      if (state is QuizCompleted) {
        // Record completion to streak data for persistence
        // Study mode doesn't earn XP so we don't record it
        if (state.result.sessionType != QuizSessionType.studyMode) {
          _recordCompletionWithMilestones(state.result);
        }

        // Play celebration based on performance
        _playCelebration(state.result);
      }
    });
  }

  /// Record quiz completion and check for milestone celebrations
  Future<void> _recordCompletionWithMilestones(QuizResult result) async {
    final milestones = await ref.read(streakDataProvider.notifier).recordQuizCompletion(
      xpEarned: result.xpEarned,
      isPerfect: result.isPerfectScore,
    );

    // Queue celebrations for milestones after a delay to let results screen show first
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final celebrationNotifier = ref.read(celebrationProvider.notifier);

      // Check for streak milestones
      celebrationNotifier.checkStreakMilestone(
        milestones.previousStreak,
        milestones.newStreak,
      );

      // Check for level up
      celebrationNotifier.checkLevelUp(
        milestones.previousXp,
        milestones.newXp,
      );
    });
  }

  /// Play celebration sounds and effects based on quiz performance
  Future<void> _playCelebration(QuizResult result) async {
    final audioService = ref.read(audioServiceProvider);

    if (result.isPerfectScore) {
      // Perfect score - big celebration
      _confettiController.play();
      HapticFeedback.heavyImpact();
      await audioService.playLevelUp();

      // Show celebration overlay for perfect scores
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            CelebrationOverlay.show(
              context,
              type: CelebrationType.perfect,
              message: AppLocalizations.of(context).perfectScore,
              autoDismiss: true,
              dismissDuration: const Duration(seconds: 3),
            );
          }
        });
      }
    } else if (result.accuracy >= 90) {
      // Excellent performance
      _confettiController.play();
      HapticFeedback.mediumImpact();
      await audioService.playAchievement();
    } else if (result.accuracy >= 80) {
      // Good performance
      HapticFeedback.mediumImpact();
      await audioService.playConfetti();
    } else if (result.accuracy >= 60) {
      // Okay performance
      HapticFeedback.lightImpact();
      await audioService.playCorrect();
    } else {
      // Needs improvement
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizStateProvider);
    final l10n = AppLocalizations.of(context);

    // Set up celebration context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(celebrationProvider.notifier).setContext(context);
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: quizState.when(
              data: (state) {
                if (state is! QuizCompleted) {
                  // No results, go back to quiz selection
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(Routes.quiz);
                  });
                  return const SizedBox.shrink();
                }
                return _buildResults(context, state.result);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(l10n.error),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.success,
                AppColors.xpGold,
                AppColors.achievement,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  /// Get first name from user's display name
  String _getFirstName(String? fullName, AppLocalizations l10n) {
    if (fullName == null || fullName.isEmpty) {
      return l10n.guest;
    }
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  Widget _buildResults(BuildContext context, QuizResult result) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = ref.watch(currentUserProvider);
    final firstName = _getFirstName(user?.displayName, l10n);
    final isGameOver = widget.gameOverReason != null;

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final spacingLG = responsive.sp(AppDimensions.spacingLG);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final spacingMD = responsive.sp(AppDimensions.spacingMD);
    final spacingXL = responsive.sp(AppDimensions.spacingXL);
    final spacingXXL = responsive.sp(AppDimensions.spacingXXL);
    final titleFontSize = responsive.sp(26);

    return SingleChildScrollView(
      padding: responsive.insets(AppDimensions.md),
      child: ResponsiveCenter(
        child: Column(
        children: [
          SizedBox(height: spacingLG),

          // Game Over or Success Header
          if (isGameOver)
            ResultIconDisplay(accuracy: result.accuracy, isGameOver: true)
          else
            ResultIconDisplay(accuracy: result.accuracy).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
          SizedBox(height: spacingLG),

          // Title
          Text(
            isGameOver ? l10n.gameOver : l10n.quizComplete,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),

          // Motivational message with Atlas
          SizedBox(height: spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AtlasAnimated(
                state: result.accuracy >= 70
                    ? AtlasState.celebrate
                    : AtlasState.encourage,
                size: 50,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  result.accuracy >= 70
                      ? l10n.motivationalQuiz(firstName)
                      : l10n.motivationalProgress(firstName),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          // Star Rating
          SizedBox(height: spacingXL),
          StarRatingDisplay(
            stars: result.starRating,
            animation: _starsAnimation,
          ).animate().fadeIn(delay: 400.ms),

          // Grade Badge
          SizedBox(height: spacingMD),
          GradeBadge(grade: result.grade).animate().fadeIn(delay: 500.ms),

          // Perfect Score Banner
          if (result.isPerfectScore) ...[
            SizedBox(height: spacingMD),
            const PerfectScoreBanner()
                .animate()
                .fadeIn(delay: 600.ms)
                .shimmer(duration: 2000.ms),
          ],

          // Session type info
          if (result.sessionType != QuizSessionType.standard) ...[
            SizedBox(height: spacingMD),
            SessionTypeBadge(
              sessionType: result.sessionType,
              continent: result.continent,
            ).animate().fadeIn(delay: 600.ms),
          ],

          SizedBox(height: spacingXL),

          // Score card
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) => ResultScoreCard(
              score: result.score,
              totalQuestions: result.totalQuestions,
              accuracy: result.accuracy,
              animationValue: _scoreAnimation.value,
              isArabic: isArabic,
            ),
          ),

          SizedBox(height: spacingLG),

          // Stats row
          ResultStatsRow(
            timeTaken: result.timeTaken,
            difficulty: result.difficulty,
            mode: result.mode,
          ).animate().fadeIn(delay: 800.ms),

          // Bonuses section
          if (result.sessionType != QuizSessionType.studyMode) ...[
            SizedBox(height: spacingLG),
            BonusesSection(
              streakBonus: result.streakBonus,
              speedBonus: result.speedBonus,
              hintsUsed: result.hintsUsed,
              perfectStreak: result.perfectStreak,
            ).animate().fadeIn(delay: 900.ms),
          ],

          // XP earned
          if (result.sessionType != QuizSessionType.studyMode) ...[
            SizedBox(height: spacingXL),
            AnimatedBuilder(
              animation: _xpAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_xpAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _xpAnimation.value,
                    child: XpEarnedCard(
                      xpEarned: result.xpEarned,
                      sessionType: result.sessionType,
                      isArabic: isArabic,
                    ),
                  ),
                );
              },
            ),
          ],

          // Weak/Strong areas
          if (result.weakAreas.isNotEmpty || result.strongAreas.isNotEmpty) ...[
            SizedBox(height: spacingXL),
            PerformanceAnalysisSection(
              strongAreas: result.strongAreas,
              weakAreas: result.weakAreas,
              isArabic: isArabic,
            ).animate().fadeIn(delay: 1000.ms),
          ],

          // Achievements unlocked
          if (result.newAchievements.isNotEmpty) ...[
            SizedBox(height: spacingXL),
            AchievementsSection(
              achievements: result.newAchievements,
              isArabic: isArabic,
            ).animate().fadeIn(delay: 1100.ms),
          ],

          SizedBox(height: spacingXXL),

          // Action buttons
          const ResultActionButtons()
              .animate()
              .fadeIn(delay: 1200.ms)
              .slideY(begin: 0.2, end: 0),

          SizedBox(height: spacingLG),
        ],
        ),
      ),
    );
  }
}
