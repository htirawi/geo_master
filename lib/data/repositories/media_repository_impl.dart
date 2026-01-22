import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../datasources/remote/exchange_rate_datasource.dart';
import '../datasources/remote/news_datasource.dart';
import '../datasources/remote/timezone_datasource.dart';
import '../datasources/remote/unsplash_datasource.dart';
import '../datasources/remote/wikipedia_datasource.dart';
import '../datasources/remote/youtube_datasource.dart';
import '../models/exchange_rate_model.dart';
import '../models/news_model.dart';
import '../models/unsplash_model.dart';
import '../models/youtube_model.dart';

/// Media repository implementation
class MediaRepositoryImpl implements IMediaRepository {
  MediaRepositoryImpl({
    required IUnsplashDataSource unsplashDataSource,
    required IYouTubeDataSource youtubeDataSource,
    required INewsDataSource newsDataSource,
    required IExchangeRateDataSource exchangeRateDataSource,
    required ITimezoneDataSource timezoneDataSource,
    required IWikipediaDataSource wikipediaDataSource,
  })  : _unsplashDataSource = unsplashDataSource,
        _youtubeDataSource = youtubeDataSource,
        _newsDataSource = newsDataSource,
        _exchangeRateDataSource = exchangeRateDataSource,
        _timezoneDataSource = timezoneDataSource,
        _wikipediaDataSource = wikipediaDataSource;

  final IUnsplashDataSource _unsplashDataSource;
  final IYouTubeDataSource _youtubeDataSource;
  final INewsDataSource _newsDataSource;
  final IExchangeRateDataSource _exchangeRateDataSource;
  final ITimezoneDataSource _timezoneDataSource;
  final IWikipediaDataSource _wikipediaDataSource;

  // Images (Unsplash)

