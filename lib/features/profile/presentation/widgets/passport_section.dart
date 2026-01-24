import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_dimensions.dart';

/// Passport section with items
class PassportSection extends StatelessWidget {
  const PassportSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.isArabic,
  });

  final String title;
  final IconData icon;
  final List<PassportItem> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: (isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ))
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((entry) => Column(
                      children: [
                        entry.value,
                        if (entry.key < items.length - 1)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: theme.dividerColor.withValues(alpha: 0.5),
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Passport item with icon and action
class PassportItem extends StatelessWidget {
  const PassportItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ))
                        .copyWith(color: theme.colorScheme.onSurface),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: (isArabic
                              ? GoogleFonts.cairo(fontSize: 13)
                              : GoogleFonts.poppins(fontSize: 13))
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(
              isArabic ? Icons.chevron_left : Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
