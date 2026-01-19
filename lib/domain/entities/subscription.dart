import 'package:flutter/foundation.dart';

/// Subscription entity
@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.expirationDate,
    this.productId,
    this.platform,
    this.willRenew = true,
  });

  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? expirationDate;
  final String? productId;
  final String? platform; // "ios" or "android"
  final bool willRenew;

  /// Check if subscription is active
  bool get isActive {
    if (status != SubscriptionStatus.active) return false;
    if (expirationDate == null) return true;
    return DateTime.now().isBefore(expirationDate!);
  }

  /// Check if subscription is premium (any paid tier)
  bool get isPremium => tier != SubscriptionTier.free && isActive;

  /// Get days until expiration
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? expirationDate,
    String? productId,
    String? platform,
    bool? willRenew,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      productId: productId ?? this.productId,
      platform: platform ?? this.platform,
      willRenew: willRenew ?? this.willRenew,
    );
  }
}

/// Subscription tiers
enum SubscriptionTier {
  free,
  basic,
  pro,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
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
      case SubscriptionTier.basic:
        return 'أساسي';
      case SubscriptionTier.pro:
        return 'برو';
      case SubscriptionTier.premium:
        return 'بريميوم';
    }
  }

  /// Get features for this tier
  List<SubscriptionFeature> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          SubscriptionFeature.limitedQuizzes,
          SubscriptionFeature.limitedAiChat,
          SubscriptionFeature.adsEnabled,
        ];
      case SubscriptionTier.basic:
        return [
          SubscriptionFeature.unlimitedQuizzes,
          SubscriptionFeature.limitedAiChat,
          SubscriptionFeature.noAds,
        ];
      case SubscriptionTier.pro:
        return [
          SubscriptionFeature.unlimitedQuizzes,
          SubscriptionFeature.unlimitedAiChat,
          SubscriptionFeature.noAds,
          SubscriptionFeature.offlineAccess,
        ];
      case SubscriptionTier.premium:
        return [
          SubscriptionFeature.unlimitedQuizzes,
          SubscriptionFeature.unlimitedAiChat,
          SubscriptionFeature.noAds,
          SubscriptionFeature.offlineAccess,
          SubscriptionFeature.streakFreeze,
          SubscriptionFeature.exclusiveAchievements,
          SubscriptionFeature.prioritySupport,
        ];
    }
  }
}

/// Subscription status
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  paused,
  trial;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.trial:
        return 'Trial';
    }
  }
}

/// Subscription features
enum SubscriptionFeature {
  limitedQuizzes,
  unlimitedQuizzes,
  limitedAiChat,
  unlimitedAiChat,
  adsEnabled,
  noAds,
  offlineMode,
  offlineAccess, // Alias for offlineMode for backwards compatibility
  streakFreeze,
  exclusiveAchievements,
  prioritySupport,
  advancedStats,
  customThemes,
  terrain3D,
  advancedLearning;

  String get displayName {
    switch (this) {
      case SubscriptionFeature.limitedQuizzes:
        return '5 Quizzes/Day';
      case SubscriptionFeature.unlimitedQuizzes:
        return 'Unlimited Quizzes';
      case SubscriptionFeature.limitedAiChat:
        return '10 AI Messages/Day';
      case SubscriptionFeature.unlimitedAiChat:
        return 'Unlimited AI Chat';
      case SubscriptionFeature.adsEnabled:
        return 'Contains Ads';
      case SubscriptionFeature.noAds:
        return 'No Ads';
      case SubscriptionFeature.offlineMode:
      case SubscriptionFeature.offlineAccess:
        return 'Offline Access';
      case SubscriptionFeature.streakFreeze:
        return 'Streak Freeze';
      case SubscriptionFeature.exclusiveAchievements:
        return 'Exclusive Achievements';
      case SubscriptionFeature.prioritySupport:
        return 'Priority Support';
      case SubscriptionFeature.advancedStats:
        return 'Advanced Statistics';
      case SubscriptionFeature.customThemes:
        return 'Custom Themes';
      case SubscriptionFeature.terrain3D:
        return '3D Terrain View';
      case SubscriptionFeature.advancedLearning:
        return 'Advanced Learning';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case SubscriptionFeature.limitedQuizzes:
        return '5 اختبارات/يوم';
      case SubscriptionFeature.unlimitedQuizzes:
        return 'اختبارات غير محدودة';
      case SubscriptionFeature.limitedAiChat:
        return '10 رسائل/يوم';
      case SubscriptionFeature.unlimitedAiChat:
        return 'محادثات غير محدودة';
      case SubscriptionFeature.adsEnabled:
        return 'يحتوي على إعلانات';
      case SubscriptionFeature.noAds:
        return 'بدون إعلانات';
      case SubscriptionFeature.offlineMode:
      case SubscriptionFeature.offlineAccess:
        return 'وصول بدون إنترنت';
      case SubscriptionFeature.streakFreeze:
        return 'تجميد السلسلة';
      case SubscriptionFeature.exclusiveAchievements:
        return 'إنجازات حصرية';
      case SubscriptionFeature.prioritySupport:
        return 'دعم أولوي';
      case SubscriptionFeature.advancedStats:
        return 'إحصائيات متقدمة';
      case SubscriptionFeature.customThemes:
        return 'سمات مخصصة';
      case SubscriptionFeature.terrain3D:
        return 'تضاريس ثلاثية الأبعاد';
      case SubscriptionFeature.advancedLearning:
        return 'تعلم متقدم';
    }
  }

  bool get isPositive {
    switch (this) {
      case SubscriptionFeature.limitedQuizzes:
      case SubscriptionFeature.limitedAiChat:
      case SubscriptionFeature.adsEnabled:
        return false;
      default:
        return true;
    }
  }
}

/// Subscription offering (from RevenueCat)
@immutable
class SubscriptionOffering {
  const SubscriptionOffering({
    required this.id,
    required this.productId,
    required this.tier,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    required this.period,
    this.hasFreeTrial = false,
    this.freeTrialDays,
  });

  final String id;
  final String productId;
  final SubscriptionTier tier;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  final SubscriptionPeriod period;
  final bool hasFreeTrial;
  final int? freeTrialDays;

  /// Get monthly equivalent price
  double get monthlyPrice {
    switch (period) {
      case SubscriptionPeriod.weekly:
        return price * 4;
      case SubscriptionPeriod.monthly:
        return price;
      case SubscriptionPeriod.yearly:
        return price / 12;
    }
  }
}

/// Subscription period
enum SubscriptionPeriod {
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case SubscriptionPeriod.weekly:
        return 'Weekly';
      case SubscriptionPeriod.monthly:
        return 'Monthly';
      case SubscriptionPeriod.yearly:
        return 'Yearly';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case SubscriptionPeriod.weekly:
        return 'أسبوعي';
      case SubscriptionPeriod.monthly:
        return 'شهري';
      case SubscriptionPeriod.yearly:
        return 'سنوي';
    }
  }
}
