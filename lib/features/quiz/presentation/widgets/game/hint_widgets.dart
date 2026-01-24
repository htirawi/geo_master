import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Hint button widget
class HintButton extends StatelessWidget {
  const HintButton({
    super.key,
    required this.onPressed,
    required this.isArabic,
  });

  final VoidCallback onPressed;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.lightbulb_outline, size: AppDimensions.iconSM),
        label: Text(
          l10n.useHint,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.xpGold,
          side: const BorderSide(color: AppColors.xpGold),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

/// Hint display card widget
class HintDisplay extends StatelessWidget {
  const HintDisplay({
    super.key,
    required this.hint,
  });

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.xpGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb,
            color: AppColors.xpGold,
            size: AppDimensions.iconSM,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              hint,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.xpGold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
}
