import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/country.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/widgets/error_widgets.dart';

/// Country explorer screen - World Atlas Theme
/// A beautifully designed explorer with an immersive geography experience
class CountryExplorerScreen extends ConsumerStatefulWidget {
  const CountryExplorerScreen({super.key});

  @override
  ConsumerState<CountryExplorerScreen> createState() =>
      _CountryExplorerScreenState();
}

class _CountryExplorerScreenState extends ConsumerState<CountryExplorerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final searchQuery = ref.watch(countrySearchQueryProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Explorer Header
          SliverToBoxAdapter(
            child: _ExplorerHeader(
              isArabic: isArabic,
              searchController: _searchController,
              onSearchChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
              searchQuery: searchQuery,
              onClearSearch: () {
                _searchController.clear();
                ref.read(countrySearchQueryProvider.notifier).state = '';
              },
            ),
          ),
          // Region Filter
          SliverToBoxAdapter(
            child: _RegionFilterSection(
              selectedRegion: selectedRegion,
              onRegionSelected: (region) {
                HapticFeedback.selectionClick();
                ref.read(selectedRegionProvider.notifier).state = region;
              },
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),
          // View Toggle & Count
          SliverToBoxAdapter(
            child: _ViewToggleHeader(
              isGridView: _isGridView,
              onViewToggle: () {
                HapticFeedback.lightImpact();
                setState(() => _isGridView = !_isGridView);
              },
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),
          // Country List/Grid
          _isGridView
              ? _CountryGridView(isArabic: isArabic)
              : _CountryListView(isArabic: isArabic),
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Explorer Header with search
class _ExplorerHeader extends StatelessWidget {
  const _ExplorerHeader({
    required this.isArabic,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.onClearSearch,
  });

  final bool isArabic;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchQuery;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _AtlasPatternPainter(),
            ),
          ),
          // Decorative globe
          Positioned(
            right: isArabic ? null : -40,
            left: isArabic ? -40 : null,
            top: 40,
            child: Icon(
              Icons.public,
              size: 180,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.explore,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.worldAtlas,
                            style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.discoverCountries,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: GoogleFonts.poppins(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: l10n.searchCountries,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[400]),
                                onPressed: onClearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Atlas pattern painter
class _AtlasPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw latitude lines
    for (int i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw meridian curves
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final path = Path()
        ..moveTo(x - 15, 0)
        ..quadraticBezierTo(x, size.height / 2, x + 15, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Region filter section
class _RegionFilterSection extends ConsumerWidget {
  const _RegionFilterSection({
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  final String? selectedRegion;
  final ValueChanged<String?> onRegionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final regions = ref.watch(regionsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // All filter
            _RegionChip(
              label: l10n.all,
              icon: Icons.public,
              color: AppColors.primary,
              isSelected: selectedRegion == null,
              onTap: () => onRegionSelected(null),
            ),
            const SizedBox(width: 8),
            // Region filters
            ...regions.map((region) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _RegionChip(
                    label: _getLocalizedRegion(l10n, region),
                    icon: _getRegionIcon(region),
                    color: _getRegionColor(region),
                    isSelected: selectedRegion == region,
                    onTap: () =>
                        onRegionSelected(selectedRegion == region ? null : region),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getLocalizedRegion(AppLocalizations l10n, String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return l10n.africa;
      case 'americas':
        return l10n.americas;
      case 'asia':
        return l10n.asia;
      case 'europe':
        return l10n.europe;
      case 'oceania':
        return l10n.oceania;
      default:
        return region;
    }
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny;
      case 'americas':
        return Icons.landscape;
      case 'asia':
        return Icons.temple_buddhist;
      case 'europe':
        return Icons.castle;
      case 'oceania':
        return Icons.waves;
      default:
        return Icons.public;
    }
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return AppColors.regionAfrica;
      case 'americas':
        return AppColors.regionAmericas;
      case 'asia':
        return AppColors.regionAsia;
      case 'europe':
        return AppColors.regionEurope;
      case 'oceania':
        return AppColors.regionOceania;
      default:
        return AppColors.primary;
    }
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// View toggle header
class _ViewToggleHeader extends ConsumerWidget {
  const _ViewToggleHeader({
    required this.isGridView,
    required this.onViewToggle,
  });

  final bool isGridView;
  final VoidCallback onViewToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredCountries = ref.watch(regionFilteredCountriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, color: AppColors.tertiary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${filteredCountries.length} ${l10n.countries}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // View toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _ViewToggleButton(
                  icon: Icons.view_list,
                  isSelected: !isGridView,
                  onTap: isGridView ? onViewToggle : null,
                  isFirst: true,
                ),
                _ViewToggleButton(
                  icon: Icons.grid_view,
                  isSelected: isGridView,
                  onTap: !isGridView ? onViewToggle : null,
                  isFirst: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tertiary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(12) : Radius.zero,
            right: !isFirst ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}

/// Country List View
class _CountryListView extends ConsumerWidget {
  const _CountryListView({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryState = ref.watch(countryListProvider);
    final filteredCountries = ref.watch(regionFilteredCountriesProvider);

    return countryState.when(
      data: (state) {
        if (state is CountryListLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.tertiary),
              ),
            ),
          );
        }

        if (state is CountryListError) {
          return SliverToBoxAdapter(
            child: _buildError(context, ref, state.failure.message, l10n),
          );
        }

        if (filteredCountries.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmpty(context, l10n),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final country = filteredCountries[index];
              return _CountryListCard(
                country: country,
                isArabic: isArabic,
                index: index,
              );
            },
            childCount: filteredCountries.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: AppColors.tertiary),
          ),
        ),
      ),
      error: (error, _) =>
          SliverToBoxAdapter(child: _buildError(context, ref, error.toString(), l10n)),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCountriesFound,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    String error,
    AppLocalizations l10n,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Create a failure from the error string
    final failure = NetworkFailure(
      message: error,
      code: 'unknown',
    );

    return ErrorStateWidget.fromFailure(
      failure: failure,
      isArabic: isArabic,
      onRetry: () => ref.read(countryListProvider.notifier).loadCountries(
            forceRefresh: true,
          ),
    );
  }
}

/// Country List Card
class _CountryListCard extends StatelessWidget {
  const _CountryListCard({
    required this.country,
    required this.isArabic,
    required this.index,
  });

  final Country country;
  final bool isArabic;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(Routes.countryDetail.replaceFirst(':code', country.code));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Flag
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.getDisplayName(isArabic: isArabic),
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: _getRegionColor(country.region),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            country.getDisplayCapital(isArabic: isArabic) ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.people,
                            label: country.formattedPopulation,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: _getRegionIcon(country.region),
                            label: _getLocalizedRegion(l10n, country.region),
                            color: _getRegionColor(country.region),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow
              Container(
                margin: const EdgeInsetsDirectional.only(end: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 10)), duration: 300.ms);
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return AppColors.regionAfrica;
      case 'americas':
        return AppColors.regionAmericas;
      case 'asia':
        return AppColors.regionAsia;
      case 'europe':
        return AppColors.regionEurope;
      case 'oceania':
        return AppColors.regionOceania;
      default:
        return AppColors.primary;
    }
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny;
      case 'americas':
        return Icons.landscape;
      case 'asia':
        return Icons.temple_buddhist;
      case 'europe':
        return Icons.castle;
      case 'oceania':
        return Icons.waves;
      default:
        return Icons.public;
    }
  }

  String _getLocalizedRegion(AppLocalizations l10n, String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return l10n.africa;
      case 'americas':
        return l10n.americas;
      case 'asia':
        return l10n.asia;
      case 'europe':
        return l10n.europe;
      case 'oceania':
        return l10n.oceania;
      default:
        return region;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Country Grid View
class _CountryGridView extends ConsumerWidget {
  const _CountryGridView({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryState = ref.watch(countryListProvider);
    final filteredCountries = ref.watch(regionFilteredCountriesProvider);

    return countryState.when(
      data: (state) {
        if (state is CountryListLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.tertiary),
              ),
            ),
          );
        }

        if (filteredCountries.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.noCountriesFound),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final country = filteredCountries[index];
                return _CountryGridCard(
                  country: country,
                  isArabic: isArabic,
                  index: index,
                );
              },
              childCount: filteredCountries.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: AppColors.tertiary),
          ),
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(l10n.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Country Grid Card
class _CountryGridCard extends StatelessWidget {
  const _CountryGridCard({
    required this.country,
    required this.isArabic,
    required this.index,
  });

  final Country country;
  final bool isArabic;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(Routes.countryDetail.replaceFirst(':code', country.code));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Flag
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: country.flagUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Region badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRegionColor(country.region),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getRegionIcon(country.region),
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      country.getDisplayName(isArabic: isArabic),
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            country.getDisplayCapital(isArabic: isArabic) ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * (index % 10)), duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 50 * (index % 10)),
          duration: 300.ms,
        );
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return AppColors.regionAfrica;
      case 'americas':
        return AppColors.regionAmericas;
      case 'asia':
        return AppColors.regionAsia;
      case 'europe':
        return AppColors.regionEurope;
      case 'oceania':
        return AppColors.regionOceania;
      default:
        return AppColors.primary;
    }
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny;
      case 'americas':
        return Icons.landscape;
      case 'asia':
        return Icons.temple_buddhist;
      case 'europe':
        return Icons.castle;
      case 'oceania':
        return Icons.waves;
      default:
        return Icons.public;
    }
  }
}
