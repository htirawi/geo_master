import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/cards/explorer_card.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/user_provider.dart';
import 'week_progress_bar.dart';
import 'mini_stat_item.dart';

/// Expedition Progress Card - Streak + Stats
///
/// Uses the ExplorerCard component for consistent card styling.
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

    return ExplorerCard.elevated(
      padding: const EdgeInsets.all(AppDimensions.lg),
      borderRadius: AppDimensions.borderRadiusXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm - 2),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD + 2),
                ),
                child: const Icon(Icons.local_fire_department,
                  color: AppColors.streak, size: AppDimensions.iconMD),
              ),
              const SizedBox(width: AppDimensions.sm),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.streak, Color(0xFFFF8A65)],
                  ),
                  borderRadius: AppDimensions.borderRadiusLG,
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
                    const SizedBox(width: AppDimensions.xxs),
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
          const SizedBox(height: AppDimensions.lg),
          // Week progress visualization
          WeekProgressBar(streak: streak),
          const SizedBox(height: AppDimensions.lg),
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
