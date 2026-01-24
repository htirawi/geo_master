import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Score card with animated progress
class ResultScoreCard extends StatelessWidget {
  const ResultScoreCard({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.animationValue,
    required this.isArabic,
  });

  final int score;
  final int totalQuestions;
  final double accuracy;
  final double animationValue;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final displayScore = (score * animationValue).round();

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
                    color: _getScoreColor(accuracy),
                  ),
                ),
                Text(
                  ' / $totalQuestions',
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
                value: accuracy / 100 * animationValue,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                color: _getScoreColor(accuracy),
                minHeight: AppDimensions.progressBarHeight * 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              '${(accuracy * animationValue).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(accuracy),
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
}
