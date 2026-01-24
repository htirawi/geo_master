import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Perfect score celebration banner
class PerfectScoreBanner extends StatelessWidget {
  const PerfectScoreBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: AppDimensions.iconSM),
          const SizedBox(width: AppDimensions.xs),
          Text(
            l10n.perfectScoreTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: AppDimensions.xs),
          const Icon(Icons.star, color: Colors.white, size: AppDimensions.iconSM),
        ],
      ),
    );
  }
}
