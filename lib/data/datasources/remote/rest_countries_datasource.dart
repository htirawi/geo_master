import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/country_model.dart';

/// REST Countries API data source interface
abstract class IRestCountriesDataSource {
  /// Get all countries
  Future<List<CountryModel>> getAllCountries();

  /// Get country by code (alpha-2 or alpha-3)
  Future<CountryModel> getCountryByCode(String code);

  /// Get countries by region
  Future<List<CountryModel>> getCountriesByRegion(String region);

  /// Search countries by name
  Future<List<CountryModel>> searchCountriesByName(String name);
}

/// REST Countries API data source implementation
class RestCountriesDataSource implements IRestCountriesDataSource {
  RestCountriesDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<CountryModel>> getAllCountries() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.restCountriesAll,
        queryParameters: {
          'fields': _getFields(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!;
        return data.map((json) => CountryModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw ServerException(
        message: 'Failed to fetch countries',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<CountryModel> getCountryByCode(String code) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByCode}/$code',
        queryParameters: {
          'fields': _getFields(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // API returns an array even for single country
        final List<dynamic> data = response.data!;
        if (data.isEmpty) {
          throw const ServerException(
            message: 'Country not found',
            statusCode: 404,
          );
        }
        return CountryModel.fromJson(data.first as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Failed to fetch country',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<CountryModel>> getCountriesByRegion(String region) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByRegion}/$region',
        queryParameters: {
          'fields': _getFields(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!;
        return data.map((json) => CountryModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw ServerException(
        message: 'Failed to fetch countries by region',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<CountryModel>> searchCountriesByName(String name) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByName}/$name',
        queryParameters: {
          'fields': _getFields(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!;
        return data.map((json) => CountryModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      if (response.statusCode == 404) {
        return []; // No countries found
      }

      throw ServerException(
        message: 'Failed to search countries',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No countries found
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Get the fields parameter for API requests
  String _getFields() {
    return 'name,cca2,cca3,capital,region,subregion,population,area,languages,currencies,flags,coatOfArms,latlng,borders,timezones,translations';
  }

  /// Handle Dio errors
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
        if (statusCode == 404) {
          return const ServerException(
            message: 'Resource not found',
            statusCode: 404,
          );
        }
        return ServerException(
          message: 'Server error occurred',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'An error occurred',
        );
    }
  }
}
