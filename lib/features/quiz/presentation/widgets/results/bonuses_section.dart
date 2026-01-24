import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Bonuses and penalties section
class BonusesSection extends StatelessWidget {
  const BonusesSection({
    super.key,
    required this.streakBonus,
    required this.speedBonus,
    required this.hintsUsed,
    required this.perfectStreak,
  });

  final double streakBonus;
  final double speedBonus;
  final int hintsUsed;
  final int perfectStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bonuses = <Widget>[];

    // Streak bonus (> 1.0 means there's a bonus)
    if (streakBonus > 1.0) {
      bonuses.add(BonusChip(
        icon: Icons.local_fire_department,
        label: l10n.streakBonus,
        value: '${streakBonus.toStringAsFixed(1)}x',
        color: AppColors.xpGold,
      ));
    }

    // Speed bonus (> 1.0 means there's a bonus)
    if (speedBonus > 1.0) {
      bonuses.add(BonusChip(
        icon: Icons.bolt,
        label: l10n.speedBonus,
        value: '${speedBonus.toStringAsFixed(1)}x',
        color: AppColors.success,
      ));
    }

    // Hints used penalty
    if (hintsUsed > 0) {
      bonuses.add(BonusChip(
        icon: Icons.lightbulb,
        label: l10n.hintsLabel,
        value: '-${hintsUsed * 5}',
        color: AppColors.warning,
        isNegative: true,
      ));
    }

    // Perfect streak bonus
    if (perfectStreak > 3) {
      bonuses.add(BonusChip(
        icon: Icons.whatshot,
        label: l10n.perfectStreakLabel,
        value: '$perfectStreak',
        color: AppColors.error,
      ));
    }

    if (bonuses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bonusesAndPenalties,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Wrap(
          spacing: AppDimensions.xs,
          runSpacing: AppDimensions.xs,
          children: bonuses,
        ),
      ],
    );
  }
}

/// Individual bonus chip
class BonusChip extends StatelessWidget {
  const BonusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isNegative = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs - 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconXS, color: color),
          const SizedBox(width: AppDimensions.xs - 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
            ),
          ),
          const SizedBox(width: AppDimensions.xs - 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.xs - 2,
              vertical: AppDimensions.xxs,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
