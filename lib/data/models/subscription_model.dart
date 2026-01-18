/// Subscription tier enum
enum SubscriptionTier {
  free,
  pro,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case SubscriptionTier.free:
        return 'مجاني';
      case SubscriptionTier.pro:
        return 'برو';
      case SubscriptionTier.premium:
        return 'بريميوم';
    }
  }
}

/// Subscription period enum
enum SubscriptionPeriod {
  monthly,
  yearly,
  lifetime;

  String get displayName {
    switch (this) {
      case SubscriptionPeriod.monthly:
        return 'Monthly';
      case SubscriptionPeriod.yearly:
        return 'Yearly';
      case SubscriptionPeriod.lifetime:
        return 'Lifetime';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case SubscriptionPeriod.monthly:
        return 'شهري';
      case SubscriptionPeriod.yearly:
        return 'سنوي';
      case SubscriptionPeriod.lifetime:
        return 'مدى الحياة';
    }
  }
}

/// Subscription data model for RevenueCat integration
class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.isTrial = false,
    this.willRenew = true,
    this.productId,
    this.originalTransactionId,
    this.purchaseDate,
    this.store,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      period: SubscriptionPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => SubscriptionPeriod.monthly,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      isTrial: json['isTrial'] as bool? ?? false,
      willRenew: json['willRenew'] as bool? ?? true,
      productId: json['productId'] as String?,
      originalTransactionId: json['originalTransactionId'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      store: json['store'] as String?,
    );
  }

  /// Create a free tier subscription
  factory SubscriptionModel.free(String userId) {
    return SubscriptionModel(
      id: 'free_$userId',
      userId: userId,
      tier: SubscriptionTier.free,
      period: SubscriptionPeriod.monthly,
      startDate: DateTime.now(),
      isActive: true,
      isTrial: false,
      willRenew: false,
    );
  }

  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isTrial;
  final bool willRenew;
  final String? productId;
  final String? originalTransactionId;
  final DateTime? purchaseDate;
  final String? store; // 'app_store' or 'play_store'

  /// Check if subscription is expired
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Get days remaining
  int? get daysRemaining {
    if (endDate == null) return null;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if user has premium access
  bool get hasPremiumAccess => isActive && tier != SubscriptionTier.free;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.name,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'isTrial': isTrial,
      'willRenew': willRenew,
      'productId': productId,
      'originalTransactionId': originalTransactionId,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'store': store,
    };
  }
}

/// Product offering model for displaying subscription options
class ProductOfferingModel {
  const ProductOfferingModel({
    required this.productId,
    required this.tier,
    required this.period,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    this.discountPercent,
    this.originalPrice,
    this.originalPriceString,
    this.trialDays,
  });

  factory ProductOfferingModel.fromJson(Map<String, dynamic> json) {
    return ProductOfferingModel(
      productId: json['productId'] as String? ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.pro,
      ),
      period: SubscriptionPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => SubscriptionPeriod.monthly,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceString: json['priceString'] as String? ?? '',
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      discountPercent: json['discountPercent'] as int?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      originalPriceString: json['originalPriceString'] as String?,
      trialDays: json['trialDays'] as int?,
    );
  }

  final String productId;
  final SubscriptionTier tier;
  final SubscriptionPeriod period;
  final double price;
  final String priceString;
  final String currencyCode;
  final int? discountPercent;
  final double? originalPrice;
  final String? originalPriceString;
  final int? trialDays;

  /// Check if product has a discount
  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  /// Check if product has a free trial
  bool get hasTrial => trialDays != null && trialDays! > 0;

  /// Get monthly equivalent price for yearly subscriptions
  double? get monthlyEquivalent {
    if (period != SubscriptionPeriod.yearly) return null;
    return price / 12;
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'tier': tier.name,
      'period': period.name,
      'price': price,
      'priceString': priceString,
      'currencyCode': currencyCode,
      'discountPercent': discountPercent,
      'originalPrice': originalPrice,
      'originalPriceString': originalPriceString,
      'trialDays': trialDays,
    };
  }
}

