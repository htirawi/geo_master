/// News article model from NewsAPI
class NewsArticleModel {
  const NewsArticleModel({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    this.author,
    this.source,
    this.publishedAt,
    this.content,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    // Parse source
    String? source;
    final sourceData = json['source'] as Map<String, dynamic>?;
    if (sourceData != null) {
      source = sourceData['name'] as String?;
    }

    return NewsArticleModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      author: json['author'] as String?,
      source: source,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      content: json['content'] as String?,
    );
  }

  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String? author;
  final String? source;
  final DateTime? publishedAt;
  final String? content;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'author': author,
      'source': source != null ? {'name': source} : null,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
    };
  }

  /// Check if article has image
  bool get hasImage => urlToImage != null && urlToImage!.isNotEmpty;

  /// Get time ago string
  String get timeAgo {
    if (publishedAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }

  /// Get short description
  String getShortDescription({int maxLength = 150}) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }
}

/// News API response model
class NewsResponseModel {
  const NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      status: json['status'] as String? ?? '',
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String status;
  final int totalResults;
  final List<NewsArticleModel> articles;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((e) => e.toJson()).toList(),
    };
  }

  /// Check if response is successful
  bool get isSuccess => status == 'ok';
}

/// News category enum
enum NewsCategory {
  general,
  business,
  entertainment,
  health,
  science,
  sports,
  technology;

  String get value => name;
}

/// News sort order enum
enum NewsSortBy {
  relevancy,
  popularity,
  publishedAt;

  String get value => name;
}
