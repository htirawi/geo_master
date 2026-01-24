import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Compass-style Quick Actions
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
        const SizedBox(width: 12),
        Expanded(
          child: CompassActionItem(
            icon: Icons.explore_rounded,
            label: l10n.explore,
            color: AppColors.tertiary,
            gradient: AppColors.forestGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(Routes.explore);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CompassActionItem(
            icon: Icons.smart_toy_rounded,
            label: l10n.aiTutor,
            color: AppColors.primary,
            gradient: AppColors.oceanGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(Routes.aiTutor);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CompassActionItem(
            icon: Icons.emoji_events_rounded,
            label: l10n.achievements,
            color: AppColors.xpGold,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8F00), Color(0xFFFFD54F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
