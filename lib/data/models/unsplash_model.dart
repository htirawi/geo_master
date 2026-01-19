/// Unsplash photo model from Unsplash API
class UnsplashPhotoModel {
  const UnsplashPhotoModel({
    required this.id,
    required this.description,
    required this.altDescription,
    required this.urls,
    required this.user,
    this.width,
    this.height,
    this.color,
    this.likes,
    this.createdAt,
    this.location,
  });

  factory UnsplashPhotoModel.fromJson(Map<String, dynamic> json) {
    return UnsplashPhotoModel(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      altDescription: json['alt_description'] as String? ?? '',
      urls: UnsplashUrlsModel.fromJson(
          json['urls'] as Map<String, dynamic>? ?? {}),
      user: UnsplashUserModel.fromJson(
          json['user'] as Map<String, dynamic>? ?? {}),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      color: json['color'] as String?,
      likes: (json['likes'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      location: json['location'] != null
          ? UnsplashLocationModel.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String description;
  final String altDescription;
  final UnsplashUrlsModel urls;
  final UnsplashUserModel user;
  final int? width;
  final int? height;
  final String? color;
  final int? likes;
  final DateTime? createdAt;
  final UnsplashLocationModel? location;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'alt_description': altDescription,
      'urls': urls.toJson(),
      'user': user.toJson(),
      'width': width,
      'height': height,
      'color': color,
      'likes': likes,
      'created_at': createdAt?.toIso8601String(),
      'location': location?.toJson(),
    };
  }

  /// Get aspect ratio
  double get aspectRatio {
    if (width == null || height == null || height == 0) return 1.0;
    return width! / height!;
  }
}

/// Unsplash photo URLs model
class UnsplashUrlsModel {
  const UnsplashUrlsModel({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  factory UnsplashUrlsModel.fromJson(Map<String, dynamic> json) {
    return UnsplashUrlsModel(
      raw: json['raw'] as String? ?? '',
      full: json['full'] as String? ?? '',
      regular: json['regular'] as String? ?? '',
      small: json['small'] as String? ?? '',
      thumb: json['thumb'] as String? ?? '',
    );
  }

  final String raw;
  final String full;
  final String regular;
  final String small;
  final String thumb;

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'full': full,
      'regular': regular,
      'small': small,
      'thumb': thumb,
    };
  }
}

/// Unsplash user model
class UnsplashUserModel {
  const UnsplashUserModel({
    required this.id,
    required this.username,
    required this.name,
    this.portfolioUrl,
    this.profileImageUrl,
  });

  factory UnsplashUserModel.fromJson(Map<String, dynamic> json) {
    String? profileImageUrl;
    final profileImage = json['profile_image'] as Map<String, dynamic>?;
    if (profileImage != null) {
      profileImageUrl = profileImage['medium'] as String?;
    }

    return UnsplashUserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      portfolioUrl: json['portfolio_url'] as String?,
      profileImageUrl: profileImageUrl,
    );
  }

  final String id;
  final String username;
  final String name;
  final String? portfolioUrl;
  final String? profileImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'portfolio_url': portfolioUrl,
      'profile_image':
          profileImageUrl != null ? {'medium': profileImageUrl} : null,
    };
  }

  /// Get attribution link
  String get attributionLink =>
      'https://unsplash.com/@$username?utm_source=geomaster&utm_medium=referral';
}

/// Unsplash location model
class UnsplashLocationModel {
  const UnsplashLocationModel({
    this.name,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
  });

  factory UnsplashLocationModel.fromJson(Map<String, dynamic> json) {
    double? latitude;
    double? longitude;
    final position = json['position'] as Map<String, dynamic>?;
    if (position != null) {
      latitude = (position['latitude'] as num?)?.toDouble();
      longitude = (position['longitude'] as num?)?.toDouble();
    }

    return UnsplashLocationModel(
      name: json['name'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: latitude,
      longitude: longitude,
    );
  }

  final String? name;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'country': country,
      'position': latitude != null && longitude != null
          ? {'latitude': latitude, 'longitude': longitude}
          : null,
    };
  }
}

/// Unsplash search response model
class UnsplashSearchResponseModel {
  const UnsplashSearchResponseModel({
    required this.total,
    required this.totalPages,
    required this.results,
  });

  factory UnsplashSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return UnsplashSearchResponseModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) =>
                  UnsplashPhotoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final int total;
  final int totalPages;
  final List<UnsplashPhotoModel> results;

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'total_pages': totalPages,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
