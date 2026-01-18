import '../../domain/entities/country.dart';

/// Weather data model from OpenWeatherMap API
class WeatherModel {
  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.condition,
    required this.conditionDescription,
    required this.icon,
    required this.cityName,
    required this.countryCode,
    required this.sunrise,
    required this.sunset,
  });

  final double temperature; // Celsius
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDeg;
  final String condition; // e.g., "Clear", "Clouds", "Rain"
  final String conditionDescription;
  final String icon;
  final String cityName;
  final String countryCode;
  final DateTime sunrise;
  final DateTime sunset;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      pressure: main['pressure'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      condition: weather['main'] as String,
      conditionDescription: weather['description'] as String,
      icon: weather['icon'] as String,
      cityName: json['name'] as String,
      countryCode: sys['country'] as String? ?? '',
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunrise'] as int) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunset'] as int) * 1000,
      ),
    );
  }

  /// Convert to domain entity
  CountryWeather toEntity(String countryCode) {
    return CountryWeather(
      countryCode: countryCode,
      temperature: temperature,
      condition: condition,
      icon: _getWeatherIconUrl(icon),
      humidity: humidity,
      windSpeed: windSpeed,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get the full URL for the weather icon
  String _getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  /// Get localized weather condition
  String getLocalizedCondition(bool isArabic) {
    if (!isArabic) return condition;

    switch (condition.toLowerCase()) {
      case 'clear':
        return 'صافي';
      case 'clouds':
        return 'غائم';
      case 'rain':
        return 'ممطر';
      case 'drizzle':
        return 'رذاذ';
      case 'thunderstorm':
        return 'عاصفة رعدية';
      case 'snow':
        return 'ثلج';
      case 'mist':
      case 'fog':
        return 'ضباب';
      case 'haze':
        return 'ضبابي';
      case 'dust':
      case 'sand':
        return 'غبار';
      default:
        return condition;
    }
  }
}
