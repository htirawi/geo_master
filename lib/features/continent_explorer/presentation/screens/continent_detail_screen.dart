import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../domain/entities/continent.dart';
import '../../../../presentation/providers/continent_provider.dart';
import '../../../../presentation/providers/country_progress_provider.dart';

/// Detail screen for a specific continent showing its countries
class ContinentDetailScreen extends ConsumerStatefulWidget {
  const ContinentDetailScreen({
    super.key,
    required this.continentId,
  });

  /// The continent ID (e.g., 'africa', 'europe', 'asia')
  final String continentId;

  @override
  ConsumerState<ContinentDetailScreen> createState() =>
      _ContinentDetailScreenState();
}

class _ContinentDetailScreenState extends ConsumerState<ContinentDetailScreen> {
  String _searchQuery = '';
  CountryFilterMode _filterMode = CountryFilterMode.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Fetch continent by ID
    final continentAsync = ref.watch(continentByIdProvider(widget.continentId));

    return continentAsync.when(
      data: (continent) {
        if (continent == null) {
          return _buildNotFound(context, isArabic);
        }
        return _buildContent(context, continent, theme, isArabic);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _buildError(context, error, isArabic),
    );
  }

  Widget _buildNotFound(BuildContext context, bool isArabic) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'القارة غير موجودة' : 'Continent not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: Text(isArabic ? 'رجوع' : 'Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error, bool isArabic) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'حدث خطأ' : 'An error occurred',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(error.toString()),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: Text(isArabic ? 'رجوع' : 'Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Continent continent,
    ThemeData theme,
    bool isArabic,
  ) {
    final statsAsync = ref.watch(continentStatsProvider(continent.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                continent.getDisplayName(isArabic: isArabic),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: continent.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats header
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) => _buildStatsHeader(theme, stats, continent, isArabic),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _buildStatsHeader(
                theme,
                const ContinentStats(
                  totalCountries: 0,
                  exploredCountries: 0,
                  completedCountries: 0,
                  totalXp: 0,
                ),
                continent,
                isArabic,
              ),
            ),
          ),

          // Search and filters
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              searchQuery: _searchQuery,
              filterMode: _filterMode,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
              onFilterChanged: (mode) {
                setState(() => _filterMode = mode);
              },
              isArabic: isArabic,
            ),
          ),

          // Countries list
          _buildCountriesList(context, continent, isArabic),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    ThemeData theme,
    ContinentStats stats,
    Continent continent,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(
            icon: Icons.flag,
            value: '${continent.countryCodes.length}',
            label: isArabic ? 'دولة' : 'Countries',
          ),
          _StatChip(
            icon: Icons.explore,
            value: '${stats.exploredCountries}',
            label: isArabic ? 'مستكشفة' : 'Explored',
            color: const Color(0xFF4CAF50),
          ),
          _StatChip(
            icon: Icons.star,
            value: '${stats.totalXp}',
            label: 'XP',
            color: Colors.amber,
          ),
          _StatChip(
            icon: Icons.favorite,
            value: '${stats.favoriteCountries}',
            label: isArabic ? 'مفضلة' : 'Favorites',
            color: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesList(
    BuildContext context,
    Continent continent,
    bool isArabic,
  ) {
    final filteredCountries = _filterCountries(continent.countryCodes);

    if (filteredCountries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'لا توجد نتائج' : 'No results found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final countryCode = filteredCountries[index];
            return _CountryListItem(
              countryCode: countryCode,
              isArabic: isArabic,
              onTap: () => _navigateToCountryDetail(context, countryCode),
            );
          },
          childCount: filteredCountries.length,
        ),
      ),
    );
  }

  List<String> _filterCountries(List<String> countries) {
    var filtered = countries.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((code) {
        // In a real app, you'd look up the country name from the code
        return code.toLowerCase().contains(query);
      }).toList();
    }

    // Apply mode filter
    // In a real implementation, you'd check actual progress data
    switch (_filterMode) {
      case CountryFilterMode.all:
        break;
      case CountryFilterMode.explored:
        // Filter to only explored countries
        break;
      case CountryFilterMode.notStarted:
        // Filter to only not started countries
        break;
      case CountryFilterMode.favorites:
        // Filter to only favorites
        break;
    }

    return filtered;
  }

  void _navigateToCountryDetail(BuildContext context, String countryCode) {
    context.push(Routes.countryDetailTabbedPath(countryCode));
  }
}

enum CountryFilterMode { all, explored, notStarted, favorites }

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: chipColor),
        ),
        const SizedBox(height: 6),
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

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchHeaderDelegate({
    required this.searchQuery,
    required this.filterMode,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.isArabic,
  });

  final String searchQuery;
  final CountryFilterMode filterMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CountryFilterMode> onFilterChanged;
  final bool isArabic;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: isArabic ? 'ابحث عن دولة...' : 'Search countries...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: isArabic ? 'الكل' : 'All',
                  isSelected: filterMode == CountryFilterMode.all,
                  onTap: () => onFilterChanged(CountryFilterMode.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'مستكشفة' : 'Explored',
                  icon: Icons.check_circle_outline,
                  isSelected: filterMode == CountryFilterMode.explored,
                  onTap: () => onFilterChanged(CountryFilterMode.explored),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'لم يبدأ' : 'Not Started',
                  icon: Icons.circle_outlined,
                  isSelected: filterMode == CountryFilterMode.notStarted,
                  onTap: () => onFilterChanged(CountryFilterMode.notStarted),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'مفضلة' : 'Favorites',
                  icon: Icons.favorite_outline,
                  isSelected: filterMode == CountryFilterMode.favorites,
                  onTap: () => onFilterChanged(CountryFilterMode.favorites),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return searchQuery != oldDelegate.searchQuery ||
        filterMode != oldDelegate.filterMode;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}

class _CountryListItem extends ConsumerWidget {
  const _CountryListItem({
    required this.countryCode,
    required this.isArabic,
    required this.onTap,
  });

  final String countryCode;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final progressAsync = ref.watch(progressForCountryProvider(countryCode));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Flag placeholder
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    countryCode.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Country info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // In a real app, you'd look up the country name
                      _getCountryName(countryCode, isArabic),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    progressAsync.when(
                      data: (progress) => Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress.completionPercentage / 100,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${progress.completionPercentage.toInt()}%',
                            style: theme.textTheme.labelSmall,
                          ),
                          if (progress.isFavorite) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Color(0xFFE91E63),
                            ),
                          ],
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountryName(String code, bool isArabic) {
    // This would be replaced with actual country name lookup
    // For now, just return the code
    return code.toUpperCase();
  }
}
