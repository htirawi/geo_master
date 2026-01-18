import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../data/datasources/remote/weather_datasource.dart';
import '../../data/models/weather_model.dart';
import '../../domain/entities/country.dart';

/// Weather data source provider
final weatherDataSourceProvider = Provider<IWeatherDataSource>((ref) {
  return sl<IWeatherDataSource>();
});

/// Weather by capital city provider
/// Uses the country's capital to fetch weather data
final weatherByCapitalProvider =
    FutureProvider.family<CountryWeather?, Country>((ref, country) async {
  final capital = country.capital;
  if (capital == null || capital.isEmpty) {
    return null;
  }

  try {
    final dataSource = ref.watch(weatherDataSourceProvider);
    final weatherModel = await dataSource.getWeatherByCity(capital);
    return weatherModel.toEntity(country.code);
  } catch (e) {
    // Weather is not critical - return null on error
    return null;
  }
});

/// Weather by coordinates provider
/// Fallback method using country coordinates
final weatherByCoordinatesProvider =
    FutureProvider.family<CountryWeather?, Country>((ref, country) async {
  try {
    final dataSource = ref.watch(weatherDataSourceProvider);
    final weatherModel = await dataSource.getWeatherByCoordinates(
      country.coordinates.latitude,
      country.coordinates.longitude,
    );
    return weatherModel.toEntity(country.code);
  } catch (e) {
    // Weather is not critical - return null on error
    return null;
  }
});

/// Combined weather provider that tries capital first, then coordinates
final countryWeatherProvider =
    FutureProvider.family<WeatherData?, Country>((ref, country) async {
  final capital = country.capital;

  try {
    final dataSource = ref.watch(weatherDataSourceProvider);

    WeatherModel weatherModel;
    if (capital != null && capital.isNotEmpty) {
      // Try by capital city first
      try {
        weatherModel = await dataSource.getWeatherByCity(capital);
      } catch (e) {
        // Fallback to coordinates
        weatherModel = await dataSource.getWeatherByCoordinates(
          country.coordinates.latitude,
          country.coordinates.longitude,
        );
      }
    } else {
      // No capital, use coordinates
      weatherModel = await dataSource.getWeatherByCoordinates(
        country.coordinates.latitude,
        country.coordinates.longitude,
      );
    }

    return WeatherData(
      model: weatherModel,
      entity: weatherModel.toEntity(country.code),
    );
  } catch (e) {
    // Weather is not critical - return null on error
    return null;
  }
});

/// Weather data wrapper with both model and entity
class WeatherData {
  const WeatherData({
    required this.model,
    required this.entity,
  });

  final WeatherModel model;
  final CountryWeather entity;
}
