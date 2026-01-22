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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                return _buildResults(context, state.result, theme, l10n, isArabic);
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

  Widget _buildResults(
    BuildContext context,
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
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
            _buildGameOverHeader(theme, isArabic)
          else
            _buildResultIcon(result, theme).animate().scale(
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
          _buildStarRating(result, theme).animate().fadeIn(delay: 400.ms),

          // Grade Badge
          const SizedBox(height: AppDimensions.spacingMD),
          _buildGradeBadge(result, theme, isArabic).animate().fadeIn(delay: 500.ms),

          // Perfect Score Banner
          if (result.isPerfectScore) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            _buildPerfectScoreBanner(theme, isArabic)
                .animate()
                .fadeIn(delay: 600.ms)
                .shimmer(duration: 2000.ms),
          ],

          // Session type info
          if (result.sessionType != QuizSessionType.standard) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            _buildSessionTypeInfo(result, theme, isArabic)
                .animate()
                .fadeIn(delay: 600.ms),
          ],

          const SizedBox(height: AppDimensions.spacingXL),

          // Score card
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) => _buildScoreCard(
              result,
              theme,
              l10n,
              isArabic,
              _scoreAnimation.value,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLG),

          // Stats row
          _buildStatsRow(result, theme, l10n, isArabic)
              .animate()
              .fadeIn(delay: 800.ms),

          // Bonuses section
          if (result.sessionType != QuizSessionType.studyMode) ...[
            const SizedBox(height: AppDimensions.spacingLG),
            _buildBonusesSection(result, theme, isArabic)
                .animate()
                .fadeIn(delay: 900.ms),
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
                    child: _buildXpCard(result, theme, l10n, isArabic),
                  ),
                );
              },
            ),
          ],

          // Weak/Strong areas
          if (result.weakAreas.isNotEmpty || result.strongAreas.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXL),
            _buildPerformanceAnalysis(result, theme, isArabic)
                .animate()
                .fadeIn(delay: 1000.ms),
          ],

          // Achievements unlocked
          if (result.newAchievements.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXL),
            _buildAchievementsSection(result, theme, isArabic)
                .animate()
                .fadeIn(delay: 1100.ms),
          ],

          const SizedBox(height: AppDimensions.spacingXXL),

          // Action buttons
          _buildActionButtons(context, result, theme, l10n, isArabic)
              .animate()
              .fadeIn(delay: 1200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppDimensions.spacingLG),
        ],
      ),
    );
  }

  Widget _buildGameOverHeader(ThemeData theme, bool isArabic) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.error.withValues(alpha: 0.1),
      ),
      child: const Icon(
        Icons.sentiment_dissatisfied,
        size: 60,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildResultIcon(QuizResult result, ThemeData theme) {
    final accuracy = result.accuracy;
    IconData icon;
    Color color;

    if (accuracy >= 100) {
      icon = Icons.emoji_events;
      color = AppColors.xpGold;
    } else if (accuracy >= 80) {
      icon = Icons.military_tech;
      color = AppColors.success;
    } else if (accuracy >= 60) {
      icon = Icons.thumb_up;
      color = AppColors.primary;
    } else if (accuracy >= 40) {
      icon = Icons.sentiment_neutral;
      color = AppColors.warning;
    } else {
      icon = Icons.sentiment_dissatisfied;
      color = AppColors.error;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: 60, color: color),
    );
  }

  Widget _buildStarRating(QuizResult result, ThemeData theme) {
    final stars = result.starRating;

    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        final animatedStars =
            (stars * _starsAnimation.value).clamp(0.0, 5.0).toInt();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = index < animatedStars;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: 36,
                color: isFilled ? AppColors.xpGold : Colors.grey[400],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGradeBadge(QuizResult result, ThemeData theme, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    final grade = result.grade;
    final color = _getGradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        _getGradeDisplay(grade, l10n),
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getGradeDisplay(String grade, AppLocalizations l10n) {
    switch (grade) {
      case 'A+':
        return l10n.gradeExcellentPlus;
      case 'A':
        return l10n.gradeExcellent;
      case 'B':
        return l10n.gradeVeryGood;
      case 'C':
        return l10n.gradeGood;
      case 'D':
        return l10n.gradePass;
      default:
        return l10n.gradeFail;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return AppColors.xpGold;
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.primary;
      case 'C':
        return AppColors.warning;
      case 'D':
        return Colors.orange;
      default:
        return AppColors.error;
    }
  }

  Widget _buildPerfectScoreBanner(ThemeData theme, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.perfectScoreTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildSessionTypeInfo(
    QuizResult result,
    ThemeData theme,
    bool isArabic,
  ) {
    final sessionName = _getSessionTypeName(result.sessionType, isArabic);
    final color = _getSessionTypeColor(result.sessionType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSessionTypeIcon(result.sessionType),
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            sessionName,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (result.continent != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
            Text(
              result.continent!,
              style: GoogleFonts.poppins(
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
    double animationValue,
  ) {
    final displayScore = (result.score * animationValue).round();
    final displayTotal = result.totalQuestions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          children: [
            Text(
              l10n.yourScore,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$displayScore',
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.accuracy),
                  ),
                ),
                Text(
                  ' / $displayTotal',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.progressBarHeight,
              ),
              child: LinearProgressIndicator(
                value: result.accuracy / 100 * animationValue,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                color: _getScoreColor(result.accuracy),
                minHeight: AppDimensions.progressBarHeight * 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              '${(result.accuracy * animationValue).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(result.accuracy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.primary;
    if (accuracy >= 40) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildStatsRow(
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer,
            label: l10n.timeTaken,
            value: _formatDuration(result.timeTaken),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.speed,
            label: l10n.levelLabel,
            value: result.difficulty.displayName,
            color: _getDifficultyColor(result.difficulty),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.category,
            label: l10n.modeLabel,
            value: result.mode.displayName,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBonusesSection(
    QuizResult result,
    ThemeData theme,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    final bonuses = <Widget>[];

    // Streak bonus
    if (result.streakBonus > 0) {
      bonuses.add(_buildBonusChip(
        icon: Icons.local_fire_department,
        label: l10n.streakBonus,
        value: '+${result.streakBonus}',
        color: AppColors.xpGold,
      ));
    }

    // Speed bonus
    if (result.speedBonus > 0) {
      bonuses.add(_buildBonusChip(
        icon: Icons.bolt,
        label: l10n.speedBonus,
        value: '+${result.speedBonus}',
        color: AppColors.success,
      ));
    }

    // Hints used penalty
    if (result.hintsUsed > 0) {
      bonuses.add(_buildBonusChip(
        icon: Icons.lightbulb,
        label: l10n.hintsLabel,
        value: '-${result.hintsUsed * 5}',
        color: AppColors.warning,
        isNegative: true,
      ));
    }

    // Perfect streak bonus
    if (result.perfectStreak > 3) {
      bonuses.add(_buildBonusChip(
        icon: Icons.whatshot,
        label: l10n.perfectStreakLabel,
        value: '${result.perfectStreak}',
        color: AppColors.error,
      ));
    }

    if (bonuses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bonusesAndPenalties,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bonuses,
        ),
      ],
    );
  }

  Widget _buildBonusChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return AppColors.difficultyEasy;
      case QuizDifficulty.medium:
        return AppColors.difficultyMedium;
      case QuizDifficulty.hard:
        return AppColors.difficultyHard;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  Widget _buildXpCard(
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Card(
      color: AppColors.xpGold.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.xpGold,
                  size: 40,
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.xpEarned,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '+${result.xpEarned} XP',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.xpGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // XP breakdown
            if (result.sessionType != QuizSessionType.standard) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getXpMultiplierText(result.sessionType, isArabic),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.xpGold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getXpMultiplierText(QuizSessionType sessionType, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    final multiplier = sessionType.xpMultiplier;
    return l10n.xpMultiplierInfo(
      '${multiplier}x',
      _getSessionTypeName(sessionType, isArabic),
    );
  }

  Widget _buildPerformanceAnalysis(
    QuizResult result,
    ThemeData theme,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.performanceAnalysis,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Strong areas
        if (result.strongAreas.isNotEmpty) ...[
          _buildAreaSection(
            title: l10n.strongAreas,
            areas: result.strongAreas,
            icon: Icons.check_circle,
            color: AppColors.success,
            isArabic: isArabic,
          ),
          const SizedBox(height: 12),
        ],
        // Weak areas
        if (result.weakAreas.isNotEmpty)
          _buildAreaSection(
            title: l10n.needsImprovement,
            areas: result.weakAreas,
            icon: Icons.trending_up,
            color: AppColors.warning,
            isArabic: isArabic,
          ),
      ],
    );
  }

  Widget _buildAreaSection({
    required String title,
    required List<String> areas,
    required IconData icon,
    required Color color,
    required bool isArabic,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areas.map((area) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAreaDisplayName(area, isArabic),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getAreaDisplayName(String area, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    final names = {
      'capitals': l10n.areaCapitals,
      'flags': l10n.areaFlags,
      'reverseFlags': l10n.areaReverseFlags,
      'maps': l10n.areaMaps,
      'population': l10n.areaPopulation,
      'currencies': l10n.areaCurrencies,
      'languages': l10n.areaLanguages,
      'borders': l10n.areaBorders,
      'timezones': l10n.areaTimezones,
    };
    return names[area] ?? area;
  }

  Widget _buildAchievementsSection(
    QuizResult result,
    ThemeData theme,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.achievement),
            const SizedBox(width: 8),
            Text(
              l10n.newAchievements,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...result.newAchievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getAchievementName(achievement, isArabic),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getAchievementName(String achievement, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    final names = {
      'perfect_quiz': l10n.achievementPerfectQuiz,
      'marathon_master': l10n.achievementMarathonMaster,
      'daily_challenger': l10n.achievementDailyChallenger,
      'speed_demon': l10n.achievementSpeedDemon,
      'streak_master': l10n.achievementStreakMaster,
    };
    return names[achievement] ?? achievement;
  }

  Widget _buildActionButtons(
    BuildContext context,
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightL,
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(quizStateProvider.notifier).reset();
              context.go(Routes.quiz);
            },
            icon: const Icon(Icons.replay),
            label: Text(l10n.playAgain),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightL,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(quizStateProvider.notifier).reset();
              context.go(Routes.home);
            },
            icon: const Icon(Icons.home),
            label: Text(l10n.backToHome),
          ),
        ),
      ],
    );
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

  IconData _getSessionTypeIcon(QuizSessionType sessionType) {
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return Icons.bolt;
      case QuizSessionType.continentChallenge:
        return Icons.public;
      case QuizSessionType.timedBlitz:
        return Icons.timer;
      case QuizSessionType.dailyChallenge:
        return Icons.today;
      case QuizSessionType.marathon:
        return Icons.sports_score;
      case QuizSessionType.studyMode:
        return Icons.school;
      case QuizSessionType.standard:
        return Icons.quiz;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
