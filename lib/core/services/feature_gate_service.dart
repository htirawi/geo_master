import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription.dart';

/// Features that can be gated by subscription tier
enum Feature {
  /// Unlimited quizzes per day
  unlimitedQuizzes,

  /// Access to advanced stats dashboard
  advancedStats,

  /// Challenge friends to duels
  friendsDuels,

  /// Create custom challenges
  customChallenges,

  /// Export stats to PDF
  exportStats,

  /// No advertisements
  noAds,

  /// Priority customer support
  prioritySupport,

  /// Exclusive achievements
  exclusiveAchievements,

  /// Access to tournaments
  tournamentAccess,

  /// Access to weekly goals
  weeklyGoals,

  /// Access to friends leaderboard
  friendsLeaderboard,

  /// Custom profile themes
  customThemes,

  /// Offline mode
  offlineMode,

  /// Early access to new features
  earlyAccess,
}

/// Limits that can be controlled by subscription tier
enum FeatureLimit {
  /// Maximum quizzes per day
  dailyQuizzes,

  /// Maximum friends count
  friendsCount,

  /// Days of stats history available
  statsHistoryDays,

  /// Maximum duels per day
  dailyDuels,

  /// Maximum custom goals
  customGoals,
}

/// Service for checking feature access based on subscription tier
class FeatureGateService {
  FeatureGateService(this.tier);

  final SubscriptionTier tier;

