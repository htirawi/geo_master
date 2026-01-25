import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/user_stats.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';
import '../../../../presentation/providers/user_stats_provider.dart';

/// Stats dashboard screen with detailed analytics
class StatsDashboardScreen extends ConsumerWidget {
  const StatsDashboardScreen({super.key});

  // Mock user ID for demo
  static const _userId = 'current_user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final userStats = ref.watch(userStatsProvider(_userId));

    return Scaffold(
      body: userStats.when(
        data: (stats) => CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _StatsHeader(isArabic: isArabic),
            ),
            // Stats summary
            SliverToBoxAdapter(
              child: _StatsSummarySection(stats: stats, isArabic: isArabic),
            ),
            // Activity heatmap
            SliverToBoxAdapter(
              child: _ActivityHeatmapSection(
                activities: stats.activityHistory,
                isArabic: isArabic,
              ),
            ),
            // Accuracy by category
            SliverToBoxAdapter(
              child: _AccuracySection(stats: stats, isArabic: isArabic),
            ),
            // Weak areas
            if (stats.weakAreas.isNotEmpty)
              SliverToBoxAdapter(
                child: _WeakAreasSection(
                  weakAreas: stats.weakAreas,
                  isArabic: isArabic,
                ),
              ),
            // Strong areas
            if (stats.strongAreas.isNotEmpty)
              SliverToBoxAdapter(
                child: _StrongAreasSection(
                  strongAreas: stats.strongAreas,
                  isArabic: isArabic,
                ),
              ),
            // Countries by continent
            SliverToBoxAdapter(
              child: _ContinentProgressSection(
                countriesPerContinent: stats.countriesPerContinent,
                isArabic: isArabic,
              ),
            ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.xl),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// Stats header
class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.explorer,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: responsive.insets(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    l10n.statsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.analytics,
                    color: Colors.white70,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                l10n.statsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats summary section
class _StatsSummarySection extends StatelessWidget {
  const _StatsSummarySection({
    required this.stats,
    required this.isArabic,
  });

  final UserStats stats;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsOverview,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.sm,
            mainAxisSpacing: AppDimensions.sm,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.star,
                iconColor: AppColors.xpGold,
                label: l10n.totalXp,
                value: '${stats.totalXp}',
              ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.1, end: 0),
              _StatCard(
                icon: Icons.trending_up,
                iconColor: AppColors.success,
                label: l10n.level,
                value: '${stats.level}',
              ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0),
              _StatCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                label: l10n.currentStreak,
                value: '${stats.currentStreak} ${l10n.daysShort}',
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
              _StatCard(
                icon: Icons.check_circle,
                iconColor: AppColors.primary,
                label: l10n.accuracy,
                value: '${(stats.accuracy * 100).toStringAsFixed(1)}%',
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
              _StatCard(
                icon: Icons.quiz,
                iconColor: Colors.purple,
                label: l10n.quizzesCompleted,
                value: '${stats.totalQuizzes}',
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              _StatCard(
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                label: l10n.perfectScores,
                value: '${stats.perfectScores}',
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: AppDimensions.xs),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity heatmap section
class _ActivityHeatmapSection extends StatelessWidget {
  const _ActivityHeatmapSection({
    required this.activities,
    required this.isArabic,
  });

  final List<DailyActivity> activities;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    // Generate last 12 weeks of activity data
    final now = DateTime.now();
    final activityMap = <DateTime, int>{};
    for (final activity in activities) {
      final dateOnly = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      activityMap[dateOnly] = activity.intensityLevel;
    }

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.activityHistory,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: [
                  // Heatmap grid
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: 84, // 12 weeks
                      itemBuilder: (context, index) {
                        final date = now.subtract(Duration(days: 83 - index));
                        final dateOnly =
                            DateTime(date.year, date.month, date.day);
                        final intensity = activityMap[dateOnly] ?? 0;

                        return Container(
                          decoration: BoxDecoration(
                            color: _getIntensityColor(intensity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        l10n.less,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      for (var i = 0; i <= 4; i++)
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _getIntensityColor(i),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.more,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.primary.withValues(alpha: 0.1);
      case 1:
        return AppColors.primary.withValues(alpha: 0.3);
      case 2:
        return AppColors.primary.withValues(alpha: 0.5);
      case 3:
        return AppColors.primary.withValues(alpha: 0.7);
      case 4:
        return AppColors.primary;
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }
}

/// Accuracy by category section
class _AccuracySection extends StatelessWidget {
  const _AccuracySection({
    required this.stats,
    required this.isArabic,
  });

  final UserStats stats;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accuracyByCategory,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: [
                  if (stats.accuracyPerQuizType.isNotEmpty)
                    ...stats.accuracyPerQuizType.entries.map((entry) {
                      return _AccuracyBar(
                        label: _getQuizTypeName(entry.key, l10n),
                        accuracy: entry.value,
                        color: _getQuizTypeColor(entry.key),
                      );
                    }),
                  if (stats.accuracyPerQuizType.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      child: Text(
                        l10n.noDataYet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  String _getQuizTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'flags':
        return l10n.quizTypeFlags;
      case 'capitals':
        return l10n.quizTypeCapitals;
      case 'maps':
        return l10n.quizTypeMaps;
      case 'mixed':
        return l10n.quizTypeMixed;
      default:
        return type;
    }
  }

  Color _getQuizTypeColor(String type) {
    switch (type) {
      case 'flags':
        return Colors.blue;
      case 'capitals':
        return Colors.green;
      case 'maps':
        return Colors.orange;
      case 'mixed':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}

/// Accuracy bar widget
class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({
    required this.label,
    required this.accuracy,
    required this.color,
  });

  final String label;
  final double accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${(accuracy * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: accuracy,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weak areas section
class _WeakAreasSection extends StatelessWidget {
  const _WeakAreasSection({
    required this.weakAreas,
    required this.isArabic,
  });

  final List<WeakArea> weakAreas;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, color: AppColors.error, size: 20),
              const SizedBox(width: AppDimensions.xs),
              Text(
                l10n.weakAreas,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...weakAreas.take(3).map((area) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  child: Text(
                    '${(area.accuracy * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  area.getName(isArabic),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  area.getRecommendation(isArabic),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    // Navigate to practice
                  },
                  child: Text(l10n.practice),
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

/// Strong areas section
class _StrongAreasSection extends StatelessWidget {
  const _StrongAreasSection({
    required this.strongAreas,
    required this.isArabic,
  });

  final List<StrongArea> strongAreas;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.success, size: 20),
              const SizedBox(width: AppDimensions.xs),
              Text(
                l10n.strongAreas,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: strongAreas.take(5).map((area) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: AppColors.success,
                  child: Text(
                    '${(area.accuracy * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(area.getName(isArabic)),
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

/// Countries by continent section
class _ContinentProgressSection extends StatelessWidget {
  const _ContinentProgressSection({
    required this.countriesPerContinent,
    required this.isArabic,
  });

  final Map<String, int> countriesPerContinent;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    // Total countries per continent (approximate)
    const totalCountries = {
      'Africa': 54,
      'Asia': 49,
      'Europe': 44,
      'North America': 23,
      'South America': 12,
      'Oceania': 14,
    };

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.countriesByContinent,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: totalCountries.entries.map((continent) {
                  final learned = countriesPerContinent[continent.key] ?? 0;
                  final total = continent.value;
                  final progress = total > 0 ? learned / total : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getContinentName(continent.key, l10n),
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '$learned / $total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getContinentColor(continent.key),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  String _getContinentName(String continent, AppLocalizations l10n) {
    switch (continent) {
      case 'Africa':
        return l10n.continentAfrica;
      case 'Asia':
        return l10n.continentAsia;
      case 'Europe':
        return l10n.continentEurope;
      case 'North America':
        return l10n.continentNorthAmerica;
      case 'South America':
        return l10n.continentSouthAmerica;
      case 'Oceania':
        return l10n.continentOceania;
      default:
        return continent;
    }
  }

  Color _getContinentColor(String continent) {
    switch (continent) {
      case 'Africa':
        return const Color(0xFFFFB300);
      case 'Asia':
        return const Color(0xFFE91E63);
      case 'Europe':
        return const Color(0xFF2196F3);
      case 'North America':
        return const Color(0xFF4CAF50);
      case 'South America':
        return const Color(0xFF9C27B0);
      case 'Oceania':
        return const Color(0xFF00BCD4);
      default:
        return AppColors.primary;
    }
  }
}
