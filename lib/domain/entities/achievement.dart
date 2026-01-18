import 'package:flutter/foundation.dart';

/// Achievement entity
@immutable
class Achievement {
  const Achievement({
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

  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  String getDisplayDescription({required bool isArabic}) {
    return isArabic ? descriptionArabic : description;
  }
}

/// Unlocked achievement with timestamp
@immutable
class UnlockedAchievement {
  const UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.currentValue,
  });

  final String achievementId;
  final DateTime unlockedAt;
  final int currentValue;
}

/// Achievement category
enum AchievementCategory {
  learning,
  quiz,
  streak,
  exploration,
  social,
  special;

  String get displayName {
    switch (this) {
      case AchievementCategory.learning:
        return 'Learning';
      case AchievementCategory.quiz:
        return 'Quiz Master';
      case AchievementCategory.streak:
        return 'Consistency';
      case AchievementCategory.exploration:
        return 'Explorer';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case AchievementCategory.learning:
        return 'التعلم';
      case AchievementCategory.quiz:
        return 'أستاذ الاختبارات';
      case AchievementCategory.streak:
        return 'الاستمرارية';
      case AchievementCategory.exploration:
        return 'المستكشف';
      case AchievementCategory.social:
        return 'اجتماعي';
      case AchievementCategory.special:
        return 'خاص';
    }
  }
}

/// Achievement tier
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get displayName {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
      case AchievementTier.diamond:
        return 'Diamond';
    }
  }

  int get xpMultiplier {
    switch (this) {
      case AchievementTier.bronze:
        return 1;
      case AchievementTier.silver:
        return 2;
      case AchievementTier.gold:
        return 3;
      case AchievementTier.platinum:
        return 5;
      case AchievementTier.diamond:
        return 10;
    }
  }
}

/// Predefined achievements
class Achievements {
  static const List<Achievement> all = [
    // Learning achievements
    Achievement(
      id: 'first_country',
      name: 'First Discovery',
      nameArabic: 'الاكتشاف الأول',
      description: 'Learn about your first country',
      descriptionArabic: 'تعلم عن أول دولة',
      iconPath: 'assets/images/icons/achievement_first.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requiredValue: 1,
      xpReward: 50,
    ),
    Achievement(
      id: 'countries_10',
      name: 'Curious Traveler',
      nameArabic: 'المسافر الفضولي',
      description: 'Learn about 10 countries',
      descriptionArabic: 'تعلم عن 10 دول',
      iconPath: 'assets/images/icons/achievement_countries_10.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requiredValue: 10,
      xpReward: 100,
    ),
    Achievement(
      id: 'countries_50',
      name: 'World Explorer',
      nameArabic: 'مستكشف العالم',
      description: 'Learn about 50 countries',
      descriptionArabic: 'تعلم عن 50 دولة',
      iconPath: 'assets/images/icons/achievement_countries_50.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
      requiredValue: 50,
      xpReward: 250,
    ),
    Achievement(
      id: 'countries_100',
      name: 'Geography Expert',
      nameArabic: 'خبير الجغرافيا',
      description: 'Learn about 100 countries',
      descriptionArabic: 'تعلم عن 100 دولة',
      iconPath: 'assets/images/icons/achievement_countries_100.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      requiredValue: 100,
      xpReward: 500,
    ),
    Achievement(
      id: 'countries_all',
      name: 'World Master',
      nameArabic: 'سيد العالم',
      description: 'Learn about all 195 countries',
      descriptionArabic: 'تعلم عن جميع الدول الـ 195',
      iconPath: 'assets/images/icons/achievement_countries_all.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.diamond,
      requiredValue: 195,
      xpReward: 1000,
    ),

    // Quiz achievements
    Achievement(
      id: 'first_quiz',
      name: 'Quiz Beginner',
      nameArabic: 'مبتدئ الاختبارات',
      description: 'Complete your first quiz',
      descriptionArabic: 'أكمل أول اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_first.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.bronze,
      requiredValue: 1,
      xpReward: 50,
    ),
    Achievement(
      id: 'perfect_quiz',
      name: 'Perfect Score',
      nameArabic: 'النتيجة المثالية',
      description: 'Get 100% on a quiz',
      descriptionArabic: 'احصل على 100% في اختبار',
      iconPath: 'assets/images/icons/achievement_perfect.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.silver,
      requiredValue: 1,
      xpReward: 200,
    ),
    Achievement(
      id: 'quizzes_50',
      name: 'Quiz Enthusiast',
      nameArabic: 'متحمس الاختبارات',
      description: 'Complete 50 quizzes',
      descriptionArabic: 'أكمل 50 اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_50.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      requiredValue: 50,
      xpReward: 500,
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      name: 'Getting Started',
      nameArabic: 'البداية',
      description: 'Maintain a 3-day streak',
      descriptionArabic: 'حافظ على سلسلة 3 أيام',
      iconPath: 'assets/images/icons/achievement_streak_3.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      requiredValue: 3,
      xpReward: 75,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Weekly Warrior',
      nameArabic: 'محارب الأسبوع',
      description: 'Maintain a 7-day streak',
      descriptionArabic: 'حافظ على سلسلة 7 أيام',
      iconPath: 'assets/images/icons/achievement_streak_7.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      requiredValue: 7,
      xpReward: 150,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      nameArabic: 'أستاذ الشهر',
      description: 'Maintain a 30-day streak',
      descriptionArabic: 'حافظ على سلسلة 30 يوم',
      iconPath: 'assets/images/icons/achievement_streak_30.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      requiredValue: 30,
      xpReward: 500,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Unstoppable',
      nameArabic: 'لا يمكن إيقافه',
      description: 'Maintain a 100-day streak',
      descriptionArabic: 'حافظ على سلسلة 100 يوم',
      iconPath: 'assets/images/icons/achievement_streak_100.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      requiredValue: 100,
      xpReward: 1000,
    ),

    // Exploration achievements
    Achievement(
      id: 'africa_complete',
      name: 'African Explorer',
      nameArabic: 'مستكشف أفريقيا',
      description: 'Learn about all African countries',
      descriptionArabic: 'تعلم عن جميع الدول الأفريقية',
      iconPath: 'assets/images/icons/achievement_africa.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      requiredValue: 54,
      xpReward: 400,
    ),
    Achievement(
      id: 'europe_complete',
      name: 'European Explorer',
      nameArabic: 'مستكشف أوروبا',
      description: 'Learn about all European countries',
      descriptionArabic: 'تعلم عن جميع الدول الأوروبية',
      iconPath: 'assets/images/icons/achievement_europe.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      requiredValue: 44,
      xpReward: 400,
    ),
    Achievement(
      id: 'asia_complete',
      name: 'Asian Explorer',
      nameArabic: 'مستكشف آسيا',
      description: 'Learn about all Asian countries',
      descriptionArabic: 'تعلم عن جميع الدول الآسيوية',
      iconPath: 'assets/images/icons/achievement_asia.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      requiredValue: 48,
      xpReward: 400,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
