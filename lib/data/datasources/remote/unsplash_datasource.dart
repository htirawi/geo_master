import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/unsplash_model.dart';

/// Unsplash API data source interface
abstract class IUnsplashDataSource {
  /// Search photos by query
  Future<UnsplashSearchResponseModel> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 10,
    String? orientation,
    String? color,
  });

  /// Get random photos
  Future<List<UnsplashPhotoModel>> getRandomPhotos({
    String? query,
    int count = 1,
    String? orientation,
  });

  /// Get photos for a country
  Future<UnsplashSearchResponseModel> getCountryPhotos(
    String countryName, {
    int page = 1,
    int perPage = 10,
  });

  /// Get photos for a place of interest
  Future<UnsplashSearchResponseModel> getPlacePhotos(
    String placeName, {
    int page = 1,
    int perPage = 10,
  });
}

/// Unsplash API data source implementation
class UnsplashDataSource implements IUnsplashDataSource {
  UnsplashDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  @override
  Future<UnsplashSearchResponseModel> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 10,
    String? orientation,
    String? color,
  }) async {
    _validateApiKey();

    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'page': page,
        'per_page': perPage,
      };

      if (orientation != null) {
        queryParams['orientation'] = orientation;
      }
      if (color != null) {
        queryParams['color'] = color;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.unsplashSearch,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Client-ID $_apiKey',
            'Accept-Version': 'v1',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UnsplashSearchResponseModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to search Unsplash photos',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(message: 'Unsplash API error');
    }
  }

  @override
  Future<List<UnsplashPhotoModel>> getRandomPhotos({
    String? query,
    int count = 1,
    String? orientation,
  }) async {
    _validateApiKey();

    try {
      final queryParams = <String, dynamic>{
        'count': count,
      };

      if (query != null) {
        queryParams['query'] = query;
      }
      if (orientation != null) {
        queryParams['orientation'] = orientation;
      }

      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.unsplashRandom,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Client-ID $_apiKey',
            'Accept-Version': 'v1',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((json) => UnsplashPhotoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to get random photos',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw const ServerException(message: 'Unsplash API error');
    }
  }

  @override
  Future<UnsplashSearchResponseModel> getCountryPhotos(
    String countryName, {
    int page = 1,
    int perPage = 10,
  }) async {
    // Add context to the search query for better results
    return searchPhotos(
      query: '$countryName travel landscape',
      page: page,
      perPage: perPage,
      orientation: 'landscape',
    );
  }

  @override
  Future<UnsplashSearchResponseModel> getPlacePhotos(
    String placeName, {
    int page = 1,
    int perPage = 10,
  }) async {
    return searchPhotos(
      query: placeName,
      page: page,
      perPage: perPage,
    );
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const ServerException(
        message: 'Unsplash API key not configured',
        code: 'NO_API_KEY',
      );
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
            message: 'Invalid Unsplash API key',
            code: 'INVALID_API_KEY',
            statusCode: 401,
          );
        }
        if (statusCode == 403) {
          return const ServerException(
            message: 'Unsplash rate limit exceeded',
            code: 'RATE_LIMIT',
            statusCode: 403,
          );
        }
        return ServerException(
          message: 'Unsplash server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'Unsplash API error',
        );
    }
  }
}
