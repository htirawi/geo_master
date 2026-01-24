import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(Routes.countryDetail.replaceFirst(':code', country.code));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    const BorderRadius.vertical(top: Radius.circular(20)),
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
                    // Flag image - contain to show full flag
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: CachedNetworkImage(
                        imageUrl: country.flagUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Center(
                          child: Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    // Subtle inner shadow for depth
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    // Region badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: regionColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: regionColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getRegionIcon(country.region),
                          size: 14,
                          color: Colors.white,
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      country.getDisplayName(isArabic: isArabic),
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: regionColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            country.getDisplayCapital(isArabic: isArabic) ?? '-',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 10)), duration: 300.ms).scale(
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
