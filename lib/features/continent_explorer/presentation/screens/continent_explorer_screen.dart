import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/continent.dart';
import '../../../../presentation/providers/continent_provider.dart';
import '../widgets/continent_card.dart';
import '../widgets/continent_stats_popup.dart';

/// Main screen for exploring continents
class ContinentExplorerScreen extends ConsumerWidget {
  const ContinentExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final continentsState = ref.watch(continentListProvider);
    final viewMode = ref.watch(continentViewModeProvider);
    final sortMode = ref.watch(continentSortModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'استكشف القارات' : 'Explore Continents',
        ),
        centerTitle: true,
        actions: [
          // Sort button
          PopupMenuButton<ContinentSortMode>(
            icon: const Icon(Icons.sort),
            initialValue: sortMode,
            onSelected: (mode) {
              ref.read(continentSortModeProvider.notifier).state = mode;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ContinentSortMode.alphabetical,
                child: Row(
                  children: [
                    const Icon(Icons.sort_by_alpha, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Text(isArabic ? 'أبجدي' : 'Alphabetical'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ContinentSortMode.byCountries,
                child: Row(
                  children: [
                    const Icon(Icons.flag, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Text(isArabic ? 'عدد الدول' : 'Country Count'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ContinentSortMode.byProgress,
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Text(isArabic ? 'التقدم' : 'Progress'),
                  ],
                ),
              ),
            ],
          ),

          // View toggle
          IconButton(
            icon: Icon(
              viewMode == ContinentViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            onPressed: () {
              ref.read(continentViewModeProvider.notifier).state =
                  viewMode == ContinentViewMode.grid
                      ? ContinentViewMode.list
                      : ContinentViewMode.grid;
            },
            tooltip: viewMode == ContinentViewMode.grid
                ? (isArabic ? 'عرض قائمة' : 'List View')
                : (isArabic ? 'عرض شبكة' : 'Grid View'),
          ),
        ],
      ),
      body: continentsState.when(
        data: (state) {
          if (state is! ContinentListLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final continents = _sortContinents(
            state.continents,
            sortMode,
          );

          if (viewMode == ContinentViewMode.grid) {
            return _buildGridView(context, continents, isArabic, ref);
          } else {
            return _buildListView(context, continents, isArabic, ref);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                isArabic ? 'حدث خطأ' : 'An error occurred',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.xs),
              TextButton.icon(
                onPressed: () {
                  ref.invalidate(continentListProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Continent> _sortContinents(
    List<Continent> continents,
    ContinentSortMode sortMode,
  ) {
    final sorted = List<Continent>.from(continents);

    switch (sortMode) {
      case ContinentSortMode.alphabetical:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case ContinentSortMode.byCountries:
        sorted.sort(
            (a, b) => b.countryCodes.length.compareTo(a.countryCodes.length));
      case ContinentSortMode.byProgress:
        sorted.sort(
            (a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    }

    return sorted;
  }

  Widget _buildGridView(
    BuildContext context,
    List<Continent> continents,
    bool isArabic,
    WidgetRef ref,
  ) {
    // Use responsive grid columns based on screen size
    final columns = Responsive.gridColumns(context, mobileColumns: 2);
    final padding = Responsive.padding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: padding,
          crossAxisSpacing: padding,
          childAspectRatio: 0.75,
        ),
        itemCount: continents.length,
        itemBuilder: (context, index) {
          final continent = continents[index];
          return ContinentCard(
            continent: continent,
            onTap: () => _navigateToContinentDetail(context, continent),
            onLongPress: () => _showContinentStats(context, continent, ref),
          );
        },
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<Continent> continents,
    bool isArabic,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      itemCount: continents.length,
      itemBuilder: (context, index) {
        final continent = continents[index];
        return ContinentListTile(
          continent: continent,
          onTap: () => _navigateToContinentDetail(context, continent),
          onLongPress: () => _showContinentStats(context, continent, ref),
        );
      },
    );
  }

  void _navigateToContinentDetail(BuildContext context, Continent continent) {
    context.push(Routes.continentDetailPath(continent.id));
  }

  void _showContinentStats(
    BuildContext context,
    Continent continent,
    WidgetRef ref,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile: show bottom sheet
      ContinentStatsBottomSheet.show(
        context,
        continent: continent,
        onExplore: () => _navigateToContinentDetail(context, continent),
      );
    } else {
      // Tablet/Desktop: show dialog
      ContinentStatsPopup.show(
        context,
        continent: continent,
        onExplore: () => _navigateToContinentDetail(context, continent),
      );
    }
  }
}

/// Summary stats header widget
class ContinentExplorerHeader extends ConsumerWidget {
  const ContinentExplorerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Calculate overall stats from all continents
    final continents = ref.watch(allContinentsProvider);
    final totalCountries =
        continents.fold(0, (sum, c) => sum + c.countryCodes.length);
    final exploredContinents =
        continents.where((c) => c.progressPercentage > 0).length;
    final overallProgress = continents.isEmpty
        ? 0.0
        : continents.fold(0.0, (sum, c) => sum + c.progressPercentage) /
            (continents.length * 100);

    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg - 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'تقدمك العالمي' : 'Your Global Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeaderStat(
                icon: Icons.public,
                value: '$exploredContinents/7',
                label: isArabic ? 'قارات' : 'Continents',
              ),
              _HeaderStat(
                icon: Icons.flag,
                value: '$totalCountries',
                label: isArabic ? 'دول' : 'Countries',
              ),
              const _HeaderStat(
                icon: Icons.star,
                value: '0', // Would come from actual progress tracking
                label: 'XP',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            isArabic
                ? '${(overallProgress * 100).toInt()}% من العالم مستكشف'
                : '${(overallProgress * 100).toInt()}% of the world explored',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
