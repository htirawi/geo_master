import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/routes/routes.dart';
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
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openMap,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
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

        const SizedBox(height: 12),

        // Secondary CTA - Learn with AI
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accentColor, size: 20),
                  const SizedBox(width: 10),
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
