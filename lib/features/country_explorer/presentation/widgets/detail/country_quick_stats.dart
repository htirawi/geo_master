import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Quick stats row showing population, area, and timezone
class CountryQuickStats extends StatelessWidget {
  const CountryQuickStats({
    super.key,
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xxs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG + 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: QuickStatItem(
              icon: Icons.groups_rounded,
              label: l10n.population,
              value: country.formattedPopulation,
              isArabic: isArabic,
            ),
          ),
          Container(
            width: 1,
            height: AppDimensions.avatarSM + 8,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: QuickStatItem(
              icon: Icons.square_foot_rounded,
              label: l10n.area,
              value: country.formattedArea,
              isArabic: isArabic,
            ),
          ),
          Container(
            width: 1,
            height: AppDimensions.avatarSM + 8,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: QuickStatItem(
              icon: Icons.schedule_rounded,
              label: l10n.timezones,
              value: country.timezones.isNotEmpty
                  ? country.timezones.first.replaceAll('UTC', '')
                  : '-',
              isArabic: isArabic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Stat Item Widget
class QuickStatItem extends StatelessWidget {
  const QuickStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isArabic,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm, horizontal: AppDimensions.xs),
      child: Column(
        children: [
          Icon(icon, size: AppDimensions.iconSM, color: Colors.grey[600]),
          const SizedBox(height: AppDimensions.xxs + 2),
          Text(
            value,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
