/// YouTube video model from YouTube Data API v3
class YouTubeVideoModel {
  const YouTubeVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelId,
    required this.channelTitle,
    this.publishedAt,
    this.duration,
    this.viewCount,
    this.likeCount,
    this.tags = const [],
  });

  factory YouTubeVideoModel.fromJson(Map<String, dynamic> json) {
    // Parse from search result format
    String videoId = '';
    if (json['id'] is Map<String, dynamic>) {
      videoId = (json['id'] as Map<String, dynamic>)['videoId'] as String? ?? '';
    } else if (json['id'] is String) {
      videoId = json['id'] as String;
    }

    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};

    // Parse thumbnail
    String thumbnailUrl = '';
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
    if (thumbnails != null) {
      // Prefer high quality, fallback to medium, then default
      final high = thumbnails['high'] as Map<String, dynamic>?;
      final medium = thumbnails['medium'] as Map<String, dynamic>?;
      final defaultThumb = thumbnails['default'] as Map<String, dynamic>?;
      thumbnailUrl = high?['url'] as String? ??
          medium?['url'] as String? ??
          defaultThumb?['url'] as String? ??
          '';
    }

    // Parse duration and statistics from contentDetails and statistics
    String? duration;
    int? viewCount;
    int? likeCount;

    final contentDetails = json['contentDetails'] as Map<String, dynamic>?;
    if (contentDetails != null) {
      duration = contentDetails['duration'] as String?;
    }

    final statistics = json['statistics'] as Map<String, dynamic>?;
    if (statistics != null) {
      viewCount = int.tryParse(statistics['viewCount']?.toString() ?? '');
      likeCount = int.tryParse(statistics['likeCount']?.toString() ?? '');
    }

    return YouTubeVideoModel(
      id: videoId,
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      thumbnailUrl: thumbnailUrl,
      channelId: snippet['channelId'] as String? ?? '',
      channelTitle: snippet['channelTitle'] as String? ?? '',
      publishedAt: snippet['publishedAt'] != null
          ? DateTime.tryParse(snippet['publishedAt'] as String)
          : null,
      duration: duration,
      viewCount: viewCount,
      likeCount: likeCount,
      tags: (snippet['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelId;
  final String channelTitle;
  final DateTime? publishedAt;
  final String? duration; // ISO 8601 duration format
  final int? viewCount;
  final int? likeCount;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'id': {'videoId': id},
      'snippet': {
        'title': title,
        'description': description,
        'thumbnails': {
          'high': {'url': thumbnailUrl}
        },
        'channelId': channelId,
        'channelTitle': channelTitle,
        'publishedAt': publishedAt?.toIso8601String(),
        'tags': tags,
      },
      'contentDetails': duration != null ? {'duration': duration} : null,
      'statistics': {
        'viewCount': viewCount?.toString(),
        'likeCount': likeCount?.toString(),
      },
    };
  }

  /// Get video URL
  String get videoUrl => 'https://www.youtube.com/watch?v=$id';

  /// Get embed URL
  String get embedUrl => 'https://www.youtube.com/embed/$id';

  /// Get formatted view count
  String get formattedViewCount {
    if (viewCount == null) return 'N/A';
    if (viewCount! >= 1000000000) {
      return '${(viewCount! / 1000000000).toStringAsFixed(1)}B views';
    } else if (viewCount! >= 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount! >= 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }

  /// Parse ISO 8601 duration to readable format
  String get formattedDuration {
    if (duration == null) return '';

    // Parse PT format (e.g., PT1H2M3S)
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration!);

    if (match == null) return '';

    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '') ?? 0;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// YouTube search response model
class YouTubeSearchResponseModel {
  const YouTubeSearchResponseModel({
    required this.items,
    this.nextPageToken,
    this.prevPageToken,
    this.totalResults,
  });

  factory YouTubeSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final pageInfo = json['pageInfo'] as Map<String, dynamic>?;

    return YouTubeSearchResponseModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => YouTubeVideoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextPageToken: json['nextPageToken'] as String?,
      prevPageToken: json['prevPageToken'] as String?,
      totalResults: (pageInfo?['totalResults'] as num?)?.toInt(),
    );
  }

  final List<YouTubeVideoModel> items;
  final String? nextPageToken;
  final String? prevPageToken;
  final int? totalResults;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'nextPageToken': nextPageToken,
      'prevPageToken': prevPageToken,
      'pageInfo': totalResults != null ? {'totalResults': totalResults} : null,
    };
  }
}
