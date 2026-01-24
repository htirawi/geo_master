import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Currencies section displaying all used currencies
class CountryCurrenciesSection extends StatelessWidget {
  const CountryCurrenciesSection({
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

    if (country.currencies.isEmpty) {
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
                  color: AppColors.xpGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.xs + 2),
                ),
                child: const Icon(Icons.payments_rounded,
                    size: AppDimensions.iconSM - 2, color: AppColors.xpGold),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                l10n.currencies,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...country.currencies.map((currency) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: Row(
                  children: [
                    Container(
                      width: AppDimensions.avatarMD,
                      height: AppDimensions.avatarMD,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.name,
                            style: (isArabic
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currency.code,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
