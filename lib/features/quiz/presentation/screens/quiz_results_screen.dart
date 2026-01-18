import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';

/// Quiz results screen - shows score, XP earned, and allows review
class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _xpAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _xpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      // Check for perfect score
      final state = ref.read(quizStateProvider).valueOrNull;
      if (state is QuizCompleted && state.result.isPerfectScore) {
        _confettiController.play();
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
                return _buildResults(context, state.result, theme, l10n);
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

  Widget _buildResults(
    BuildContext context,
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXL),

          // Trophy/Badge icon
          _buildResultIcon(result, theme),
          const SizedBox(height: AppDimensions.spacingLG),

          // Title
          Text(
            l10n.quizComplete,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (result.isPerfectScore) ...[
            const SizedBox(height: AppDimensions.spacingSM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.xpGold,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.perfectScore,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingXL),

          // Score card
          _buildScoreCard(result, theme, l10n),

          const SizedBox(height: AppDimensions.spacingLG),

          // Stats row
          _buildStatsRow(result, theme, l10n),

          const SizedBox(height: AppDimensions.spacingXL),

          // XP earned
          AnimatedBuilder(
            animation: _xpAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_xpAnimation.value * 0.2),
                child: Opacity(
                  opacity: _xpAnimation.value,
                  child: _buildXpCard(result, theme, l10n),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spacingXXL),

          // Action buttons
          _buildActionButtons(context, result, theme, l10n),

          const SizedBox(height: AppDimensions.spacingLG),
        ],
      ),
    );
  }

  Widget _buildResultIcon(QuizResult result, ThemeData theme) {
    final accuracy = result.accuracy;
    IconData icon;
    Color color;
    const double size = 80;

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
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildScoreCard(
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final displayScore =
            (result.score * _scoreAnimation.value).round();
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
                      style: theme.textTheme.displayLarge?.copyWith(
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
                    value: result.accuracy / 100 * _scoreAnimation.value,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    color: _getScoreColor(result.accuracy),
                    minHeight: AppDimensions.progressBarHeight * 1.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                Text(
                  '${(result.accuracy * _scoreAnimation.value).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.accuracy),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            label: l10n.difficulty,
            value: result.difficulty.displayName,
            color: _getDifficultyColor(result.difficulty),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.category,
            label: 'Mode',
            value: result.mode.displayName,
            color: AppColors.secondary,
          ),
        ),
      ],
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
  ) {
    return Card(
      color: AppColors.xpGold.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star,
              color: AppColors.xpGold,
              size: 32,
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
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.xpGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    QuizResult result,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightL,
          child: FilledButton.icon(
            onPressed: () {
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