  @override
  Future<Either<Failure, List<UnsplashPhotoModel>>> getCountryPhotos(
    String countryName, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _unsplashDataSource.getCountryPhotos(
        countryName,
        page: page,
        perPage: perPage,
      );
      return Right(response.results);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching country photos', tag: 'MediaRepo', error: e);
      return Left(ServerFailure(message: 'Failed to fetch photos'));
    }
  }

  @override
  Future<Either<Failure, List<UnsplashPhotoModel>>> getPlacePhotos(
    String placeName, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _unsplashDataSource.getPlacePhotos(
        placeName,
        page: page,
        perPage: perPage,
      );
      return Right(response.results);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch photos'));
    }
  }

  @override
  Future<Either<Failure, List<UnsplashPhotoModel>>> searchPhotos(
    String query, {
    int page = 1,
    int perPage = 10,
    String? orientation,
  }) async {
    try {
      final response = await _unsplashDataSource.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
        orientation: orientation,
      );
      return Right(response.results);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search photos'));
    }
  }

  @override
  Future<Either<Failure, List<UnsplashPhotoModel>>> getRandomPhotos({
    String? query,
    int count = 5,
  }) async {
    try {
      final photos = await _unsplashDataSource.getRandomPhotos(
        query: query,
        count: count,
      );
      return Right(photos);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get random photos'));
    }
  }

  // Videos (YouTube)

  @override
  Future<Either<Failure, List<YouTubeVideoModel>>> getCountryVideos(
    String countryName, {
    int maxResults = 10,
    String? pageToken,
  }) async {
    try {
      final response = await _youtubeDataSource.getCountryVideos(
        countryName,
        maxResults: maxResults,
        pageToken: pageToken,
      );
      return Right(response.items);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching country videos', tag: 'MediaRepo', error: e);
      return Left(ServerFailure(message: 'Failed to fetch videos'));
    }
  }

  @override
  Future<Either<Failure, List<YouTubeVideoModel>>> getPlaceVideos(
    String placeName, {
    int maxResults = 5,
  }) async {
    try {
      final response = await _youtubeDataSource.getPlaceVideos(
        placeName,
        maxResults: maxResults,
      );
      return Right(response.items);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch videos'));
    }
  }

  @override
  Future<Either<Failure, List<YouTubeVideoModel>>> searchVideos(
    String query, {
    int maxResults = 10,
    String? pageToken,
  }) async {
    try {
      final response = await _youtubeDataSource.searchVideos(
        query: query,
        maxResults: maxResults,
        pageToken: pageToken,
      );
      return Right(response.items);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search videos'));
    }
  }

  @override
  Future<Either<Failure, List<YouTubeVideoModel>>> getVideoDetails(
    List<String> videoIds,
  ) async {
    try {
      final videos = await _youtubeDataSource.getVideoDetails(videoIds);
      return Right(videos);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get video details'));
    }
  }

  // News

  @override
  Future<Either<Failure, List<NewsArticleModel>>> getCountryNews(
    String countryName, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _newsDataSource.getCountryNews(
        countryName,
        page: page,
        pageSize: pageSize,
      );
      return Right(response.articles);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching country news', tag: 'MediaRepo', error: e);
      return Left(ServerFailure(message: 'Failed to fetch news'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleModel>>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _newsDataSource.getTopHeadlines(
        country: country,
        category: category,
        page: page,
        pageSize: pageSize,
      );
      return Right(response.articles);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch headlines'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleModel>>> searchNews(
    String query, {
    int page = 1,
    int pageSize = 10,
    String? sortBy,
  }) async {
    try {
      final response = await _newsDataSource.getNews(
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
      );
      return Right(response.articles);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search news'));
    }
  }

  // Exchange Rates

  @override
  Future<Either<Failure, ExchangeRateModel>> getExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    try {
      final rates = await _exchangeRateDataSource.getLatestRates(
        baseCurrency: baseCurrency,
      );
      return Right(rates);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching exchange rates', tag: 'MediaRepo', error: e);
      return Left(ServerFailure(message: 'Failed to fetch rates'));
    }
  }

  @override
  Future<Either<Failure, CurrencyConversionModel>> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final conversion = await _exchangeRateDataSource.convert(
        amount: amount,
        from: from,
        to: to,
      );
      return Right(conversion);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to convert currency'));
    }
  }

  @override
  Future<Either<Failure, double>> getExchangeRate({
    required String from,
    required String to,
  }) async {
    try {
      final rate = await _exchangeRateDataSource.getRate(from: from, to: to);
      return Right(rate);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rate'));
    }
  }

  // Timezone

  @override
  Future<Either<Failure, TimezoneInfo>> getTimezoneInfo(String timezone) async {
    try {
      final info = await _timezoneDataSource.getTimezone(timezone);
      return Right(info);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      logger.error('Error fetching timezone', tag: 'MediaRepo', error: e);
      return Left(ServerFailure(message: 'Failed to fetch timezone'));
    }
  }

  @override
  Future<Either<Failure, TimezoneInfo>> getCountryTime(String timezone) async {
    return getTimezoneInfo(timezone);
  }

  @override
  Future<Either<Failure, Duration>> getTimeDifference(
    String fromTimezone,
    String toTimezone,
  ) async {
    try {
      final difference = await _timezoneDataSource.getTimeDifference(
        fromTimezone,
        toTimezone,
      );
      return Right(difference);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get time difference'));
    }
  }

  // Wikipedia

  @override
  Future<Either<Failure, WikipediaSummary>> getWikipediaSummary(
    String title, {
    bool isArabic = false,
  }) async {
    try {
      final summary = await _wikipediaDataSource.getSummary(
        title,
        isArabic: isArabic,
      );
      return Right(WikipediaSummary(
        title: summary.title,
        extract: summary.extract,
        description: summary.description,
        thumbnailUrl: summary.thumbnailUrl,
        pageUrl: summary.pageUrl,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch Wikipedia'));
    }
  }

  // Cache

  @override
  Future<Either<Failure, void>> clearCache() async {
    // Media repository doesn't maintain its own cache
    // Data sources handle their own caching
    return const Right(null);
  }
}
