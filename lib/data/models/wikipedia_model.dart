/// Wikipedia API response model
class WikipediaSummaryModel {
  const WikipediaSummaryModel({
    required this.title,
    required this.extract,
    this.description,
    this.thumbnailUrl,
    this.originalImageUrl,
    this.pageUrl,
    this.coordinates,
  });

  factory WikipediaSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parse thumbnail
    String? thumbnailUrl;
    String? originalImageUrl;
    final thumbnail = json['thumbnail'] as Map<String, dynamic>?;
    if (thumbnail != null) {
      thumbnailUrl = thumbnail['source'] as String?;
    }
    final originalImage = json['originalimage'] as Map<String, dynamic>?;
    if (originalImage != null) {
      originalImageUrl = originalImage['source'] as String?;
    }

    // Parse coordinates
    WikipediaCoordinates? coordinates;
    final coordData = json['coordinates'] as Map<String, dynamic>?;
    if (coordData != null) {
      coordinates = WikipediaCoordinates(
        latitude: (coordData['lat'] as num?)?.toDouble() ?? 0,
        longitude: (coordData['lon'] as num?)?.toDouble() ?? 0,
      );
    }

    // Parse content URLs
    String? pageUrl;
    final contentUrls = json['content_urls'] as Map<String, dynamic>?;
    if (contentUrls != null) {
      final desktop = contentUrls['desktop'] as Map<String, dynamic>?;
      pageUrl = desktop?['page'] as String?;
    }

    return WikipediaSummaryModel(
      title: json['title'] as String? ?? '',
      extract: json['extract'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: thumbnailUrl,
      originalImageUrl: originalImageUrl,
      pageUrl: pageUrl,
      coordinates: coordinates,
    );
  }

  final String title;
  final String extract;
  final String? description;
  final String? thumbnailUrl;
  final String? originalImageUrl;
  final String? pageUrl;
  final WikipediaCoordinates? coordinates;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'extract': extract,
      'description': description,
      'thumbnail': thumbnailUrl != null ? {'source': thumbnailUrl} : null,
      'originalimage':
          originalImageUrl != null ? {'source': originalImageUrl} : null,
      'content_urls': pageUrl != null
          ? {
              'desktop': {'page': pageUrl}
            }
          : null,
      'coordinates': coordinates != null
          ? {'lat': coordinates!.latitude, 'lon': coordinates!.longitude}
          : null,
    };
  }

  /// Get a shortened extract
  String getShortExtract({int maxLength = 200}) {
    if (extract.length <= maxLength) return extract;
    return '${extract.substring(0, maxLength)}...';
  }
}

/// Wikipedia coordinates model
class WikipediaCoordinates {
  const WikipediaCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Wikipedia search result model
class WikipediaSearchResultModel {
  const WikipediaSearchResultModel({
    required this.pageId,
    required this.title,
    this.snippet,
    this.thumbnailUrl,
  });

  factory WikipediaSearchResultModel.fromJson(Map<String, dynamic> json) {
    String? thumbnailUrl;
    final thumbnail = json['thumbnail'] as Map<String, dynamic>?;
    if (thumbnail != null) {
      thumbnailUrl = thumbnail['source'] as String?;
    }

    return WikipediaSearchResultModel(
      pageId: (json['pageid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String?,
      thumbnailUrl: thumbnailUrl,
    );
  }

  final int pageId;
  final String title;
  final String? snippet;
  final String? thumbnailUrl;

  Map<String, dynamic> toJson() {
    return {
      'pageid': pageId,
      'title': title,
      'snippet': snippet,
      'thumbnail': thumbnailUrl != null ? {'source': thumbnailUrl} : null,
    };
  }
}
