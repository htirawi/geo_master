import '../../domain/entities/achievement.dart';

/// Achievement data model for Firestore/local storage
class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.iconPath,
    required this.category,
    required this.tier,
    required this.requiredValue,
    required this.xpReward,
    this.isPremiumOnly = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionArabic: json['descriptionArabic'] as String? ?? '',
      iconPath: json['iconPath'] as String? ?? '',
      category: AchievementCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AchievementCategory.learning,
      ),
      tier: AchievementTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => AchievementTier.bronze,
      ),
      requiredValue: json['requiredValue'] as int? ?? 0,
      xpReward: json['xpReward'] as int? ?? 0,
      isPremiumOnly: json['isPremiumOnly'] as bool? ?? false,
    );
  }

  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      name: entity.name,
      nameArabic: entity.nameArabic,
      description: entity.description,
      descriptionArabic: entity.descriptionArabic,
      iconPath: entity.iconPath,
      category: entity.category,
      tier: entity.tier,
      requiredValue: entity.requiredValue,
      xpReward: entity.xpReward,
      isPremiumOnly: entity.isPremiumOnly,
    );
  }

  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final String iconPath;
  final AchievementCategory category;
  final AchievementTier tier;
  final int requiredValue;
  final int xpReward;
  final bool isPremiumOnly;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'iconPath': iconPath,
      'category': category.name,
      'tier': tier.name,
      'requiredValue': requiredValue,
      'xpReward': xpReward,
      'isPremiumOnly': isPremiumOnly,
    };
  }

  Achievement toEntity() {
    return Achievement(
      id: id,
      name: name,
      nameArabic: nameArabic,
      description: description,
      descriptionArabic: descriptionArabic,
      iconPath: iconPath,
      category: category,
      tier: tier,
      requiredValue: requiredValue,
      xpReward: xpReward,
      isPremiumOnly: isPremiumOnly,
    );
  }
}

/// Unlocked achievement data model
class UnlockedAchievementModel {
  const UnlockedAchievementModel({
    required this.achievementId,
    required this.unlockedAt,
    required this.currentValue,
  });

  factory UnlockedAchievementModel.fromJson(Map<String, dynamic> json) {
    return UnlockedAchievementModel(
      achievementId: json['achievementId'] as String? ?? '',
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : DateTime.now(),
      currentValue: json['currentValue'] as int? ?? 0,
    );
  }

  factory UnlockedAchievementModel.fromEntity(UnlockedAchievement entity) {
    return UnlockedAchievementModel(
      achievementId: entity.achievementId,
      unlockedAt: entity.unlockedAt,
      currentValue: entity.currentValue,
    );
  }

  final String achievementId;
  final DateTime unlockedAt;
  final int currentValue;

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'currentValue': currentValue,
    };
  }

  UnlockedAchievement toEntity() {
    return UnlockedAchievement(
      achievementId: achievementId,
      unlockedAt: unlockedAt,
      currentValue: currentValue,
    );
  }
}

/// User achievements progress model for tracking progress towards achievements
class AchievementProgressModel {
  const AchievementProgressModel({
    required this.achievementId,
    required this.currentValue,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory AchievementProgressModel.fromJson(Map<String, dynamic> json) {
    return AchievementProgressModel(
      achievementId: json['achievementId'] as String? ?? '',
      currentValue: json['currentValue'] as int? ?? 0,
      requiredValue: json['requiredValue'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  final String achievementId;
  final int currentValue;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    if (requiredValue == 0) return 0.0;
    return (currentValue / requiredValue).clamp(0.0, 1.0);
  }

  /// Get progress percentage as int (0 to 100)
  int get progressPercent => (progress * 100).round();

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentValue': currentValue,
      'requiredValue': requiredValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}