  /// Feature access matrix by subscription tier
  static final Map<Feature, Set<SubscriptionTier>> _featureAccess = {
    Feature.unlimitedQuizzes: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.advancedStats: {
      SubscriptionTier.basic,
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.friendsDuels: {
      SubscriptionTier.basic,
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.customChallenges: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.exportStats: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.noAds: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.prioritySupport: {
      SubscriptionTier.premium,
    },
    Feature.exclusiveAchievements: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.tournamentAccess: {
      SubscriptionTier.basic,
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.weeklyGoals: {
      SubscriptionTier.free,
      SubscriptionTier.basic,
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.friendsLeaderboard: {
      SubscriptionTier.basic,
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.customThemes: {
      SubscriptionTier.pro,
      SubscriptionTier.premium,
    },
    Feature.offlineMode: {
      SubscriptionTier.premium,
    },
    Feature.earlyAccess: {
      SubscriptionTier.premium,
    },
  };

  /// Feature limits by subscription tier
  static final Map<FeatureLimit, Map<SubscriptionTier, int>> _featureLimits = {
    FeatureLimit.dailyQuizzes: {
      SubscriptionTier.free: 5,
      SubscriptionTier.basic: 20,
      SubscriptionTier.pro: -1, // Unlimited
      SubscriptionTier.premium: -1, // Unlimited
    },
    FeatureLimit.friendsCount: {
      SubscriptionTier.free: 10,
      SubscriptionTier.basic: 50,
      SubscriptionTier.pro: 200,
      SubscriptionTier.premium: -1, // Unlimited
    },
    FeatureLimit.statsHistoryDays: {
      SubscriptionTier.free: 7,
      SubscriptionTier.basic: 30,
      SubscriptionTier.pro: 365,
      SubscriptionTier.premium: -1, // Unlimited
    },
    FeatureLimit.dailyDuels: {
      SubscriptionTier.free: 3,
      SubscriptionTier.basic: 10,
      SubscriptionTier.pro: -1, // Unlimited
      SubscriptionTier.premium: -1, // Unlimited
    },
    FeatureLimit.customGoals: {
      SubscriptionTier.free: 0,
      SubscriptionTier.basic: 3,
      SubscriptionTier.pro: 10,
      SubscriptionTier.premium: -1, // Unlimited
    },
  };

  /// Check if user can access a specific feature
  bool canAccessFeature(Feature feature) {
    final allowedTiers = _featureAccess[feature];
    if (allowedTiers == null) return true; // Default: accessible
    return allowedTiers.contains(tier);
  }

  /// Get the limit for a specific feature
  /// Returns -1 for unlimited, 0 for no access
  int getLimit(FeatureLimit limit) {
    final limits = _featureLimits[limit];
    if (limits == null) return -1; // Default: unlimited
    return limits[tier] ?? 0;
  }

  /// Check if a limit is unlimited (-1)
  bool isUnlimited(FeatureLimit limit) {
    return getLimit(limit) == -1;
  }

  /// Check if user is within the limit
  bool isWithinLimit(FeatureLimit limit, int currentValue) {
    final maxLimit = getLimit(limit);
    if (maxLimit == -1) return true; // Unlimited
    return currentValue < maxLimit;
  }

  /// Get percentage of limit used
  double getLimitUsagePercentage(FeatureLimit limit, int currentValue) {
    final maxLimit = getLimit(limit);
    if (maxLimit == -1) return 0; // Unlimited, no percentage
    if (maxLimit == 0) return 1; // No access
    return (currentValue / maxLimit).clamp(0, 1);
  }

  /// Get remaining uses for a limit
  int getRemainingUses(FeatureLimit limit, int currentValue) {
    final maxLimit = getLimit(limit);
    if (maxLimit == -1) return -1; // Unlimited
    return (maxLimit - currentValue).clamp(0, maxLimit);
  }

  /// Get features available in a specific tier
  static Set<Feature> getFeaturesForTier(SubscriptionTier tier) {
    return _featureAccess.entries
        .where((entry) => entry.value.contains(tier))
        .map((entry) => entry.key)
        .toSet();
  }

  /// Get tier required for a feature
  static SubscriptionTier? getMinimumTierForFeature(Feature feature) {
    final allowedTiers = _featureAccess[feature];
    if (allowedTiers == null) return null;

    // Return the lowest tier that has access
    for (final tier in SubscriptionTier.values) {
      if (allowedTiers.contains(tier)) {
        return tier;
      }
    }
    return null;
  }

  /// Get upgrade suggestion for a feature
  SubscriptionTier? getUpgradeSuggestion(Feature feature) {
    if (canAccessFeature(feature)) return null;

    // Find the lowest tier that grants access
    for (final t in SubscriptionTier.values) {
      if (t.index > tier.index) {
        final allowedTiers = _featureAccess[feature];
        if (allowedTiers?.contains(t) ?? false) {
          return t;
        }
      }
    }
    return null;
  }
}

/// Provider for feature gate service
final featureGateServiceProvider =
    Provider.family<FeatureGateService, SubscriptionTier>((ref, tier) {
  return FeatureGateService(tier);
});

/// Provider for checking specific feature access
final canAccessFeatureProvider =
    Provider.family<bool, FeatureAccessKey>((ref, key) {
  final service = ref.watch(featureGateServiceProvider(key.tier));
  return service.canAccessFeature(key.feature);
});

/// Provider for getting feature limit
final featureLimitProvider =
    Provider.family<int, FeatureLimitKey>((ref, key) {
  final service = ref.watch(featureGateServiceProvider(key.tier));
  return service.getLimit(key.limit);
});

/// Key for feature access provider
class FeatureAccessKey {
  const FeatureAccessKey({
    required this.tier,
    required this.feature,
  });

  final SubscriptionTier tier;
  final Feature feature;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureAccessKey &&
        other.tier == tier &&
        other.feature == feature;
  }

  @override
  int get hashCode => tier.hashCode ^ feature.hashCode;
}

/// Key for feature limit provider
class FeatureLimitKey {
  const FeatureLimitKey({
    required this.tier,
    required this.limit,
  });

  final SubscriptionTier tier;
  final FeatureLimit limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureLimitKey &&
        other.tier == tier &&
        other.limit == limit;
  }

  @override
  int get hashCode => tier.hashCode ^ limit.hashCode;
}

/// Extension for subscription tier display
extension SubscriptionTierExtension on SubscriptionTier {
  String getNameEn() {
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

  String getNameAr() {
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

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();

  String getDescriptionEn() {
    switch (this) {
      case SubscriptionTier.free:
        return 'Get started with basic features';
      case SubscriptionTier.basic:
        return 'More quizzes and social features';
      case SubscriptionTier.pro:
        return 'Unlimited access and advanced stats';
      case SubscriptionTier.premium:
        return 'Everything plus exclusive benefits';
    }
  }

  String getDescriptionAr() {
    switch (this) {
      case SubscriptionTier.free:
        return 'ابدأ بالميزات الأساسية';
      case SubscriptionTier.basic:
        return 'المزيد من الاختبارات والميزات الاجتماعية';
      case SubscriptionTier.pro:
        return 'وصول غير محدود وإحصائيات متقدمة';
      case SubscriptionTier.premium:
        return 'كل شيء بالإضافة إلى مزايا حصرية';
    }
  }

  String getDescription(bool isArabic) =>
      isArabic ? getDescriptionAr() : getDescriptionEn();

  /// Price per month (for display purposes)
  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.basic:
        return 2.99;
      case SubscriptionTier.pro:
        return 6.99;
      case SubscriptionTier.premium:
        return 12.99;
    }
  }
}

/// Extension for feature display
extension FeatureExtension on Feature {
  String getNameEn() {
    switch (this) {
      case Feature.unlimitedQuizzes:
        return 'Unlimited Quizzes';
      case Feature.advancedStats:
        return 'Advanced Stats';
      case Feature.friendsDuels:
        return 'Friend Duels';
      case Feature.customChallenges:
        return 'Custom Challenges';
      case Feature.exportStats:
        return 'Export Stats';
      case Feature.noAds:
        return 'No Ads';
      case Feature.prioritySupport:
        return 'Priority Support';
      case Feature.exclusiveAchievements:
        return 'Exclusive Achievements';
      case Feature.tournamentAccess:
        return 'Tournament Access';
      case Feature.weeklyGoals:
        return 'Weekly Goals';
      case Feature.friendsLeaderboard:
        return 'Friends Leaderboard';
      case Feature.customThemes:
        return 'Custom Themes';
      case Feature.offlineMode:
        return 'Offline Mode';
      case Feature.earlyAccess:
        return 'Early Access';
    }
  }

  String getNameAr() {
    switch (this) {
      case Feature.unlimitedQuizzes:
        return 'اختبارات غير محدودة';
      case Feature.advancedStats:
        return 'إحصائيات متقدمة';
      case Feature.friendsDuels:
        return 'مبارزات الأصدقاء';
      case Feature.customChallenges:
        return 'تحديات مخصصة';
      case Feature.exportStats:
        return 'تصدير الإحصائيات';
      case Feature.noAds:
        return 'بدون إعلانات';
      case Feature.prioritySupport:
        return 'دعم أولوية';
      case Feature.exclusiveAchievements:
        return 'إنجازات حصرية';
      case Feature.tournamentAccess:
        return 'الوصول للبطولات';
      case Feature.weeklyGoals:
        return 'الأهداف الأسبوعية';
      case Feature.friendsLeaderboard:
        return 'لوحة متصدري الأصدقاء';
      case Feature.customThemes:
        return 'سمات مخصصة';
      case Feature.offlineMode:
        return 'وضع عدم الاتصال';
      case Feature.earlyAccess:
        return 'وصول مبكر';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();
}