/// Feature gate model for premium features
class FeatureGateModel {
  const FeatureGateModel({
    required this.featureId,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.requiredTier,
    this.usageLimit,
    this.currentUsage = 0,
  });

  factory FeatureGateModel.fromJson(Map<String, dynamic> json) {
    return FeatureGateModel(
      featureId: json['featureId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionArabic: json['descriptionArabic'] as String? ?? '',
      requiredTier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['requiredTier'],
        orElse: () => SubscriptionTier.free,
      ),
      usageLimit: json['usageLimit'] as int?,
      currentUsage: json['currentUsage'] as int? ?? 0,
    );
  }

  final String featureId;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final SubscriptionTier requiredTier;
  final int? usageLimit; // null = unlimited
  final int currentUsage;

  /// Check if feature is available for a given tier
  bool isAvailableFor(SubscriptionTier userTier) {
    return userTier.index >= requiredTier.index;
  }

  /// Check if usage limit is reached
  bool get isLimitReached {
    if (usageLimit == null) return false;
    return currentUsage >= usageLimit!;
  }

  /// Get remaining usage
  int? get remainingUsage {
    if (usageLimit == null) return null;
    final remaining = usageLimit! - currentUsage;
    return remaining < 0 ? 0 : remaining;
  }

  Map<String, dynamic> toJson() {
    return {
      'featureId': featureId,
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'requiredTier': requiredTier.name,
      'usageLimit': usageLimit,
      'currentUsage': currentUsage,
    };
  }
}

/// Predefined feature gates
class FeatureGates {
  static const aiTutorDaily = FeatureGateModel(
    featureId: 'ai_tutor_daily',
    name: 'AI Tutor (Daily)',
    nameArabic: 'المعلم الذكي (يومي)',
    description: 'Daily AI tutor chat messages',
    descriptionArabic: 'رسائل المعلم الذكي اليومية',
    requiredTier: SubscriptionTier.free,
    usageLimit: 5,
  );

  static const aiTutorUnlimited = FeatureGateModel(
    featureId: 'ai_tutor_unlimited',
    name: 'Unlimited AI Tutor',
    nameArabic: 'معلم ذكي غير محدود',
    description: 'Unlimited AI tutor conversations',
    descriptionArabic: 'محادثات غير محدودة مع المعلم الذكي',
    requiredTier: SubscriptionTier.pro,
  );

  static const offlineMode = FeatureGateModel(
    featureId: 'offline_mode',
    name: 'Offline Mode',
    nameArabic: 'وضع عدم الاتصال',
    description: 'Access content offline',
    descriptionArabic: 'الوصول للمحتوى بدون اتصال',
    requiredTier: SubscriptionTier.pro,
  );

  static const noAds = FeatureGateModel(
    featureId: 'no_ads',
    name: 'Ad-Free Experience',
    nameArabic: 'تجربة بدون إعلانات',
    description: 'Remove all advertisements',
    descriptionArabic: 'إزالة جميع الإعلانات',
    requiredTier: SubscriptionTier.pro,
  );

  static const advancedStats = FeatureGateModel(
    featureId: 'advanced_stats',
    name: 'Advanced Statistics',
    nameArabic: 'إحصائيات متقدمة',
    description: 'Detailed learning analytics',
    descriptionArabic: 'تحليلات تعلم مفصلة',
    requiredTier: SubscriptionTier.premium,
  );

  static const customQuizzes = FeatureGateModel(
    featureId: 'custom_quizzes',
    name: 'Custom Quizzes',
    nameArabic: 'اختبارات مخصصة',
    description: 'Create personalized quizzes',
    descriptionArabic: 'إنشاء اختبارات شخصية',
    requiredTier: SubscriptionTier.premium,
  );

  static const List<FeatureGateModel> all = [
    aiTutorDaily,
    aiTutorUnlimited,
    offlineMode,
    noAds,
    advancedStats,
    customQuizzes,
  ];
}
