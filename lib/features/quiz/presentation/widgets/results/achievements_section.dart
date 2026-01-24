import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// New achievements section
class AchievementsSection extends StatelessWidget {
  const AchievementsSection({
    super.key,
    required this.achievements,
    required this.isArabic,
  });

  final List<String> achievements;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.achievement),
            const SizedBox(width: AppDimensions.xs),
            Text(
              l10n.newAchievements,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        ...achievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.xs),
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    _getAchievementName(achievement, l10n),
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

  String _getAchievementName(String achievement, AppLocalizations l10n) {
    final names = {
      'perfect_quiz': l10n.achievementPerfectQuiz,
      'marathon_master': l10n.achievementMarathonMaster,
      'daily_challenger': l10n.achievementDailyChallenger,
      'speed_demon': l10n.achievementSpeedDemon,
      'streak_master': l10n.achievementStreakMaster,
    };
    return names[achievement] ?? achievement;
  }
}
