import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Languages section displaying all spoken languages
class CountryLanguagesSection extends StatelessWidget {
  const CountryLanguagesSection({
    super.key,
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (country.languages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg - 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG + 4),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.xs + 2),
                ),
                child: const Icon(Icons.translate_rounded,
                    size: AppDimensions.iconSM - 2, color: AppColors.tertiary),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                l10n.languages,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.xs,
            runSpacing: AppDimensions.xs,
            children: country.languages
                .map((lang) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm + 2, vertical: AppDimensions.xs),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Text(
                        lang,
                        style:
                            (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
