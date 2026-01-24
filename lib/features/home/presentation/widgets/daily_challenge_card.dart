import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/user_preferences_provider.dart'
    show LocalLearningPreferences, localLearningPreferencesProvider;

/// Daily Challenge Card with adventure theme - personalized based on user interests
class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  /// Get quiz mode based on user interests
  String _getPreferredQuizMode(LocalLearningPreferences prefs) {
    // Priority order based on what user selected
    if (prefs.isInterestedIn('flags')) return 'flags';
    if (prefs.isInterestedIn('capitals')) return 'capitals';
    if (prefs.isInterestedIn('geography')) return 'geography';
    if (prefs.isInterestedIn('culture')) return 'culture';
    if (prefs.isInterestedIn('languages')) return 'languages';
    if (prefs.isInterestedIn('history')) return 'history';
    // Default if no interests selected
    return 'capitals';
  }

  /// Get difficulty string from user preferences
  String _getDifficulty(LocalLearningPreferences prefs) {
    return prefs.difficulty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userPrefs = ref.watch(localLearningPreferencesProvider);
    final quizMode = _getPreferredQuizMode(userPrefs);
    final difficulty = _getDifficulty(userPrefs);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Challenge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.xpGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.dailyChallenge,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.dailyChallengeDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+100 XP',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Start button - uses personalized quiz mode and difficulty
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('${Routes.quizGame}?mode=$quizMode&difficulty=$difficulty');
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF6A1B9A),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
