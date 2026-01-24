import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/i_country_content_repository.dart';
import '../../../../presentation/providers/country_content_provider.dart';

/// Geography tab showing terrain, climate, hazards, and regions
class GeographyTab extends ConsumerWidget {
  const GeographyTab({
    super.key,
    required this.country,
  });

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final geographyAsync = ref.watch(geographyInfoProvider(country.code));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location card
          _LocationCard(country: country, isArabic: isArabic),
          const SizedBox(height: AppDimensions.md),

          // Geography info from API
          geographyAsync.when(
            data: (info) {
              if (info == null) return const SizedBox.shrink();

              return Column(
                children: [
                  // Terrain section
                  if (info.terrainTypes.isNotEmpty)
                    _TerrainCard(terrainTypes: info.terrainTypes, isArabic: isArabic),
                  const SizedBox(height: AppDimensions.md),

                  // Climate section
                  if (info.climateZones.isNotEmpty)
                    _ClimateCard(climateZones: info.climateZones, isArabic: isArabic),
                  const SizedBox(height: AppDimensions.md),

                  // Natural hazards
                  if (info.naturalHazards.isNotEmpty)
                    _NaturalHazardsCard(
                      hazards: info.naturalHazards,
                      isArabic: isArabic,
                    ),
                  const SizedBox(height: AppDimensions.md),

                  // Water bodies
                  if (info.waterBodies.isNotEmpty)
                    _WaterBodiesCard(
                      waterBodies: info.waterBodies,
                      isArabic: isArabic,
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => _buildPlaceholderContent(context, isArabic),
          ),

          // Timezones section
          _TimezonesCard(country: country, isArabic: isArabic),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context, bool isArabic) {
    return Column(
      children: [
        _TerrainCard(
          terrainTypes: [
            TerrainType(
              name: isArabic ? 'متنوعة' : 'Varied terrain',
              percentage: 100,
            ),
          ],
          isArabic: isArabic,
        ),
        const SizedBox(height: AppDimensions.md),
        _ClimateCard(
          climateZones: [
            ClimateZone(
              name: isArabic ? 'مناخ متنوع' : 'Diverse climate',
            ),
          ],
          isArabic: isArabic,
        ),
      ],
    );
  }
}

/// Location information card
class _LocationCard extends StatelessWidget {
  const _LocationCard({
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
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: AppDimensions.iconSM,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'الموقع' : 'Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            _InfoRow(
              label: isArabic ? 'القارة' : 'Continent',
              value: country.continents.join(', '),
            ),
            _InfoRow(
              label: isArabic ? 'المنطقة' : 'Region',
              value: country.region,
            ),
            if (country.subregion != null)
              _InfoRow(
                label: isArabic ? 'المنطقة الفرعية' : 'Subregion',
                value: country.subregion!,
              ),
            _InfoRow(
              label: isArabic ? 'الإحداثيات' : 'Coordinates',
              value:
                  '${country.coordinates.latitude.toStringAsFixed(2)}°, ${country.coordinates.longitude.toStringAsFixed(2)}°',
            ),
            _InfoRow(
              label: isArabic ? 'حبيسة' : 'Landlocked',
              value: country.isLandlocked
                  ? (isArabic ? 'نعم' : 'Yes')
                  : (isArabic ? 'لا' : 'No'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}

/// Terrain information card
class _TerrainCard extends StatelessWidget {
  const _TerrainCard({
    required this.terrainTypes,
    required this.isArabic,
  });

  final List<TerrainType> terrainTypes;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.terrain,
                  size: AppDimensions.iconSM,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'التضاريس' : 'Terrain',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            ...terrainTypes.map((terrain) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          terrain.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (terrain.percentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(terrain.color ?? 0xFF4CAF50)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: Text(
                            '${terrain.percentage.toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// Climate information card
class _ClimateCard extends StatelessWidget {
  const _ClimateCard({
    required this.climateZones,
    required this.isArabic,
  });

  final List<ClimateZone> climateZones;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny,
                  size: AppDimensions.iconSM,
                  color: Colors.orange,
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'المناخ' : 'Climate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            ...climateZones.map((climate) => Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.xs),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          climate.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (climate.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            climate.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (climate.averageTempCelsius != null ||
                            climate.rainfallMm != null) ...[
                          const SizedBox(height: AppDimensions.xs),
                          Row(
                            children: [
                              if (climate.averageTempCelsius != null) ...[
                                const Icon(
                                  Icons.thermostat,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${climate.averageTempCelsius!.toInt()}°C',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(width: AppDimensions.md),
                              ],
                              if (climate.rainfallMm != null) ...[
                                const Icon(
                                  Icons.water_drop,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${climate.rainfallMm!.toInt()} mm',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// Natural hazards card
class _NaturalHazardsCard extends StatelessWidget {
  const _NaturalHazardsCard({
    required this.hazards,
    required this.isArabic,
  });

  final List<String> hazards;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: AppDimensions.iconSM,
                  color: Colors.red,
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'المخاطر الطبيعية' : 'Natural Hazards',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.xs,
              runSpacing: AppDimensions.xs,
              children: hazards.map((hazard) {
                return Chip(
                  avatar: Icon(
                    _getHazardIcon(hazard),
                    size: 16,
                    color: Colors.red,
                  ),
                  label: Text(hazard),
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHazardIcon(String hazard) {
    final lower = hazard.toLowerCase();
    if (lower.contains('earthquake')) return Icons.vibration;
    if (lower.contains('volcano')) return Icons.volcano;
    if (lower.contains('flood')) return Icons.water;
    if (lower.contains('hurricane') || lower.contains('cyclone')) {
      return Icons.storm;
    }
    if (lower.contains('tsunami')) return Icons.waves;
    if (lower.contains('drought')) return Icons.wb_sunny;
    return Icons.warning;
  }
}

/// Water bodies card
class _WaterBodiesCard extends StatelessWidget {
  const _WaterBodiesCard({
    required this.waterBodies,
    required this.isArabic,
  });

  final List<String> waterBodies;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.water,
                  size: AppDimensions.iconSM,
                  color: Colors.blue,
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'المسطحات المائية' : 'Water Bodies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.xs,
              runSpacing: AppDimensions.xs,
              children: waterBodies.take(10).map((body) {
                return Chip(
                  avatar: const Icon(Icons.waves, size: 16, color: Colors.blue),
                  label: Text(body),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
            if (waterBodies.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.xs),
                child: Text(
                  isArabic
                      ? '+ ${waterBodies.length - 10} أخرى'
                      : '+ ${waterBodies.length - 10} more',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Timezones card
class _TimezonesCard extends StatelessWidget {
  const _TimezonesCard({
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (country.timezones.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppDimensions.iconSM,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  isArabic ? 'المناطق الزمنية' : 'Timezones',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Text(
                    '${country.timezones.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.xs,
              runSpacing: AppDimensions.xs,
              children: country.timezones.take(6).map((tz) {
                return Chip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text(tz),
                );
              }).toList(),
            ),
            if (country.timezones.length > 6)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.xs),
                child: Text(
                  isArabic
                      ? '+ ${country.timezones.length - 6} أخرى'
                      : '+ ${country.timezones.length - 6} more',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
