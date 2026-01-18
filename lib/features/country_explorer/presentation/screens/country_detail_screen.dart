import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/providers/weather_provider.dart';

/// Country detail screen showing all country information
class CountryDetailScreen extends ConsumerWidget {
  const CountryDetailScreen({
    super.key,
    required this.countryCode,
  });

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryAsync = ref.watch(countryByCodeProvider(countryCode));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: countryAsync.when(
        data: (country) {
          if (country == null) {
            return _buildNotFound(context, l10n);
          }
          return _buildContent(context, ref, country, theme, l10n, isArabic);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error, l10n),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.spacingMD),
          Text(l10n.countryNotFound),
          const SizedBox(height: AppDimensions.spacingLG),
          FilledButton(
            onPressed: () => context.pop(),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.spacingMD),
          Text(l10n.error),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(error.toString()),
          const SizedBox(height: AppDimensions.spacingLG),
          FilledButton(
            onPressed: () => context.pop(),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return CustomScrollView(
      slivers: [
        // App bar with flag
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
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
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareCountry(country, isArabic),
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick facts card
              _buildQuickFactsCard(country, theme, l10n, isArabic),
              const SizedBox(height: AppDimensions.spacingLG),

              // Weather section
              _buildSectionTitle(l10n.weather, Icons.wb_sunny, theme),
              const SizedBox(height: AppDimensions.spacingSM),
              _WeatherCard(country: country),
              const SizedBox(height: AppDimensions.spacingLG),

              // Location section
              _buildSectionTitle(l10n.location, Icons.location_on, theme),
              const SizedBox(height: AppDimensions.spacingSM),
              _buildLocationCard(country, theme, l10n),
              const SizedBox(height: AppDimensions.spacingLG),

              // Details section
              _buildSectionTitle(l10n.details, Icons.info_outline, theme),
              const SizedBox(height: AppDimensions.spacingSM),
              _buildDetailsCard(country, theme, l10n),
              const SizedBox(height: AppDimensions.spacingLG),

              // Languages section
              if (country.languages.isNotEmpty) ...[
                _buildSectionTitle(l10n.languages, Icons.translate, theme),
                const SizedBox(height: AppDimensions.spacingSM),
                _buildLanguagesCard(country, theme),
                const SizedBox(height: AppDimensions.spacingLG),
              ],

              // Currencies section
              if (country.currencies.isNotEmpty) ...[
                _buildSectionTitle(l10n.currencies, Icons.attach_money, theme),
                const SizedBox(height: AppDimensions.spacingSM),
                _buildCurrenciesCard(country, theme),
                const SizedBox(height: AppDimensions.spacingLG),
              ],

              // Borders section
              if (country.borders.isNotEmpty) ...[
                _buildSectionTitle(l10n.borders, Icons.border_all, theme),
                const SizedBox(height: AppDimensions.spacingSM),
                _buildBordersCard(context, ref, country, theme),
                const SizedBox(height: AppDimensions.spacingLG),
              ],

              // Actions
              _buildActionsSection(context, country, theme, l10n),
              const SizedBox(height: AppDimensions.spacingXL),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppDimensions.spacingSM),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFactsCard(
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
          children: [
            Expanded(
              child: _QuickFactItem(
                icon: Icons.location_city,
                label: l10n.capital,
                value: country.getDisplayCapital(isArabic: isArabic) ?? '-',
                color: AppColors.primary,
              ),
            ),
            _buildDivider(theme),
            Expanded(
              child: _QuickFactItem(
                icon: Icons.people,
                label: l10n.population,
                value: country.formattedPopulation,
                color: AppColors.secondary,
              ),
            ),
            _buildDivider(theme),
            Expanded(
              child: _QuickFactItem(
                icon: Icons.square_foot,
                label: l10n.area,
                value: country.formattedArea,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 50,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildLocationCard(
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            _buildInfoRow(l10n.region, country.region, theme),
            if (country.subregion != null)
              _buildInfoRow(l10n.subregion, country.subregion!, theme),
            _buildInfoRow(
              l10n.continents,
              country.continents.join(', '),
              theme,
            ),
            _buildInfoRow(
              l10n.coordinates,
              '${country.coordinates.latitude.toStringAsFixed(2)}, ${country.coordinates.longitude.toStringAsFixed(2)}',
              theme,
            ),
            if (country.timezones.isNotEmpty)
              _buildInfoRow(
                l10n.timezones,
                country.timezones.take(3).join(', ') +
                    (country.timezones.length > 3
                        ? ' (+${country.timezones.length - 3})'
                        : ''),
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            _buildInfoRow(l10n.officialName, country.name, theme),
            _buildInfoRow(l10n.countryCode, '${country.code} / ${country.code3}', theme),
            _buildInfoRow(
              l10n.unMember,
              country.isUnMember ? l10n.yes : l10n.no,
              theme,
            ),
            _buildInfoRow(
              l10n.landlocked,
              country.isLandlocked ? l10n.yes : l10n.no,
              theme,
            ),
            if (country.drivingSide != null)
              _buildInfoRow(
                l10n.drivingSide,
                country.drivingSide == 'left' ? l10n.left : l10n.right,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesCard(Country country, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Wrap(
          spacing: AppDimensions.spacingSM,
          runSpacing: AppDimensions.spacingSM,
          children: country.languages.map((language) {
            return Chip(
              avatar: const Icon(Icons.language, size: 18),
              label: Text(language),
              backgroundColor: theme.colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCurrenciesCard(Country country, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: country.currencies.map((currency) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.xpGold.withValues(alpha: 0.2),
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    color: AppColors.xpGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(currency.name),
              subtitle: Text(currency.code),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBordersCard(
    BuildContext context,
    WidgetRef ref,
    Country country,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Wrap(
          spacing: AppDimensions.spacingSM,
          runSpacing: AppDimensions.spacingSM,
          children: country.borders.map((borderCode) {
            return ActionChip(
              avatar: const Icon(Icons.flag, size: 18),
              label: Text(borderCode),
              onPressed: () {
                context.push('${Routes.countryDetail.replaceFirst(':code', borderCode)}');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    Country country,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _openMap(country),
            icon: const Icon(Icons.map),
            label: Text(l10n.viewOnMap),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to AI Tutor with country context
              context.push(
                '${Routes.aiTutor}?country=${country.code}',
              );
            },
            icon: const Icon(Icons.smart_toy),
            label: Text(l10n.learnMore),
          ),
        ),
      ],
    );
  }

  void _shareCountry(Country country, bool isArabic) {
    final name = country.getDisplayName(isArabic: isArabic);
    final capital = country.getDisplayCapital(isArabic: isArabic);
    final text = '$name - Capital: $capital, Population: ${country.formattedPopulation}';
    // Share functionality would go here
    debugPrint('Share: $text');
  }

  void _openMap(Country country) async {
    final lat = country.coordinates.latitude;
    final lng = country.coordinates.longitude;
    final url = Uri.parse('https://www.google.com/maps/@$lat,$lng,6z');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _QuickFactItem extends StatelessWidget {
  const _QuickFactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Weather card widget that fetches and displays weather for the country's capital
class _WeatherCard extends ConsumerWidget {
  const _WeatherCard({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final weatherAsync = ref.watch(countryWeatherProvider(country));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: weatherAsync.when(
          data: (weatherData) {
            if (weatherData == null) {
              return _buildUnavailable(theme, l10n);
            }
            return _buildWeatherContent(
              context,
              weatherData,
              theme,
              l10n,
              isArabic,
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingLG),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _buildUnavailable(theme, l10n),
        ),
      ),
    );
  }

  Widget _buildUnavailable(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.cloud_off,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: Text(
            l10n.weatherUnavailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherData weatherData,
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final weather = weatherData.model;
    final capital = country.getDisplayCapital(isArabic: isArabic) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with city name
        if (capital.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
            child: Text(
              capital,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        // Main weather info
        Row(
          children: [
            // Weather icon
            CachedNetworkImage(
              imageUrl: 'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
              width: 64,
              height: 64,
              placeholder: (_, __) => const SizedBox(
                width: 64,
                height: 64,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Icon(
                _getWeatherIcon(weather.condition),
                size: 64,
                color: _getWeatherColor(weather.condition),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            // Temperature
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°C',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.getLocalizedCondition(isArabic),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        const Divider(),
        const SizedBox(height: AppDimensions.spacingSM),
        // Additional weather info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _WeatherInfoItem(
              icon: Icons.thermostat,
              label: l10n.feelsLike,
              value: '${weather.feelsLike.round()}°C',
            ),
            _WeatherInfoItem(
              icon: Icons.water_drop,
              label: l10n.humidity,
              value: '${weather.humidity}%',
            ),
            _WeatherInfoItem(
              icon: Icons.air,
              label: l10n.wind,
              value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
            ),
          ],
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'clouds':
        return Colors.grey;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'snow':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}

class _WeatherInfoItem extends StatelessWidget {
  const _WeatherInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
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
