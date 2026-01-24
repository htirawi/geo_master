import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Performance analysis showing strong and weak areas
class PerformanceAnalysisSection extends StatelessWidget {
  const PerformanceAnalysisSection({
    super.key,
    required this.strongAreas,
    required this.weakAreas,
    required this.isArabic,
  });

  final List<String> strongAreas;
  final List<String> weakAreas;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.performanceAnalysis,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Strong areas
        if (strongAreas.isNotEmpty) ...[
          _AreaSection(
            title: l10n.strongAreas,
            areas: strongAreas,
            icon: Icons.check_circle,
            color: AppColors.success,
            isArabic: isArabic,
          ),
          const SizedBox(height: 12),
        ],
        // Weak areas
        if (weakAreas.isNotEmpty)
          _AreaSection(
            title: l10n.needsImprovement,
            areas: weakAreas,
            icon: Icons.trending_up,
            color: AppColors.warning,
            isArabic: isArabic,
          ),
      ],
    );
  }
}

class _AreaSection extends StatelessWidget {
  const _AreaSection({
    required this.title,
    required this.areas,
    required this.icon,
    required this.color,
    required this.isArabic,
  });

  final String title;
  final List<String> areas;
  final IconData icon;
  final Color color;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areas.map((area) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAreaDisplayName(area, l10n),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getAreaDisplayName(String area, AppLocalizations l10n) {
    final names = {
      'capitals': l10n.areaCapitals,
      'flags': l10n.areaFlags,
      'reverseFlags': l10n.areaReverseFlags,
      'maps': l10n.areaMaps,
      'population': l10n.areaPopulation,
      'currencies': l10n.areaCurrencies,
      'languages': l10n.areaLanguages,
      'borders': l10n.areaBorders,
      'timezones': l10n.areaTimezones,
    };
    return names[area] ?? area;
  }
}
