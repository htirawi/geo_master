import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/news_model.dart';

/// News API data source interface
abstract class INewsDataSource {
  /// Get news articles
  Future<NewsResponseModel> getNews({
    String? query,
    String? country,
    String? category,
    String? sources,
    String? language,
    String? sortBy,
    int page = 1,
    int pageSize = 10,
  });

  /// Get top headlines
  Future<NewsResponseModel> getTopHeadlines({
    String? country,
    String? category,
    String? query,
    int page = 1,
    int pageSize = 10,
  });

  /// Get news for a country
  Future<NewsResponseModel> getCountryNews(
    String countryName, {
    int page = 1,
    int pageSize = 10,
  });
}

/// NewsAPI data source implementation
class NewsDataSource implements INewsDataSource {
  NewsDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  @override
  Future<NewsResponseModel> getNews({
    String? query,
    String? country,
    String? category,
    String? sources,
    String? language,
    String? sortBy,
    int page = 1,
    int pageSize = 10,
  }) async {
    _validateApiKey();

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'apiKey': _apiKey,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (language != null) {
        queryParams['language'] = language;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      if (sources != null) {
        queryParams['sources'] = sources;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.newsEverything,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NewsResponseModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch news',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'News API error: $e');
    }
  }

  @override
  Future<NewsResponseModel> getTopHeadlines({
    String? country,
    String? category,
    String? query,
    int page = 1,
    int pageSize = 10,
  }) async {
    _validateApiKey();

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'apiKey': _apiKey,
      };

      if (country != null) {
        queryParams['country'] = country;
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.newsTopHeadlines,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return NewsResponseModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch headlines',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'News API error: $e');
    }
  }

  @override
  Future<NewsResponseModel> getCountryNews(
    String countryName, {
    int page = 1,
    int pageSize = 10,
  }) async {
    return getNews(
      query: countryName,
      language: 'en',
      sortBy: 'publishedAt',
      page: page,
      pageSize: pageSize,
    );
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const ServerException(
        message: 'News API key not configured',
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
        final data = e.response?.data as Map<String, dynamic>?;
        final code = data?['code'] as String?;

        if (statusCode == 401 || code == 'apiKeyInvalid') {
          return const ServerException(
            message: 'Invalid News API key',
            code: 'INVALID_API_KEY',
            statusCode: 401,
          );
        }
        if (statusCode == 426 || code == 'upgradeRequired') {
          return const ServerException(
            message: 'News API plan upgrade required',
            code: 'UPGRADE_REQUIRED',
            statusCode: 426,
          );
        }
        if (statusCode == 429 || code == 'rateLimited') {
          return const ServerException(
            message: 'News API rate limit exceeded',
            code: 'RATE_LIMIT',
            statusCode: 429,
          );
        }
        return ServerException(
          message: data?['message'] as String? ?? 'News server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'News API error',
        );
    }
  }
}
