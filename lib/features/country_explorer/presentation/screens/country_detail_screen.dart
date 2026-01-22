import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/entities/flag_meaning.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/providers/weather_provider.dart';

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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_off, size: 64, color: AppColors.error),
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
    final size = MediaQuery.of(context).size;

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
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Flag Card
                  _buildFlagCard(context, theme, size, accentColor)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                  const SizedBox(height: 24),

                  // Country Name & Info
                  _buildCountryHeader(context, theme, l10n, isArabic, accentColor)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  // Flag Colors Meaning Section
                  _FlagColorsMeaningSection(
                    countryCode: country.code,
                    accentColor: accentColor,
                  ).animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  // Quick Stats Row
                  _buildQuickStats(context, theme, l10n, isArabic)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  // Weather Card
                  _WeatherCard(country: country, accentColor: accentColor)
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 20),

                  // Info Sections
                  _buildInfoSection(
                    context,
                    theme,
                    l10n,
                    isArabic,
                    title: l10n.location,
                    icon: Icons.public_rounded,
                    accentColor: accentColor,
                    items: [
                      _InfoItem(l10n.region, country.getDisplayRegion(isArabic: isArabic)),
                      if (country.subregion != null)
                        _InfoItem(l10n.subregion, country.getDisplaySubregion(isArabic: isArabic) ?? country.subregion!),
                      _InfoItem(l10n.continents, country.continents.join(', ')),
                      _InfoItem(l10n.coordinates, '${country.coordinates.latitude.toStringAsFixed(2)}°, ${country.coordinates.longitude.toStringAsFixed(2)}°'),
                    ],
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 20),

                  _buildInfoSection(
                    context,
                    theme,
                    l10n,
                    isArabic,
                    title: l10n.details,
                    icon: Icons.info_outline_rounded,
                    accentColor: AppColors.info,
                    items: [
                      _InfoItem(l10n.officialName, country.name),
                      _InfoItem(l10n.countryCode, '${country.code} / ${country.code3}'),
                      _InfoItem(l10n.unMember, country.isUnMember ? l10n.yes : l10n.no),
                      _InfoItem(l10n.landlocked, country.isLandlocked ? l10n.yes : l10n.no),
                      if (country.drivingSide != null)
                        _InfoItem(l10n.drivingSide, country.drivingSide == 'left' ? l10n.left : l10n.right),
                      if (country.timezones.isNotEmpty)
                        _InfoItem(l10n.timezones, country.timezones.first + (country.timezones.length > 1 ? ' (+${country.timezones.length - 1})' : '')),
                    ],
                  ).animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  // Languages
                  if (country.languages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildLanguagesSection(context, theme, l10n, isArabic)
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  // Currencies
                  if (country.currencies.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCurrenciesSection(context, theme, l10n, isArabic)
                        .animate()
                        .fadeIn(delay: 650.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  // Neighboring Countries
                  if (country.borders.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildNeighborsSection(context, ref, theme, l10n, isArabic)
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],

                  const SizedBox(height: 28),

                  // Action Buttons
                  _buildActionButtons(context, theme, l10n, isArabic, accentColor)
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.ios_share_rounded, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            _shareCountry(context, l10n, isArabic);
          },
        ),
      ),
    );
  }

  Widget _buildFlagCard(BuildContext context, ThemeData theme, Size size, Color accentColor) {
    return Center(
      child: Container(
        width: size.width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: country.flagUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(country.flagEmoji, style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(country.flagEmoji, style: const TextStyle(fontSize: 64)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryHeader(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Country Name
        Text(
          country.getDisplayName(isArabic: isArabic),
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Capital City
        if (country.capital != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                country.getDisplayCapital(isArabic: isArabic) ?? '',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Region Tag & Country Code
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Region Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRegionIcon(country.region),
                    size: 14,
                    color: accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    country.getDisplayRegion(isArabic: isArabic),
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Country Code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                country.code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.groups_rounded,
              label: l10n.population,
              value: country.formattedPopulation,
              isArabic: isArabic,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.square_foot_rounded,
              label: l10n.area,
              value: country.formattedArea,
              isArabic: isArabic,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.schedule_rounded,
              label: l10n.timezones,
              value: country.timezones.isNotEmpty ? country.timezones.first.replaceAll('UTC', '') : '-',
              isArabic: isArabic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 12),
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        item.value,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
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
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.translate_rounded, size: 18, color: AppColors.tertiary),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.languages,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: country.languages.map((lang) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrenciesSection(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded, size: 18, color: AppColors.xpGold),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.currencies,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...country.currencies.map((currency) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      currency.symbol,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.name,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currency.code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.grey[500],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNeighborsSection(BuildContext context, WidgetRef ref, ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.handshake_rounded, size: 18, color: AppColors.forest),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.borders,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${country.borders.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: country.borders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final borderCode = country.borders[index];
                final neighborAsync = ref.watch(countryByCodeProvider(borderCode));

                return neighborAsync.when(
                  data: (neighbor) => _NeighborCard(
                    code: borderCode,
                    flagEmoji: neighbor?.flagEmoji,
                    name: neighbor?.getDisplayName(isArabic: isArabic),
                    isArabic: isArabic,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(Routes.countryDetail.replaceFirst(':code', borderCode));
                    },
                  ),
                  loading: () => _NeighborCard(
                    code: borderCode,
                    isArabic: isArabic,
                    onTap: () {},
                  ),
                  error: (_, __) => _NeighborCard(
                    code: borderCode,
                    isArabic: isArabic,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations l10n, bool isArabic, Color accentColor) {
    return Column(
      children: [
        // Primary CTA - View on Map
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openMap(),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.viewOnMap,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary CTA - Learn with AI
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('${Routes.aiTutor}?country=${country.code}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accentColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    l10n.learnMore,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareCountry(BuildContext context, AppLocalizations l10n, bool isArabic) async {
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

  void _openMap() async {
    final lat = country.coordinates.latitude;
    final lng = country.coordinates.longitude;
    final url = Uri.parse('https://www.google.com/maps/@$lat,$lng,6z');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny_rounded;
      case 'americas':
        return Icons.landscape_rounded;
      case 'asia':
        return Icons.temple_buddhist_rounded;
      case 'europe':
        return Icons.castle_rounded;
      case 'oceania':
        return Icons.waves_rounded;
      default:
        return Icons.public_rounded;
    }
  }
}

/// Simple data class for info items
class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}

/// Quick Stat Item Widget
class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isArabic,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(height: 6),
          Text(
            value,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Neighbor Country Card
class _NeighborCard extends StatelessWidget {
  const _NeighborCard({
    required this.code,
    this.flagEmoji,
    this.name,
    required this.isArabic,
    required this.onTap,
  });

  final String code;
  final String? flagEmoji;
  final String? name;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flagEmoji ?? '🏳️',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 6),
            Text(
              name ?? code,
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Weather Card Widget
class _WeatherCard extends ConsumerWidget {
  const _WeatherCard({
    required this.country,
    required this.accentColor,
  });

  final Country country;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final weatherAsync = ref.watch(countryWeatherProvider(country));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A90D9),
            const Color(0xFF67B8DE),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: weatherAsync.when(
        data: (weatherData) {
          if (weatherData == null) {
            return _buildUnavailable(l10n, isArabic);
          }
          return _buildWeatherContent(context, weatherData, l10n, isArabic);
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        error: (_, __) => _buildUnavailable(l10n, isArabic),
      ),
    );
  }

  Widget _buildUnavailable(AppLocalizations l10n, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 28, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          l10n.weatherUnavailable,
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weatherData, AppLocalizations l10n, bool isArabic) {
    final weather = weatherData.model;

    return Row(
      children: [
        // Weather Icon & Temp
        Expanded(
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: 'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 64,
                height: 64,
                placeholder: (_, __) => const SizedBox(width: 64, height: 64),
                errorWidget: (_, __, ___) => Icon(
                  _getWeatherIcon(weather.condition),
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    weather.getLocalizedCondition(isArabic),
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Additional Stats
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _WeatherStat(
                icon: Icons.water_drop_rounded,
                value: '${weather.humidity}%',
              ),
              const SizedBox(height: 10),
              _WeatherStat(
                icon: Icons.air_rounded,
                value: '${weather.windSpeed.toStringAsFixed(0)} m/s',
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Flag Colors Section - Clean, minimal, professional design
class _FlagColorsMeaningSection extends StatelessWidget {
  const _FlagColorsMeaningSection({
    required this.countryCode,
    required this.accentColor,
  });

  final String countryCode;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final flagMeaning = FlagMeaningsRepository.getMeaning(countryCode);

    if (flagMeaning == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 22,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'ألوان العلم ومعانيها' : 'Flag Colors & Meanings',
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Color Cards
        ...flagMeaning.colors.asMap().entries.map((entry) {
          final index = entry.key;
          final flagColor = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < flagMeaning.colors.length - 1 ? 12 : 0,
            ),
            child: _FlagColorCard(
              flagColor: flagColor,
              isArabic: isArabic,
            ).animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),
          );
        }),

        // Symbols Section (if available)
        if (flagMeaning.additionalInfo != null) ...[
          const SizedBox(height: 20),
          _SymbolsCard(
            flagMeaning: flagMeaning,
            isArabic: isArabic,
            accentColor: accentColor,
          ).animate(delay: Duration(milliseconds: 50 * flagMeaning.colors.length))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ],
    );
  }
}

/// Clean, minimal color card
class _FlagColorCard extends StatelessWidget {
  const _FlagColorCard({
    required this.flagColor,
    required this.isArabic,
  });

  final FlagColor flagColor;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color swatch (RTL-aware)
          Container(
            width: 56,
            height: 72,
            decoration: ShapeDecoration(
              color: flagColor.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: const Radius.circular(15),
                ),
                side: flagColor.color == const Color(0xFFFFFFFF)
                    ? BorderSide(color: Colors.grey[300]!, width: 1)
                    : BorderSide.none,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color name and hex
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          flagColor.getName(isArabic: isArabic),
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyHexCode(context, flagColor.hexCode, l10n),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            flagColor.hexCode,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Meaning
                  Text(
                    flagColor.getMeaning(isArabic: isArabic),
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyHexCode(BuildContext context, String hexCode, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: hexCode));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.copiedToClipboard}: $hexCode'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Symbols card for additional flag information
class _SymbolsCard extends StatelessWidget {
  const _SymbolsCard({
    required this.flagMeaning,
    required this.isArabic,
    required this.accentColor,
  });

  final FlagMeaning flagMeaning;
  final bool isArabic;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'الرموز والمعاني' : 'Symbols & Meanings',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? (flagMeaning.additionalInfoAr ?? flagMeaning.additionalInfo!)
                : flagMeaning.additionalInfo!,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 13,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
