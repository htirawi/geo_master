import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';

/// Today's Destination - Featured Country Card
class TodaysDestinationCard extends ConsumerWidget {
  const TodaysDestinationCard({super.key, required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryAsync = ref.watch(countryOfTheDayProvider);

    return countryAsync.when(
      data: (country) {
        if (country == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.countryDetailPath(country.code));
          },
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Flag background with gradient overlay
                  CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.primary),
                    errorWidget: (_, __, ___) => Container(color: AppColors.primary),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label - positioned at top right for RTL support
                        Align(
                          alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.sunrise,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pin_drop, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.countryOfTheDay,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Country name and info with arrow
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Country info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.getDisplayName(isArabic: isArabic),
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.people,
                                        color: Colors.white.withValues(alpha: 0.8), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        country.formattedPopulation,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.location_on,
                                        color: Colors.white.withValues(alpha: 0.8), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        country.getDisplayRegion(isArabic: isArabic),
                                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                          fontSize: 14,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Explore arrow - now part of the row, not overlapping
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isArabic ? Icons.arrow_back : Icons.arrow_forward,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
