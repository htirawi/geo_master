import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/input_sanitizer.dart';
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
      throw ServerException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<CountryModel> getCountryByCode(String code) async {
    try {
      // Sanitize and URL-encode the country code
      final sanitizedCode = InputSanitizer.sanitizeSearchQuery(code);
      if (sanitizedCode.isEmpty) {
        throw const ServerException(
          message: 'Invalid country code',
          statusCode: 400,
        );
      }
      final encodedCode = InputSanitizer.urlEncode(sanitizedCode);

      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByCode}/$encodedCode',
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
      throw ServerException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<List<CountryModel>> getCountriesByRegion(String region) async {
    try {
      // Sanitize and URL-encode the region
      final sanitizedRegion = InputSanitizer.sanitizeSearchQuery(region);
      if (sanitizedRegion.isEmpty) {
        return [];
      }
      final encodedRegion = InputSanitizer.urlEncode(sanitizedRegion);

      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByRegion}/$encodedRegion',
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
      throw ServerException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<List<CountryModel>> searchCountriesByName(String name) async {
    try {
      // Sanitize and URL-encode the search query
      final sanitizedName = InputSanitizer.sanitizeSearchQuery(name);
      if (sanitizedName.isEmpty) {
        return [];
      }
      final encodedName = InputSanitizer.urlEncode(sanitizedName);

      final response = await _dio.get<List<dynamic>>(
        '${ApiEndpoints.restCountriesByName}/$encodedName',
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
      throw ServerException(message: 'An unexpected error occurred');
    }
  }

  /// Get the fields parameter for API requests
  /// NOTE: REST Countries API has a 10 field limit
  String _getFields() {
    // Essential fields only (10 max)
    return 'name,cca2,cca3,capital,region,subregion,population,area,flags,latlng';
  }

  /// Get extended fields for single country lookups
  String _getExtendedFields() {
    return 'name,cca2,cca3,capital,region,subregion,population,area,flags,borders';
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
