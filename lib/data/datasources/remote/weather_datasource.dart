import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/weather_model.dart';

/// Weather API data source interface
abstract class IWeatherDataSource {
  /// Get current weather by city name
  Future<WeatherModel> getWeatherByCity(String cityName);

  /// Get current weather by coordinates
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon);
}

/// OpenWeatherMap API data source implementation
class WeatherDataSource implements IWeatherDataSource {
  WeatherDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    if (_apiKey.isEmpty) {
      throw const ServerException(
        message: 'Weather API key not configured',
        code: 'NO_API_KEY',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.weatherCurrent,
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': 'metric', // Celsius
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch weather data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(message: 'Weather API error');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw const ServerException(
        message: 'Weather API key not configured',
        code: 'NO_API_KEY',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.weatherCurrent,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric', // Celsius
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch weather data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(message: 'Weather API error');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const ServerException(
            message: 'Invalid weather API key',
            code: 'INVALID_API_KEY',
            statusCode: 401,
          );
        }
        if (statusCode == 404) {
          return const ServerException(
            message: 'City not found',
            code: 'CITY_NOT_FOUND',
            statusCode: 404,
          );
        }
        return ServerException(
          message: 'Weather server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'Weather API error',
        );
    }
  }
}
