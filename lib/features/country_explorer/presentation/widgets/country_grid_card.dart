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

/// Country Grid Card - Professional flag display with proper aspect ratio
class CountryGridCard extends StatelessWidget {
  const CountryGridCard({
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
    final regionColor = _getRegionColor(country.region);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final countryName = country.getDisplayName(isArabic: isArabic);
    final capital = country.getDisplayCapital(isArabic: isArabic);

    final Widget card = Semantics(
      button: true,
      label: '$countryName, ${country.region}${capital != null ? ', capital: $capital' : ''}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(Routes.countryDetail.replaceFirst(':code', country.code));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppDimensions.borderRadiusXL,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: AppDimensions.blurMedium - 4,
                offset: const Offset(0, AppDimensions.xxs),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Flag Container - Proper display with full flag visible
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background for white flags
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
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          child: Semantics(
                            image: true,
                            label: 'Flag of $countryName',
                            excludeSemantics: true,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CountryFlag.fromCountryCode(
                                country.code,
                                height: 64,
                                width: 96,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Subtle inner shadow for depth
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      // Region badge
                      Positioned(
                        top: AppDimensions.xs,
                        right: AppDimensions.xs,
                        child: Semantics(
                          label: '${country.region} region',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.xs,
                              vertical: AppDimensions.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: regionColor,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                              boxShadow: [
                                BoxShadow(
                                  color: regionColor.withValues(alpha: 0.3),
                                  blurRadius: AppDimensions.xxs,
                                  offset: const Offset(0, AppDimensions.xxs / 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getRegionIcon(country.region),
                              size: AppDimensions.iconXS - 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          countryName,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxs),
                      ExcludeSemantics(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: AppDimensions.sm,
                              color: regionColor,
                            ),
                            const SizedBox(width: AppDimensions.xxs),
                            Expanded(
                              child: Text(
                                capital ?? '-',
                                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (reduceMotion) {
      return card;
    }

    return card.animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 10)), duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 50 * (index % 10)),
          duration: 300.ms,
        );
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

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny;
      case 'americas':
        return Icons.landscape;
      case 'asia':
        return Icons.temple_buddhist;
      case 'europe':
        return Icons.castle;
      case 'oceania':
        return Icons.waves;
      default:
        return Icons.public;
    }
  }
}
