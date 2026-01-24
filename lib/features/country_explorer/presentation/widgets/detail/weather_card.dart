import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../presentation/providers/weather_provider.dart';

/// Weather Card Widget showing current weather for the country
class WeatherCard extends ConsumerWidget {
  const WeatherCard({
    super.key,
    required this.country,
    required this.accentColor,
  });

  final Country country;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final weatherAsync = ref.watch(countryWeatherProvider(country));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A90D9),
            Color(0xFF67B8DE),
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

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherData weatherData,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final weather = weatherData.model;

    return Row(
      children: [
        // Weather Icon & Temp
        Expanded(
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
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
