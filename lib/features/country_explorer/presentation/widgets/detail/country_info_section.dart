import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_dimensions.dart';

/// Info item data class
class InfoItem {
  const InfoItem(this.label, this.value);
  final String label;
  final String value;
}

/// Reusable info section widget for displaying key-value pairs
class CountryInfoSection extends StatelessWidget {
  const CountryInfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
    required this.isArabic,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<InfoItem> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG + 4),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimensions.lg - 4, AppDimensions.md + 2, AppDimensions.lg - 4, AppDimensions.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.xs + 2),
                  ),
                  child: Icon(icon, size: AppDimensions.iconSM - 2, color: accentColor),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  title,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimensions.lg - 4, AppDimensions.xs, AppDimensions.lg - 4, AppDimensions.md),
            child: Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs + 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.label,
                              style: (isArabic
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Flexible(
                              child: Text(
                                item.value,
                                style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
