import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../widgets/detail/country_action_buttons.dart';
import '../widgets/detail/country_currencies_section.dart';
import '../widgets/detail/country_header.dart';
import '../widgets/detail/country_info_section.dart';
import '../widgets/detail/country_languages_section.dart';
import '../widgets/detail/country_neighbors_section.dart';
import '../widgets/detail/country_quick_stats.dart';
import '../widgets/detail/flag_card.dart';
import '../widgets/detail/flag_colors_section.dart';
import '../widgets/detail/weather_card.dart';

/// Country detail screen - Premium Clean Design
class CountryDetailScreen extends ConsumerWidget {
  const CountryDetailScreen({
    super.key,
    required this.countryCode,
  });

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryAsync = ref.watch(countryByCodeProvider(countryCode));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: countryAsync.when(
        data: (country) {
          if (country == null) {
            return _buildNotFound(context, l10n);
          }
          return _CountryDetailContent(country: country);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _buildError(context, error, l10n),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.explore_off, size: AppDimensions.iconXXL, color: AppColors.error),
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            l10n.countryNotFound,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.back),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, Object error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: AppDimensions.iconXXL, color: AppColors.error),
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            Text(
              l10n.error,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.back),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.md),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main content widget for country detail
class _CountryDetailContent extends ConsumerWidget {
  const _CountryDetailContent({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic accent color based on region
    final accentColor = _getRegionAccent(country.region);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: _buildBackButton(context, theme, isArabic),
            actions: [
              _buildShareButton(context, theme, l10n, isArabic),
              const SizedBox(width: AppDimensions.xs),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Flag Card
                  FlagCard(country: country, accentColor: accentColor)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1)),

                  const SizedBox(height: AppDimensions.lg),

                  // Country Name & Info
                  CountryHeader(
                    country: country,
                    isArabic: isArabic,
                    accentColor: accentColor,
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.lg + 4),

                  // Flag Colors Meaning Section
                  FlagColorsMeaningSection(
                    countryCode: country.code,
                    accentColor: accentColor,
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.lg + 4),

                  // Quick Stats Row
                  CountryQuickStats(country: country, isArabic: isArabic)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.lg + 4),

                  // Weather Card
                  WeatherCard(country: country, accentColor: accentColor)
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.lg - 4),

                  // Location Info Section
                  CountryInfoSection(
                    title: l10n.location,
                    icon: Icons.public_rounded,
                    accentColor: accentColor,
                    isArabic: isArabic,
                    items: [
                      InfoItem(l10n.region,
                          country.getDisplayRegion(isArabic: isArabic)),
                      if (country.subregion != null)
                        InfoItem(
                            l10n.subregion,
                            country.getDisplaySubregion(isArabic: isArabic) ??
                                country.subregion!),
                      InfoItem(l10n.continents, country.continents.join(', ')),
                      InfoItem(l10n.coordinates,
                          '${country.coordinates.latitude.toStringAsFixed(2)}°, ${country.coordinates.longitude.toStringAsFixed(2)}°'),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.lg - 4),

                  // Details Info Section
                  CountryInfoSection(
                    title: l10n.details,
                    icon: Icons.info_outline_rounded,
                    accentColor: AppColors.info,
                    isArabic: isArabic,
                    items: [
                      InfoItem(l10n.officialName, country.name),
                      InfoItem(l10n.countryCode,
                          '${country.code} / ${country.code3}'),
                      InfoItem(l10n.unMember,
                          country.isUnMember ? l10n.yes : l10n.no),
                      InfoItem(l10n.landlocked,
                          country.isLandlocked ? l10n.yes : l10n.no),
                      if (country.drivingSide != null)
                        InfoItem(
                            l10n.drivingSide,
                            country.drivingSide == 'left'
                                ? l10n.left
                                : l10n.right),
                      if (country.timezones.isNotEmpty)
                        InfoItem(
                            l10n.timezones,
                            country.timezones.first +
                                (country.timezones.length > 1
                                    ? ' (+${country.timezones.length - 1})'
                                    : '')),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  // Languages
                  if (country.languages.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.lg - 4),
                    CountryLanguagesSection(country: country, isArabic: isArabic)
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  // Currencies
                  if (country.currencies.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.lg - 4),
                    CountryCurrenciesSection(
                            country: country, isArabic: isArabic)
                        .animate()
                        .fadeIn(delay: 650.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  // Neighboring Countries
                  if (country.borders.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.lg - 4),
                    CountryNeighborsSection(country: country, isArabic: isArabic)
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  const SizedBox(height: AppDimensions.lg + 4),

                  // Action Buttons
                  CountryActionButtons(
                    country: country,
                    isArabic: isArabic,
                    accentColor: accentColor,
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppDimensions.xxl - 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ThemeData theme, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xs),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: AppDimensions.iconSM,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xs),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: IconButton(
          icon: const Icon(Icons.ios_share_rounded, size: AppDimensions.iconSM),
          onPressed: () {
            HapticFeedback.lightImpact();
            _shareCountry(context, l10n, isArabic);
          },
        ),
      ),
    );
  }

  void _shareCountry(
      BuildContext context, AppLocalizations l10n, bool isArabic) async {
    final name = country.getDisplayName(isArabic: isArabic);
    final capital = country.getDisplayCapital(isArabic: isArabic);
    final region = country.getDisplayRegion(isArabic: isArabic);

    final shareText = isArabic
        ? '''🌍 $name ${country.flagEmoji}

🏛️ العاصمة: $capital
👥 السكان: ${country.formattedPopulation}
📍 المنطقة: $region
📐 المساحة: ${country.formattedArea}

اكتشف المزيد مع GeoMaster! 🗺️'''
        : '''🌍 $name ${country.flagEmoji}

🏛️ Capital: $capital
👥 Population: ${country.formattedPopulation}
📍 Region: $region
📐 Area: ${country.formattedArea}

Discover more with GeoMaster! 🗺️''';

    await Share.share(shareText, subject: name);
  }

  Color _getRegionAccent(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return const Color(0xFFE67E22);
      case 'americas':
        return const Color(0xFF3498DB);
      case 'asia':
        return const Color(0xFFE74C3C);
      case 'europe':
        return const Color(0xFF9B59B6);
      case 'oceania':
        return const Color(0xFF1ABC9C);
      default:
        return AppColors.primary;
    }
  }
}
