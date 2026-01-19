import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/youtube_model.dart';

/// YouTube API data source interface
abstract class IYouTubeDataSource {
  /// Search videos
  Future<YouTubeSearchResponseModel> searchVideos({
    required String query,
    int maxResults = 10,
    String? pageToken,
    String? regionCode,
    String? relevanceLanguage,
  });

  /// Get video details by IDs
  Future<List<YouTubeVideoModel>> getVideoDetails(List<String> videoIds);

  /// Get country travel videos
  Future<YouTubeSearchResponseModel> getCountryVideos(
    String countryName, {
    int maxResults = 10,
    String? pageToken,
  });

  /// Get place virtual tour videos
  Future<YouTubeSearchResponseModel> getPlaceVideos(
    String placeName, {
    int maxResults = 5,
  });
}

/// YouTube Data API v3 data source implementation
class YouTubeDataSource implements IYouTubeDataSource {
  YouTubeDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  @override
  Future<YouTubeSearchResponseModel> searchVideos({
    required String query,
    int maxResults = 10,
    String? pageToken,
    String? regionCode,
    String? relevanceLanguage,
  }) async {
    _validateApiKey();

    try {
      final queryParams = <String, dynamic>{
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'maxResults': maxResults,
        'key': _apiKey,
        'safeSearch': 'strict',
        'videoEmbeddable': 'true',
      };

      if (pageToken != null) {
        queryParams['pageToken'] = pageToken;
      }
      if (regionCode != null) {
        queryParams['regionCode'] = regionCode;
      }
      if (relevanceLanguage != null) {
        queryParams['relevanceLanguage'] = relevanceLanguage;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.youtubeSearch,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return YouTubeSearchResponseModel.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to search YouTube videos',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'YouTube API error: $e');
    }
  }

  @override
  Future<List<YouTubeVideoModel>> getVideoDetails(List<String> videoIds) async {
    _validateApiKey();

    if (videoIds.isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.youtubeVideos,
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds.join(','),
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final items = response.data!['items'] as List<dynamic>?;
        if (items == null) return [];

        return items
            .map((json) => YouTubeVideoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to get video details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'YouTube API error: $e');
    }
  }

  @override
  Future<YouTubeSearchResponseModel> getCountryVideos(
    String countryName, {
    int maxResults = 10,
    String? pageToken,
  }) async {
    // Search for travel documentaries and guides
    return searchVideos(
      query: '$countryName travel guide documentary',
      maxResults: maxResults,
      pageToken: pageToken,
    );
  }

  @override
  Future<YouTubeSearchResponseModel> getPlaceVideos(
    String placeName, {
    int maxResults = 5,
  }) async {
    // Search for virtual tours and travel videos
    return searchVideos(
      query: '$placeName virtual tour 4k',
      maxResults: maxResults,
    );
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const ServerException(
        message: 'YouTube API key not configured',
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
        final error = data?['error'] as Map<String, dynamic>?;
        final errors = error?['errors'] as List<dynamic>?;
        final reason = errors?.firstOrNull as Map<String, dynamic>?;
        final reasonStr = reason?['reason'] as String?;

        if (statusCode == 403) {
          if (reasonStr == 'quotaExceeded') {
            return const ServerException(
              message: 'YouTube API quota exceeded for today',
              code: 'QUOTA_EXCEEDED',
              statusCode: 403,
            );
          }
          return const ServerException(
            message: 'YouTube API access forbidden',
            code: 'FORBIDDEN',
            statusCode: 403,
          );
        }
        if (statusCode == 401) {
          return const ServerException(
            message: 'Invalid YouTube API key',
            code: 'INVALID_API_KEY',
            statusCode: 401,
          );
        }
        return ServerException(
          message: 'YouTube server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'YouTube API error',
        );
    }
  }
}
