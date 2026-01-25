import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';

/// Compass-style Quick Actions
///
/// Uses the design system's AppDimensions and HeaderGradients for consistency.
class CompassActions extends StatelessWidget {
  const CompassActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: CompassActionItem(
            icon: Icons.quiz_rounded,
            label: l10n.quickQuiz,
            color: AppColors.secondary,
            gradient: AppColors.sunsetGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(Routes.quiz);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: CompassActionItem(
            icon: Icons.explore_rounded,
            label: l10n.explore,
            color: AppColors.tertiary,
            gradient: HeaderGradients.atlas,
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(Routes.explore);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: CompassActionItem(
            icon: Icons.smart_toy_rounded,
            label: l10n.aiTutor,
            color: AppColors.primary,
            gradient: HeaderGradients.explorer,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(Routes.aiTutor);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: CompassActionItem(
            icon: Icons.emoji_events_rounded,
            label: l10n.achievements,
            color: AppColors.xpGold,
            gradient: HeaderGradients.achievement,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(Routes.achievements);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual compass action item
class CompassActionItem extends StatelessWidget {
  const CompassActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.lg),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: AppDimensions.blurLight,
              offset: const Offset(0, AppDimensions.xxs),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: AppDimensions.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
