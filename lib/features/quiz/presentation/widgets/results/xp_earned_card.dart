import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../presentation/components/celebrations/animated_counter.dart';

/// XP earned card with multiplier info and animated counter
class XpEarnedCard extends ConsumerWidget {
  const XpEarnedCard({
    super.key,
    required this.xpEarned,
    required this.sessionType,
    required this.isArabic,
    this.animate = true,
  });

  final int xpEarned;
  final QuizSessionType sessionType;
  final bool isArabic;
  final bool animate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                  size: AppDimensions.iconXXL,
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
                    if (animate)
                      XpCounter(
                        value: xpEarned,
                        duration: const Duration(milliseconds: 1500),
                        playSound: true,
                        fontSize: 32,
                        showPlusSign: true,
                      )
                    else
                      Text(
                        '+$xpEarned XP',
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
            if (sessionType != QuizSessionType.standard) ...[
              const SizedBox(height: AppDimensions.sm),
              Container(
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  _getXpMultiplierText(sessionType, l10n),
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

  String _getXpMultiplierText(QuizSessionType sessionType, AppLocalizations l10n) {
    final multiplier = sessionType.xpMultiplier;
    return l10n.xpMultiplierInfo(
      '${multiplier}x',
      _getSessionTypeName(sessionType, l10n),
    );
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
