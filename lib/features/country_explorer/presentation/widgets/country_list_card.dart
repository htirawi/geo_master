import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Country List Card - Professional flag display with proper aspect ratio
///
/// Uses the design system's AppDimensions for consistent styling.
class CountryListCard extends StatelessWidget {
  const CountryListCard({
    super.key,
    required this.country,
    required this.isArabic,
    required this.index,
  });

  final Country country;
  final bool isArabic;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regionColor = _getRegionColor(country.region);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xxs + 2,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(Routes.countryDetail.replaceFirst(':code', country.code));
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppDimensions.borderRadiusXL,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: AppDimensions.blurMedium - 4,
                offset: const Offset(0, AppDimensions.xxs),
              ),
            ],
          ),
          child: Row(
            children: [
              // Flag Container - Proper aspect ratio with full flag display
              Container(
                width: 120,
                constraints: const BoxConstraints(minHeight: 90, maxHeight: 110),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    start: Radius.circular(AppDimensions.radiusXL),
                  ),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    start: Radius.circular(AppDimensions.radiusXL),
                  ),
                  child: Stack(
                    children: [
                      // Subtle gradient background for white flags
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[200]!,
                              Colors.grey[100]!,
                            ],
                          ),
                        ),
                      ),
                      // Professional flag display using country_flags package
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.xs),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CountryFlag.fromCountryCode(
                              country.code,
                              height: 56,
                              width: 84,
                            ),
                          ),
                        ),
                      ),
                      // Subtle border overlay for definition
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          borderRadius: const BorderRadiusDirectional.horizontal(
                            start: Radius.circular(AppDimensions.radiusXL),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md - 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Country name
                      Text(
                        country.getDisplayName(isArabic: isArabic),
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.xxs + 2),
                      // Capital with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: AppDimensions.iconXS - 2,
                            color: regionColor,
                          ),
                          const SizedBox(width: AppDimensions.xxs),
                          Expanded(
                            child: Text(
                              country.getDisplayCapital(isArabic: isArabic) ?? '-',
                              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.xxs + 2),
                      // Info chips - using Wrap for responsiveness
                      Wrap(
                        spacing: AppDimensions.xxs + 2,
                        runSpacing: AppDimensions.xxs,
                        children: [
                          _InfoChip(
                            label: country.formattedPopulation,
                            color: AppColors.primary,
                          ),
                          _InfoChip(
                            label: _getLocalizedRegion(l10n, country.region),
                            color: regionColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow indicator
              Container(
                margin: const EdgeInsetsDirectional.only(end: AppDimensions.sm),
                padding: const EdgeInsets.all(AppDimensions.sm - 2),
                decoration: BoxDecoration(
                  color: regionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  size: AppDimensions.iconXS - 2,
                  color: regionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 10)), duration: 300.ms);
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return AppColors.regionAfrica;
      case 'americas':
        return AppColors.regionAmericas;
      case 'asia':
        return AppColors.regionAsia;
      case 'europe':
        return AppColors.regionEurope;
      case 'oceania':
        return AppColors.regionOceania;
      default:
        return AppColors.primary;
    }
  }

  String _getLocalizedRegion(AppLocalizations l10n, String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return l10n.africa;
      case 'americas':
        return l10n.americas;
      case 'asia':
        return l10n.asia;
      case 'europe':
        return l10n.europe;
      case 'oceania':
        return l10n.oceania;
      default:
        return region;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xxs + 1,
        vertical: AppDimensions.xxs - 1,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
