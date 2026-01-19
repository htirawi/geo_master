import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/map_style.dart';

/// Map legend showing progress color meanings
class MapLegend extends ConsumerWidget {
  const MapLegend({
    super.key,
    this.isExpanded = false,
    this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'دليل الألوان' : 'Legend',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),

                // Legend items
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  _LegendItem(
                    color: const Color(ProgressColors.completed),
                    label: isArabic ? 'مكتمل (100%)' : 'Completed (100%)',
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: const Color(ProgressColors.inProgress),
                    label: isArabic ? 'قيد التقدم (50-99%)' : 'In Progress (50-99%)',
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: const Color(ProgressColors.started),
                    label: isArabic ? 'بدأت (1-49%)' : 'Started (1-49%)',
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: const Color(ProgressColors.notStarted),
                    label: isArabic ? 'لم يبدأ (0%)' : 'Not Started (0%)',
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: const Color(ProgressColors.favorite),
                    icon: Icons.favorite,
                    label: isArabic ? 'المفضلة' : 'Favorites',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.icon,
  });

  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: color)
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Compact legend for smaller screens
class CompactMapLegend extends StatelessWidget {
  const CompactMapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactLegendDot(color: Color(ProgressColors.completed)),
          _CompactLegendDot(color: Color(ProgressColors.inProgress)),
          _CompactLegendDot(color: Color(ProgressColors.started)),
          _CompactLegendDot(color: Color(ProgressColors.notStarted)),
        ],
      ),
    );
  }
}

class _CompactLegendDot extends StatelessWidget {
  const _CompactLegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Stats bar showing exploration statistics
class MapStatsBar extends ConsumerWidget {
  const MapStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            isArabic ? 'استكشف العالم' : 'Explore the World',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
