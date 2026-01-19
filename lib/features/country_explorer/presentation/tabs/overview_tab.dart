import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/country.dart';
import '../../../../presentation/providers/country_content_provider.dart';
import '../../../../presentation/providers/timezone_provider.dart';
import '../../../../presentation/providers/weather_provider.dart';

/// Overview tab showing live info, quick facts, flag, and neighbors
class OverviewTab extends ConsumerWidget {
  const OverviewTab({
    super.key,
    required this.country,
  });

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live info card (time, weather, season)
          _LiveInfoCard(country: country),
          const SizedBox(height: 16),

          // Quick facts
          _QuickFactsSection(country: country, isArabic: isArabic),
          const SizedBox(height: 16),

          // Flag deep dive
          _FlagSection(country: country, isArabic: isArabic),
          const SizedBox(height: 16),

          // Wikipedia overview
          _WikipediaOverview(
            countryCode: country.code,
            countryName: country.name,
          ),
          const SizedBox(height: 16),

          // Neighboring countries
          if (country.borders.isNotEmpty)
            _NeighborsSection(country: country, isArabic: isArabic),
        ],
      ),
    );
  }
}

/// Live information card showing current time, weather, and season
class _LiveInfoCard extends ConsumerWidget {
  const _LiveInfoCard({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Get timezone for country (use first timezone if multiple)
    final timezone = country.timezones.isNotEmpty
        ? country.timezones.first
        : 'UTC';

    final timezoneInfo = ref.watch(timezoneInfoProvider(timezone));
    final weatherAsync = ref.watch(countryWeatherProvider(country));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'معلومات حية' : 'Live Info',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Current time
                Expanded(
                  child: timezoneInfo.when(
                    data: (info) => _InfoItem(
                      icon: Icons.schedule,
                      label: isArabic ? 'الوقت المحلي' : 'Local Time',
                      value: info?.formattedTime ?? '--:--',
                      color: theme.colorScheme.primary,
                    ),
                    loading: () => const _InfoItem(
                      icon: Icons.schedule,
                      label: 'Local Time',
                      value: '...',
                      color: Colors.grey,
                    ),
                    error: (_, __) => _InfoItem(
                      icon: Icons.schedule,
                      label: isArabic ? 'الوقت المحلي' : 'Local Time',
                      value: '--:--',
                      color: Colors.grey,
                    ),
                  ),
                ),

                // Weather
                Expanded(
                  child: weatherAsync.when(
                    data: (weather) => _InfoItem(
                      icon: Icons.wb_sunny,
                      label: isArabic ? 'الطقس' : 'Weather',
                      value: weather != null
                          ? '${weather.model.temperature.round()}°C'
                          : '--',
                      color: Colors.orange,
                    ),
                    loading: () => const _InfoItem(
                      icon: Icons.wb_sunny,
                      label: 'Weather',
                      value: '...',
                      color: Colors.grey,
                    ),
                    error: (_, __) => _InfoItem(
                      icon: Icons.wb_sunny,
                      label: isArabic ? 'الطقس' : 'Weather',
                      value: '--',
                      color: Colors.grey,
                    ),
                  ),
                ),

                // Time difference
                Expanded(
                  child: timezoneInfo.when(
                    data: (info) {
                      final diff = info?.utcOffsetSeconds ?? 0;
                      final hours = (diff / 3600).round();
                      final sign = hours >= 0 ? '+' : '';
                      return _InfoItem(
                        icon: Icons.public,
                        label: isArabic ? 'فرق التوقيت' : 'UTC',
                        value: '$sign${hours}h',
                        color: theme.colorScheme.secondary,
                      );
                    },
                    loading: () => const _InfoItem(
                      icon: Icons.public,
                      label: 'UTC',
                      value: '...',
                      color: Colors.grey,
                    ),
                    error: (_, __) => _InfoItem(
                      icon: Icons.public,
                      label: isArabic ? 'فرق التوقيت' : 'UTC',
                      value: '--',
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
        Icon(icon, color: color, size: 28),
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

/// Quick facts section
class _QuickFactsSection extends StatelessWidget {
  const _QuickFactsSection({
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'حقائق سريعة' : 'Quick Facts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FactRow(
              icon: Icons.location_city,
              label: isArabic ? 'العاصمة' : 'Capital',
              value: country.getDisplayCapital(isArabic: isArabic) ?? '-',
            ),
            _FactRow(
              icon: Icons.people,
              label: isArabic ? 'السكان' : 'Population',
              value: country.formattedPopulation,
            ),
            _FactRow(
              icon: Icons.square_foot,
              label: isArabic ? 'المساحة' : 'Area',
              value: country.formattedArea,
            ),
            _FactRow(
              icon: Icons.public,
              label: isArabic ? 'المنطقة' : 'Region',
              value: country.region,
            ),
            if (country.subregion != null)
              _FactRow(
                icon: Icons.map,
                label: isArabic ? 'المنطقة الفرعية' : 'Subregion',
                value: country.subregion!,
              ),
            _FactRow(
              icon: Icons.translate,
              label: isArabic ? 'اللغات' : 'Languages',
              value: country.languages.take(3).join(', '),
            ),
            if (country.currencies.isNotEmpty)
              _FactRow(
                icon: Icons.attach_money,
                label: isArabic ? 'العملة' : 'Currency',
                value: country.currencies.first.name,
              ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
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
}

/// Flag section with deep dive information
class _FlagSection extends StatelessWidget {
  const _FlagSection({
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large flag image
          AspectRatio(
            aspectRatio: 3 / 2,
            child: CachedNetworkImage(
              imageUrl: country.flagUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'علم الدولة' : 'National Flag',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'علم ${country.getDisplayName(isArabic: true)}'
                      : 'Flag of ${country.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wikipedia overview section
class _WikipediaOverview extends ConsumerWidget {
  const _WikipediaOverview({
    required this.countryCode,
    required this.countryName,
  });

  final String countryCode;
  final String countryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final overviewAsync = ref.watch(
      countryOverviewProvider((countryCode, countryName)),
    );

    return overviewAsync.when(
      data: (overview) {
        if (overview == null) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.article,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'نظرة عامة' : 'Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  overview.summary,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Neighboring countries section
class _NeighborsSection extends StatelessWidget {
  const _NeighborsSection({
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.border_all,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'الدول المجاورة' : 'Neighboring Countries',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.borders.map((code) {
                return ActionChip(
                  avatar: const Icon(Icons.flag, size: 16),
                  label: Text(code),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/countries/$code');
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
