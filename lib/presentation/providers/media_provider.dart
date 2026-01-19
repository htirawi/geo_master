import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../data/models/news_model.dart';
import '../../data/models/unsplash_model.dart';
import '../../data/models/youtube_model.dart';
import '../../domain/repositories/i_media_repository.dart';

/// Country photos provider
final countryPhotosProvider = FutureProvider.family<List<UnsplashPhotoModel>, String>(
  (ref, countryName) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getCountryPhotos(countryName);
    return result.fold(
      (_) => [],
      (photos) => photos,
    );
  },
);

/// Place photos provider
final placePhotosProvider = FutureProvider.family<List<UnsplashPhotoModel>, String>(
  (ref, placeName) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getPlacePhotos(placeName);
    return result.fold(
      (_) => [],
      (photos) => photos,
    );
  },
);

/// Search photos provider
final searchPhotosProvider = FutureProvider.family<List<UnsplashPhotoModel>, String>(
  (ref, query) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.searchPhotos(query);
    return result.fold(
      (_) => [],
      (photos) => photos,
    );
  },
);

/// Random photos provider
final randomPhotosProvider = FutureProvider.family<List<UnsplashPhotoModel>, String?>(
  (ref, query) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getRandomPhotos(query: query, count: 5);
    return result.fold(
      (_) => [],
      (photos) => photos,
    );
  },
);

/// Country videos provider
final countryVideosProvider = FutureProvider.family<List<YouTubeVideoModel>, String>(
  (ref, countryName) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getCountryVideos(countryName);
    return result.fold(
      (_) => [],
      (videos) => videos,
    );
  },
);

/// Place videos provider (virtual tours)
final placeVideosProvider = FutureProvider.family<List<YouTubeVideoModel>, String>(
  (ref, placeName) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getPlaceVideos(placeName);
    return result.fold(
      (_) => [],
      (videos) => videos,
    );
  },
);

/// Search videos provider
final searchVideosProvider = FutureProvider.family<List<YouTubeVideoModel>, String>(
  (ref, query) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.searchVideos(query);
    return result.fold(
      (_) => [],
      (videos) => videos,
    );
  },
);

/// Country news provider
final countryNewsProvider = FutureProvider.family<List<NewsArticleModel>, String>(
  (ref, countryName) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getCountryNews(countryName);
    return result.fold(
      (_) => [],
      (news) => news,
    );
  },
);

/// Top headlines provider
final topHeadlinesProvider = FutureProvider.family<List<NewsArticleModel>, String?>(
  (ref, country) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getTopHeadlines(country: country);
    return result.fold(
      (_) => [],
      (news) => news,
    );
  },
);

/// Wikipedia summary provider
final wikipediaSummaryProvider = FutureProvider.family<WikipediaSummary?, String>(
  (ref, title) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getWikipediaSummary(title);
    return result.fold(
      (_) => null,
      (summary) => summary,
    );
  },
);

/// Media gallery state
class MediaGalleryState {
  const MediaGalleryState({
    this.photos = const [],
    this.videos = const [],
    this.news = const [],
    this.isLoading = false,
  });

  final List<UnsplashPhotoModel> photos;
  final List<YouTubeVideoModel> videos;
  final List<NewsArticleModel> news;
  final bool isLoading;

  MediaGalleryState copyWith({
    List<UnsplashPhotoModel>? photos,
    List<YouTubeVideoModel>? videos,
    List<NewsArticleModel>? news,
    bool? isLoading,
  }) {
    return MediaGalleryState(
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Media gallery notifier
class MediaGalleryNotifier extends StateNotifier<MediaGalleryState> {
  MediaGalleryNotifier(this._repository) : super(const MediaGalleryState());

  final IMediaRepository _repository;

  /// Load all media for a country
  Future<void> loadCountryMedia(String countryName) async {
    state = state.copyWith(isLoading: true);

    // Load in parallel
    final results = await Future.wait([
      _repository.getCountryPhotos(countryName),
      _repository.getCountryVideos(countryName),
      _repository.getCountryNews(countryName),
    ]);

    state = MediaGalleryState(
      photos: results[0].fold((_) => [], (p) => p as List<UnsplashPhotoModel>),
      videos: results[1].fold((_) => [], (v) => v as List<YouTubeVideoModel>),
      news: results[2].fold((_) => [], (n) => n as List<NewsArticleModel>),
      isLoading: false,
    );
  }

  /// Load photos only
  Future<void> loadPhotos(String query) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.searchPhotos(query);
    state = state.copyWith(
      photos: result.fold((_) => [], (p) => p),
      isLoading: false,
    );
  }

  /// Clear media
  void clear() {
    state = const MediaGalleryState();
  }
}

/// Media gallery provider (per country)
final mediaGalleryProvider = StateNotifierProvider.family<
    MediaGalleryNotifier, MediaGalleryState, String>(
  (ref, countryName) {
    final repository = sl<IMediaRepository>();
    final notifier = MediaGalleryNotifier(repository);
    notifier.loadCountryMedia(countryName);
    return notifier;
  },
);

/// Selected media item for full screen view
final selectedPhotoProvider = StateProvider<UnsplashPhotoModel?>((ref) => null);
final selectedVideoProvider = StateProvider<YouTubeVideoModel?>((ref) => null);
final selectedNewsProvider = StateProvider<NewsArticleModel?>((ref) => null);

/// Media filter state
enum MediaFilter { all, photos, videos, news }

final mediaFilterProvider = StateProvider<MediaFilter>((ref) => MediaFilter.all);
