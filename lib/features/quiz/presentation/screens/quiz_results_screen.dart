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
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
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
          ref.read(streakDataProvider.notifier).recordQuizCompletion(
            xpEarned: state.result.xpEarned,
            isPerfect: state.result.isPerfectScore,
          );
        }

        if (state.result.isPerfectScore) {
          _confettiController.play();
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
    });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingLG),

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
          const SizedBox(height: AppDimensions.spacingLG),

          // Title
          Text(
            isGameOver ? l10n.gameOver : l10n.quizComplete,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),

          // Motivational message
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            result.accuracy >= 70
                ? l10n.motivationalQuiz(firstName)
                : l10n.motivationalProgress(firstName),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          // Star Rating
          const SizedBox(height: AppDimensions.spacingXL),
          StarRatingDisplay(
            stars: result.starRating,
            animation: _starsAnimation,
          ).animate().fadeIn(delay: 400.ms),

          // Grade Badge
          const SizedBox(height: AppDimensions.spacingMD),
          GradeBadge(grade: result.grade).animate().fadeIn(delay: 500.ms),

          // Perfect Score Banner
          if (result.isPerfectScore) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            const PerfectScoreBanner()
                .animate()
                .fadeIn(delay: 600.ms)
                .shimmer(duration: 2000.ms),
          ],

          // Session type info
          if (result.sessionType != QuizSessionType.standard) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            SessionTypeBadge(
              sessionType: result.sessionType,
              continent: result.continent,
            ).animate().fadeIn(delay: 600.ms),
          ],

          const SizedBox(height: AppDimensions.spacingXL),

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

          const SizedBox(height: AppDimensions.spacingLG),

          // Stats row
          ResultStatsRow(
            timeTaken: result.timeTaken,
            difficulty: result.difficulty,
            mode: result.mode,
          ).animate().fadeIn(delay: 800.ms),

          // Bonuses section
          if (result.sessionType != QuizSessionType.studyMode) ...[
            const SizedBox(height: AppDimensions.spacingLG),
            BonusesSection(
              streakBonus: result.streakBonus,
              speedBonus: result.speedBonus,
              hintsUsed: result.hintsUsed,
              perfectStreak: result.perfectStreak,
            ).animate().fadeIn(delay: 900.ms),
          ],

          // XP earned
          if (result.sessionType != QuizSessionType.studyMode) ...[
            const SizedBox(height: AppDimensions.spacingXL),
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
            const SizedBox(height: AppDimensions.spacingXL),
            PerformanceAnalysisSection(
              strongAreas: result.strongAreas,
              weakAreas: result.weakAreas,
              isArabic: isArabic,
            ).animate().fadeIn(delay: 1000.ms),
          ],

          // Achievements unlocked
          if (result.newAchievements.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXL),
            AchievementsSection(
              achievements: result.newAchievements,
              isArabic: isArabic,
            ).animate().fadeIn(delay: 1100.ms),
          ],

          const SizedBox(height: AppDimensions.spacingXXL),

          // Action buttons
          const ResultActionButtons()
              .animate()
              .fadeIn(delay: 1200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppDimensions.spacingLG),
        ],
      ),
    );
  }
}
