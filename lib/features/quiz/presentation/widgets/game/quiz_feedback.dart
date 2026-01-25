import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Quiz feedback section showing result and explanation
class QuizFeedbackSection extends StatelessWidget {
  const QuizFeedbackSection({
    super.key,
    required this.question,
    required this.isCorrect,
    required this.speedBonus,
    required this.xpEarned,
    required this.scaleAnimation,
    required this.isArabic,
  });

  final QuizQuestion question;
  final bool isCorrect;
  final double? speedBonus;
  final int? xpEarned;
  final Animation<double> scaleAnimation;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final explanation = isArabic && question.explanationArabic != null
        ? question.explanationArabic!
        : question.explanation;
    final funFact = isArabic && question.funFactArabic != null
        ? question.funFactArabic!
        : question.funFact;

    return ScaleTransition(
      scale: scaleAnimation,
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
                  size: AppDimensions.iconXL,
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
                              color:
                                  isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                          // Speed bonus badge
                          if (isCorrect && speedBonus != null && speedBonus! > 1.0)
                            Container(
                              margin: const EdgeInsets.only(left: AppDimensions.xs),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.xs,
                                vertical: AppDimensions.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.xpGold,
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusSM),
                              ),
                              child: Text(
                                '${speedBonus!.toStringAsFixed(1)}x',
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
                          l10n.theAnswerWas(question.getDisplayCorrectAnswer(isArabic: isArabic)),
                          style: theme.textTheme.bodyMedium,
                        ),
                      // XP earned
                      if (xpEarned != null && xpEarned! > 0)
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
                      const Icon(Icons.school, size: AppDimensions.iconSM),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        l10n.explanation,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
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
                        size: AppDimensions.iconSM,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppDimensions.xs),
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
                  const SizedBox(height: AppDimensions.xs),
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
}
