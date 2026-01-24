import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Expedition upgrade card for premium subscription
class ExpeditionUpgradeCard extends StatelessWidget {
  const ExpeditionUpgradeCard({
    super.key,
    required this.isArabic,
    required this.onTap,
  });

  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusXL,
        child: Ink(
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: AppDimensions.borderRadiusXL,
            boxShadow: [
              BoxShadow(
                color: AppColors.premium.withValues(alpha: 0.3),
                blurRadius: AppDimensions.blurMedium - 1,
                offset: const Offset(0, AppDimensions.xxs + 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: AppDimensions.iconLG - 4,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.upgradeToPremium,
                      style: (isArabic
                              ? GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
                              : GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ))
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppDimensions.xxs),
                    Text(
                      l10n.unlockAllFeatures,
                      style: (isArabic
                              ? GoogleFonts.cairo(fontSize: 12)
                              : GoogleFonts.poppins(fontSize: 12))
                          .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm - 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  l10n.upgrade,
                  style: (isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ))
                      .copyWith(color: AppColors.premium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
