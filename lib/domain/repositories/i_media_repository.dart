import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/datasources/remote/timezone_datasource.dart';
import '../../data/models/exchange_rate_model.dart';
import '../../data/models/news_model.dart';
import '../../data/models/unsplash_model.dart';
import '../../data/models/youtube_model.dart';

/// Media repository interface for images, videos, news, and external content
abstract class IMediaRepository {
  // Images (Unsplash)

  /// Get photos for a country
  Future<Either<Failure, List<UnsplashPhotoModel>>> getCountryPhotos(
    String countryName, {
    int page = 1,
    int perPage = 10,
  });

  /// Get photos for a place
  Future<Either<Failure, List<UnsplashPhotoModel>>> getPlacePhotos(
    String placeName, {
    int page = 1,
    int perPage = 10,
  });

  /// Search photos
  Future<Either<Failure, List<UnsplashPhotoModel>>> searchPhotos(
    String query, {
    int page = 1,
    int perPage = 10,
    String? orientation,
  });

  /// Get random photos for a topic
  Future<Either<Failure, List<UnsplashPhotoModel>>> getRandomPhotos({
    String? query,
    int count = 5,
  });

  // Videos (YouTube)

  /// Get travel videos for a country
  Future<Either<Failure, List<YouTubeVideoModel>>> getCountryVideos(
    String countryName, {
    int maxResults = 10,
    String? pageToken,
  });

  /// Get virtual tour videos for a place
  Future<Either<Failure, List<YouTubeVideoModel>>> getPlaceVideos(
    String placeName, {
    int maxResults = 5,
  });

  /// Search videos
  Future<Either<Failure, List<YouTubeVideoModel>>> searchVideos(
    String query, {
    int maxResults = 10,
    String? pageToken,
  });

  /// Get video details
  Future<Either<Failure, List<YouTubeVideoModel>>> getVideoDetails(
    List<String> videoIds,
  );

  // News

  /// Get news for a country
  Future<Either<Failure, List<NewsArticleModel>>> getCountryNews(
    String countryName, {
    int page = 1,
    int pageSize = 10,
  });

  /// Get top headlines
  Future<Either<Failure, List<NewsArticleModel>>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
    int pageSize = 10,
  });

  /// Search news
  Future<Either<Failure, List<NewsArticleModel>>> searchNews(
    String query, {
    int page = 1,
    int pageSize = 10,
    String? sortBy,
  });

  // Exchange Rates

  /// Get exchange rates for a base currency
  Future<Either<Failure, ExchangeRateModel>> getExchangeRates({
    String baseCurrency = 'USD',
  });

  /// Convert currency
  Future<Either<Failure, CurrencyConversionModel>> convertCurrency({
    required double amount,
    required String from,
    required String to,
  });

  /// Get exchange rate for a currency pair
  Future<Either<Failure, double>> getExchangeRate({
    required String from,
    required String to,
  });

  // Timezone

  /// Get timezone info for a timezone string
  Future<Either<Failure, TimezoneInfo>> getTimezoneInfo(String timezone);

  /// Get current time for a country
  Future<Either<Failure, TimezoneInfo>> getCountryTime(String timezone);

  /// Get time difference between user and country
  Future<Either<Failure, Duration>> getTimeDifference(
    String fromTimezone,
    String toTimezone,
  );

  // Wikipedia

  /// Get Wikipedia summary for a topic
  Future<Either<Failure, WikipediaSummary>> getWikipediaSummary(
    String title, {
    bool isArabic = false,
  });

  // Cache

  /// Clear media cache
  Future<Either<Failure, void>> clearCache();
}

/// Wikipedia summary result
class WikipediaSummary {
  const WikipediaSummary({
    required this.title,
    required this.extract,
    this.description,
    this.thumbnailUrl,
    this.pageUrl,
  });

  final String title;
  final String extract;
  final String? description;
  final String? thumbnailUrl;
  final String? pageUrl;

  /// Get a shortened version of the extract
  String getShortExtract({int maxLength = 200}) {
    if (extract.length <= maxLength) return extract;
    return '${extract.substring(0, maxLength)}...';
  }
}
