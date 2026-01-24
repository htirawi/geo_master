import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Traveler stats card showing exploration progress
class TravelerStatsCard extends StatelessWidget {
  const TravelerStatsCard({
    super.key,
    required this.isArabic,
    required this.countriesLearned,
    required this.achievementsCount,
    required this.currentStreak,
  });

  final bool isArabic;
  final int countriesLearned;
  final int achievementsCount;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiary,
            AppColors.tertiaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.journeyStats,
                style: (isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ))
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.public,
                  value: '$countriesLearned',
                  label: l10n.countriesVisited,
                  isArabic: isArabic,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.emoji_events,
                  value: '$achievementsCount',
                  label: l10n.achievements,
                  isArabic: isArabic,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department,
                  value: '$currentStreak',
                  label: l10n.dayStreakLabel,
                  isArabic: isArabic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isArabic,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: (isArabic
                  ? GoogleFonts.cairo(fontSize: 11)
                  : GoogleFonts.poppins(fontSize: 11))
              .copyWith(color: Colors.white.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
