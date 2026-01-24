import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Stats row showing time, difficulty, and mode
class ResultStatsRow extends StatelessWidget {
  const ResultStatsRow({
    super.key,
    required this.timeTaken,
    required this.difficulty,
    required this.mode,
  });

  final Duration timeTaken;
  final QuizDifficulty difficulty;
  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.timer,
            label: l10n.timeTaken,
            value: _formatDuration(timeTaken),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: StatCard(
            icon: Icons.speed,
            label: l10n.levelLabel,
            value: difficulty.displayName,
            color: _getDifficultyColor(difficulty),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: StatCard(
            icon: Icons.category,
            label: l10n.modeLabel,
            value: mode.displayName,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
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
}

/// Individual stat card
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
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
