import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import 'lives_display.dart';

/// Quiz game header with progress, lives, and score
class QuizGameHeader extends StatelessWidget {
  const QuizGameHeader({
    super.key,
    required this.quiz,
    required this.progress,
    required this.isArabic,
    required this.onClose,
  });

  final Quiz quiz;
  final double progress;
  final bool isArabic;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
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
                          _getSessionTypeName(quiz.sessionType, l10n),
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
                LivesDisplay(lives: quiz.livesRemaining!),
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

  String _getSessionTypeName(QuizSessionType sessionType, AppLocalizations l10n) {
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
