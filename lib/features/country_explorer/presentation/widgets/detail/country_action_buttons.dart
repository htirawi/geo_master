import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/routes/routes.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Action buttons for country detail (View on Map, Learn More)
class CountryActionButtons extends StatelessWidget {
  const CountryActionButtons({
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
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Primary CTA - View on Map
        Container(
          width: double.infinity,
          height: AppDimensions.buttonHeightLG,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: AppDimensions.lg - 4,
                offset: const Offset(0, AppDimensions.xs),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openMap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, color: Colors.white, size: AppDimensions.iconMD - 2),
                  const SizedBox(width: AppDimensions.xs + 2),
                  Text(
                    l10n.viewOnMap,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.sm),

        // Secondary CTA - Learn with AI
        Container(
          width: double.infinity,
          height: AppDimensions.buttonHeightLG - 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('${Routes.aiTutor}?country=${country.code}');
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accentColor, size: AppDimensions.iconSM),
                  const SizedBox(width: AppDimensions.xs + 2),
                  Text(
                    l10n.learnMore,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openMap() async {
    final lat = country.coordinates.latitude;
    final lng = country.coordinates.longitude;
    final url = Uri.parse('https://www.google.com/maps/@$lat,$lng,6z');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
