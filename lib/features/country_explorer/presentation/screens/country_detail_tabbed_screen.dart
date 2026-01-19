import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/country.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_content_provider.dart';
import '../../../../presentation/providers/country_progress_provider.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/widgets/error_widgets.dart';
import '../tabs/culture_tab.dart';
import '../tabs/geography_tab.dart';
import '../tabs/learn_tab.dart';
import '../tabs/overview_tab.dart';
import '../tabs/travel_tab.dart';

/// Enhanced country detail screen with 5 tabs
class CountryDetailTabbedScreen extends ConsumerStatefulWidget {
  const CountryDetailTabbedScreen({
    super.key,
    required this.countryCode,
    this.initialTab = 0,
  });

  final String countryCode;
  final int initialTab;

  @override
  ConsumerState<CountryDetailTabbedScreen> createState() =>
      _CountryDetailTabbedScreenState();
}

class _CountryDetailTabbedScreenState
    extends ConsumerState<CountryDetailTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryAsync = ref.watch(countryByCodeProvider(widget.countryCode));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: countryAsync.when(
        data: (country) {
          if (country == null) {
            return _buildNotFound(context, l10n);
          }
          // Load content when country is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(countryContentProvider(country.code).notifier)
                .loadContent(country.code, country.name);
          });
          return _buildContent(context, country, theme, l10n, isArabic);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error, l10n),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, AppLocalizations l10n) {
    return EmptyStateWidget(
      icon: Icons.public_off_rounded,
      title: l10n.countryNotFound,
      message: l10n.error,
      actionLabel: l10n.back,
      onAction: () => context.pop(),
    );
  }

  Widget _buildError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Convert error to Failure if possible
    final failure = error is Failure
        ? error
        : CountryFailure(
            message: error.toString(),
            code: 'unknown',
          );

    return ErrorStateWidget.fromFailure(
      failure: failure,
      isArabic: isArabic,
      showBackButton: true,
      onBack: () => context.pop(),
      onRetry: () => ref.invalidate(countryByCodeProvider(widget.countryCode)),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Collapsible app bar with flag
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            floating: false,
            forceElevated: innerBoxIsScrolled,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                country.getDisplayName(isArabic: isArabic),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Flag image
                  CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
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
                  // Progress badge
                  Positioned(
                    bottom: 60,
                    right: 16,
                    child: _ProgressBadge(countryCode: country.code),
                  ),
                ],
              ),
            ),
            actions: [
              // Favorite button
              _FavoriteButton(countryCode: country.code),
              // Share button
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareCountry(country, isArabic),
              ),
            ],
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              isArabic: isArabic,
            ),
          ),
        ];
      },

      // Tab content
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview tab
          OverviewTab(country: country),

          // Geography tab
          GeographyTab(country: country),

          // Culture tab
          CultureTab(
            countryCode: country.code,
            countryName: country.name,
          ),

          // Travel tab
          TravelTab(
            countryCode: country.code,
            countryName: country.name,
          ),

          // Learn tab
          LearnTab(country: country),
        ],
      ),
    );
  }

  void _shareCountry(Country country, bool isArabic) {
    final name = country.getDisplayName(isArabic: isArabic);
    final capital = country.getDisplayCapital(isArabic: isArabic);
    final text =
        '$name - Capital: $capital, Population: ${country.formattedPopulation}';
    // Share functionality would go here
    debugPrint('Share: $text');
  }
}

/// Progress badge shown on the header
class _ProgressBadge extends ConsumerWidget {
  const _ProgressBadge({required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressForCountryProvider(countryCode));

    return progressAsync.when(
      data: (progress) {
        final progressPercent = progress.completionPercentage.toInt();
        final color = _getProgressColor(progress.completionPercentage / 100);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.trending_up,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF4CAF50);
    if (progress >= 0.5) return const Color(0xFFFFC107);
    if (progress > 0) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }
}

/// Favorite button in app bar
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isCountryFavoriteProvider(countryCode));

    return isFavoriteAsync.when(
      data: (isFavorite) => IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: () {
          ref
              .read(countryProgressProvider(countryCode).notifier)
              .toggleFavorite(countryCode);
        },
      ),
      loading: () => const IconButton(
        icon: Icon(Icons.favorite_border),
        onPressed: null,
      ),
      error: (_, __) => const IconButton(
        icon: Icon(Icons.favorite_border),
        onPressed: null,
      ),
    );
  }
}

/// Tab bar delegate for sticky tabs
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.tabController,
    required this.isArabic,
  });

  final TabController tabController;
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
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(
            icon: const Icon(Icons.info_outline, size: 20),
            text: isArabic ? 'نظرة عامة' : 'Overview',
          ),
          Tab(
            icon: const Icon(Icons.terrain, size: 20),
            text: isArabic ? 'الجغرافيا' : 'Geography',
          ),
          Tab(
            icon: const Icon(Icons.theater_comedy, size: 20),
            text: isArabic ? 'الثقافة' : 'Culture',
          ),
          Tab(
            icon: const Icon(Icons.flight, size: 20),
            text: isArabic ? 'السفر' : 'Travel',
          ),
          Tab(
            icon: const Icon(Icons.school, size: 20),
            text: isArabic ? 'تعلم' : 'Learn',
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabController != oldDelegate.tabController ||
        isArabic != oldDelegate.isArabic;
  }
}
