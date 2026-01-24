import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Grade display badge
class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
    required this.grade,
  });

  final String grade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _getGradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        _getGradeDisplay(grade, l10n),
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getGradeDisplay(String grade, AppLocalizations l10n) {
    switch (grade) {
      case 'A+':
        return l10n.gradeExcellentPlus;
      case 'A':
        return l10n.gradeExcellent;
      case 'B':
        return l10n.gradeVeryGood;
      case 'C':
        return l10n.gradeGood;
      case 'D':
        return l10n.gradePass;
      default:
        return l10n.gradeFail;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return AppColors.xpGold;
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.primary;
      case 'C':
        return AppColors.warning;
      case 'D':
        return Colors.orange;
      default:
        return AppColors.error;
    }
  }
}
