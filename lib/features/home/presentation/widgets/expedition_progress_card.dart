import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import 'week_progress_bar.dart';
import 'mini_stat_item.dart';

/// Expedition Progress Card - Streak + Stats
class ExpeditionProgressCard extends ConsumerWidget {
  const ExpeditionProgressCard({super.key});

  /// Get first name from user
  String _getFirstName(String? fullName, AppLocalizations l10n) {
    if (fullName == null || fullName.isEmpty) {
      return l10n.guest;
    }
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(userProgressProvider);
    final streak = progress.currentStreak;
    final user = ref.watch(currentUserProvider);
    final firstName = _getFirstName(user?.displayName, l10n);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department,
                  color: AppColors.streak, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expeditionStreak,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      streak > 0
                          ? l10n.motivationalStreak(firstName)
                          : l10n.startStreak,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Streak number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.streak, Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.days,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Week progress visualization
          WeekProgressBar(streak: streak),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              MiniStatItem(
                icon: Icons.public,
                value: '${progress.countriesLearned}',
                label: l10n.countriesLabel,
                color: AppColors.primary,
              ),
              MiniStatItem(
                icon: Icons.quiz,
                value: '${progress.quizzesCompleted}',
                label: l10n.quizzesLabel,
                color: AppColors.tertiary,
              ),
              MiniStatItem(
                icon: Icons.star,
                value: _formatXp(progress.totalXp),
                label: l10n.xpLabel,
                color: AppColors.xpGold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
