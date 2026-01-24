import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
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
        ...achievements.map((achievement) {
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
