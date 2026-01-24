import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../domain/entities/country.dart';

/// Country name, capital, region tag and code display
class CountryHeader extends StatelessWidget {
  const CountryHeader({
    super.key,
    required this.country,
    required this.isArabic,
    required this.accentColor,
  });

  final Country country;
  final bool isArabic;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Country Name
        Text(
          country.getDisplayName(isArabic: isArabic),
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Capital City
        if (country.capital != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                country.getDisplayCapital(isArabic: isArabic) ?? '',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Region Tag & Country Code
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Region Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRegionIcon(country.region),
                    size: 14,
                    color: accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    country.getDisplayRegion(isArabic: isArabic),
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Country Code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                country.code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny_rounded;
      case 'americas':
        return Icons.landscape_rounded;
      case 'asia':
        return Icons.temple_buddhist_rounded;
      case 'europe':
        return Icons.castle_rounded;
      case 'oceania':
        return Icons.waves_rounded;
      default:
        return Icons.public_rounded;
    }
  }
}
