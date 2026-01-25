import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';

/// Passport Header with stamps pattern
class PassportHeader extends StatelessWidget {
  const PassportHeader({
    super.key,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.isPremium,
    required this.isArabic,
  });

  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.passport,
      ),
      child: Stack(
        children: [
          // Passport stamps pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PassportStampsPainter(),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm - 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                        child: const Icon(
                          Icons.badge,
                          color: Colors.white,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.passportTitle,
                              style: (isArabic
                                      ? GoogleFonts.cairo(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ))
                                  .copyWith(color: Colors.white),
                            ),
                            Text(
                              l10n.travelerIdSubtitle,
                              style: (isArabic
                                      ? GoogleFonts.cairo(fontSize: 12)
                                      : GoogleFonts.poppins(fontSize: 12))
                                  .copyWith(
                                      color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  // Passport Card
                  _PassportCard(
                    displayName: displayName,
                    email: email,
                    photoUrl: photoUrl,
                    isPremium: isPremium,
                    isArabic: isArabic,
                  )
                      .animate()
                      .fadeIn(duration: AppDimensions.durationSlow + 200.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  const SizedBox(height: AppDimensions.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportCard extends StatelessWidget {
  const _PassportCard({
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.isPremium,
    required this.isArabic,
  });

  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors for the passport card
    final cardBackground = isDark ? AppColors.surfaceDark : Colors.white;
    final photoBackground = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final tertiaryTextColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.3),
            blurRadius: AppDimensions.blurHeavy - 4,
            offset: const Offset(0, AppDimensions.sm - 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo
          Stack(
            children: [
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: photoBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                  image: photoUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: AppDimensions.iconXL + 8,
                        color: tertiaryTextColor,
                      )
                    : null,
              ),
              if (isPremium)
                Positioned(
                  right: -AppDimensions.xxs,
                  bottom: -AppDimensions.xxs,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.xxs),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: AppDimensions.iconXS - 2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.travelerName.toUpperCase(),
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: tertiaryTextColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: (isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ))
                      .copyWith(color: primaryTextColor),
                ),
                const SizedBox(height: AppDimensions.xs),
                if (email != null) ...[
                  Text(
                    l10n.contactEmail.toUpperCase(),
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: tertiaryTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppDimensions.xs),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm - 2,
                      vertical: AppDimensions.xxs,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.xxs),
                    ),
                    child: Text(
                      l10n.premiumExplorer.toUpperCase(),
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.robotoMono)(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: isArabic ? 0 : 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for passport stamps pattern
class _PassportStampsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final random = math.Random(42);

    // Draw circular stamps
    for (var i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 30;

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x, y), radius - 5, paint);
    }

    // Draw some rectangular stamps
    for (var i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final w = 40 + random.nextDouble() * 40;
      final h = 25 + random.nextDouble() * 20;
      final rotation = random.nextDouble() * 0.5 - 0.25;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(4),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
