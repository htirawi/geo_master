import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/wikipedia_model.dart';

/// Wikipedia API data source interface
abstract class IWikipediaDataSource {
  /// Get summary for a page title
  Future<WikipediaSummaryModel> getSummary(String title, {bool isArabic = false});

  /// Get summary for a country
  Future<WikipediaSummaryModel> getCountrySummary(String countryName, {bool isArabic = false});

  /// Search Wikipedia
  Future<List<WikipediaSearchResultModel>> search(String query, {int limit = 10});
}

/// Wikipedia REST API data source implementation
class WikipediaDataSource implements IWikipediaDataSource {
  WikipediaDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<WikipediaSummaryModel> getSummary(String title, {bool isArabic = false}) async {
    try {
      final baseUrl = isArabic
          ? ApiEndpoints.wikipediaArabicSummary
          : ApiEndpoints.wikipediaSummary;

      // URL encode the title
      final encodedTitle = Uri.encodeComponent(title.replaceAll(' ', '_'));

      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/$encodedTitle',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return WikipediaSummaryModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch Wikipedia summary',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Wikipedia API error: $e');
    }
  }

  @override
  Future<WikipediaSummaryModel> getCountrySummary(String countryName, {bool isArabic = false}) async {
    // Try to get the country page directly
    return getSummary(countryName, isArabic: isArabic);
  }

  @override
  Future<List<WikipediaSearchResultModel>> search(String query, {int limit = 10}) async {
    try {
      // Using the MediaWiki API for search
      final response = await _dio.get<Map<String, dynamic>>(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'search',
          'srsearch': query,
          'srlimit': limit,
          'format': 'json',
          'origin': '*',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final query = response.data!['query'] as Map<String, dynamic>?;
        if (query == null) return [];

        final search = query['search'] as List<dynamic>?;
        if (search == null) return [];

        return search
            .map((item) => WikipediaSearchResultModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to search Wikipedia',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Wikipedia search error: $e');
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
        if (statusCode == 404) {
          return const ServerException(
            message: 'Wikipedia page not found',
            code: 'PAGE_NOT_FOUND',
            statusCode: 404,
          );
        }
        return ServerException(
          message: 'Wikipedia server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'Wikipedia API error',
        );
    }
  }
}
