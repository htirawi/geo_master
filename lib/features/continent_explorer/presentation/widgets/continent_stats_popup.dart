import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/continent.dart';
import '../../../../presentation/providers/continent_provider.dart';

/// Quick stats popup for a continent (shown on long press)
class ContinentStatsPopup extends ConsumerWidget {
  const ContinentStatsPopup({
    super.key,
    required this.continent,
    this.onExplore,
    this.onClose,
  });

  final Continent continent;
  final VoidCallback? onExplore;
  final VoidCallback? onClose;

  static Future<void> show(
    BuildContext context, {
    required Continent continent,
    VoidCallback? onExplore,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ContinentStatsPopup(
          continent: continent,
          onExplore: () {
            Navigator.of(context).pop();
            onExplore?.call();
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final statsAsync = ref.watch(continentStatsProvider(continent.id));

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        continent.getDisplayName(isArabic: isArabic),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? '${continent.countryCodes.length} دولة'
                            : '${continent.countryCodes.length} Countries',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surface.withValues(alpha: 0.3),
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Stats content
          statsAsync.when(
            data: (stats) => _buildStatsContent(context, theme, stats, isArabic),
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => _buildStatsContent(
              context,
              theme,
              const ContinentStats(
                totalCountries: 0,
                exploredCountries: 0,
                completedCountries: 0,
                totalXp: 0,
              ),
              isArabic,
            ),
          ),

          // Explore button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onExplore,
                icon: const Icon(Icons.explore),
                label: Text(
                  isArabic ? 'استكشف القارة' : 'Explore Continent',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    ThemeData theme,
    ContinentStats stats,
    bool isArabic,
  ) {
    final progressValue = stats.explorationProgress / 100;
    final progressPercent = stats.explorationProgress.toInt();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress row
          _StatRow(
            icon: Icons.explore,
            iconColor: const Color(0xFF4CAF50),
            label: isArabic ? 'مستكشفة' : 'Explored',
            value: '${stats.exploredCountries}/${stats.totalCountries}',
            subValue: '$progressPercent%',
          ),
          const SizedBox(height: 16),

          // XP row
          _StatRow(
            icon: Icons.star,
            iconColor: Colors.amber,
            label: isArabic ? 'نقاط الخبرة' : 'XP Earned',
            value: '${stats.totalXp}',
            subValue: 'XP',
          ),
          const SizedBox(height: 16),

          // Completed row
          _StatRow(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF2196F3),
            label: isArabic ? 'مكتملة' : 'Completed',
            value: '${stats.completedCountries}',
            subValue: isArabic ? 'دولة' : 'countries',
          ),
          const SizedBox(height: 16),

          // Favorites row
          _StatRow(
            icon: Icons.favorite,
            iconColor: const Color(0xFFE91E63),
            label: isArabic ? 'المفضلة' : 'Favorites',
            value: '${stats.favoriteCountries}',
            subValue: isArabic ? 'دولة' : 'countries',
          ),
          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'التقدم الكلي' : 'Overall Progress',
                    style: theme.textTheme.labelMedium,
                  ),
                  Text(
                    '$progressPercent%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subValue,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          subValue,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet version for mobile
class ContinentStatsBottomSheet extends ConsumerWidget {
  const ContinentStatsBottomSheet({
    super.key,
    required this.continent,
    this.onExplore,
  });

  final Continent continent;
  final VoidCallback? onExplore;

  static Future<void> show(
    BuildContext context, {
    required Continent continent,
    VoidCallback? onExplore,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContinentStatsBottomSheet(
        continent: continent,
        onExplore: () {
          Navigator.of(context).pop();
          onExplore?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final statsAsync = ref.watch(continentStatsProvider(continent.id));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Icon(
                    Icons.public,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          continent.getDisplayName(isArabic: isArabic),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isArabic
                              ? '${continent.countryCodes.length} دولة'
                              : '${continent.countryCodes.length} countries',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats content
              statsAsync.when(
                data: (stats) =>
                    _buildBottomSheetStats(context, theme, stats, isArabic),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => _buildBottomSheetStats(
                  context,
                  theme,
                  const ContinentStats(
                    totalCountries: 0,
                    exploredCountries: 0,
                    completedCountries: 0,
                    totalXp: 0,
                  ),
                  isArabic,
                ),
              ),
              const SizedBox(height: 24),

              // Explore button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.explore),
                  label: Text(
                    isArabic ? 'استكشف القارة' : 'Explore Continent',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetStats(
    BuildContext context,
    ThemeData theme,
    ContinentStats stats,
    bool isArabic,
  ) {
    final progressValue = stats.explorationProgress / 100;
    final progressPercent = stats.explorationProgress.toInt();

    return Column(
      children: [
        // Stats grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomSheetStat(
              icon: Icons.explore,
              value: '${stats.exploredCountries}',
              label: isArabic ? 'مستكشفة' : 'Explored',
              color: const Color(0xFF4CAF50),
            ),
            _BottomSheetStat(
              icon: Icons.star,
              value: '${stats.totalXp}',
              label: 'XP',
              color: Colors.amber,
            ),
            _BottomSheetStat(
              icon: Icons.check_circle,
              value: '${stats.completedCountries}',
              label: isArabic ? 'مكتملة' : 'Completed',
              color: const Color(0xFF2196F3),
            ),
            _BottomSheetStat(
              icon: Icons.favorite,
              value: '${stats.favoriteCountries}',
              label: isArabic ? 'مفضلة' : 'Favorites',
              color: const Color(0xFFE91E63),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'التقدم' : 'Progress',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomSheetStat extends StatelessWidget {
  const _BottomSheetStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
