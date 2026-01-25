import 'package:flutter/foundation.dart';

/// Achievement rarity levels
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case AchievementRarity.common:
        return 'عادي';
      case AchievementRarity.rare:
        return 'نادر';
      case AchievementRarity.epic:
        return 'ملحمي';
      case AchievementRarity.legendary:
        return 'أسطوري';
    }
  }

  /// XP multiplier for rarity
  double get xpMultiplier {
    switch (this) {
      case AchievementRarity.common:
        return 1.0;
      case AchievementRarity.rare:
        return 1.5;
      case AchievementRarity.epic:
        return 2.0;
      case AchievementRarity.legendary:
        return 3.0;
    }
  }
}

/// Achievement category
enum AchievementCategory {
  learning,
  quiz,
  streak,
  exploration,
  social,
  challenge,
  special,
  hidden;

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
      case AchievementCategory.challenge:
        return 'Challenger';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.hidden:
        return 'Secret';
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
      case AchievementCategory.challenge:
        return 'المتحدي';
      case AchievementCategory.special:
        return 'خاص';
      case AchievementCategory.hidden:
        return 'سري';
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

  String get displayNameArabic {
    switch (this) {
      case AchievementTier.bronze:
        return 'برونزي';
      case AchievementTier.silver:
        return 'فضي';
      case AchievementTier.gold:
        return 'ذهبي';
      case AchievementTier.platinum:
        return 'بلاتيني';
      case AchievementTier.diamond:
        return 'ماسي';
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

/// Progress tracking for progressive achievements
@immutable
class AchievementProgress {
  const AchievementProgress({
    required this.current,
    required this.target,
    this.milestones = const [],
  });

  final int current;
  final int target;
  final List<int> milestones; // Intermediate reward thresholds

  double get percentage => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => current >= target;

  /// Get the next milestone (or target if no more milestones)
  int get nextMilestone {
    for (final milestone in milestones) {
      if (current < milestone) return milestone;
    }
    return target;
  }

  /// Check if a milestone was just reached
  bool reachedMilestone(int previousValue) {
    for (final milestone in milestones) {
      if (previousValue < milestone && current >= milestone) {
        return true;
      }
    }
    return false;
  }
}

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
    this.rarity = AchievementRarity.common,
    this.isPremiumOnly = false,
    this.isHidden = false,
    this.prerequisites = const [],
    this.milestones = const [],
    this.groupId,
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
  final AchievementRarity rarity;
  final bool isPremiumOnly;
  final bool isHidden;
  final List<String> prerequisites; // Achievement IDs required first
  final List<int> milestones; // Intermediate progress points
  final String? groupId; // For grouping related achievements

  String getDisplayName({required bool isArabic}) {
    return isArabic ? nameArabic : name;
  }

  String getDisplayDescription({required bool isArabic}) {
    if (isHidden) {
      return isArabic ? '؟؟؟ إنجاز سري' : '??? Secret achievement';
    }
    return isArabic ? descriptionArabic : description;
  }

  /// Calculate total XP including tier and rarity multipliers
  int get totalXpReward =>
      (xpReward * tier.xpMultiplier * rarity.xpMultiplier).round();
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

/// Predefined achievements (80+)
class Achievements {
  static const List<Achievement> all = [
    // ============================================================================
    // LEARNING ACHIEVEMENTS (15)
    // ============================================================================
    Achievement(
      id: 'first_country',
      name: 'First Discovery',
      nameArabic: 'الاكتشاف الأول',
      description: 'Learn about your first country',
      descriptionArabic: 'تعلم عن أول دولة',
      iconPath: 'assets/images/icons/achievement_first.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 50,
      groupId: 'countries_learned',
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
      rarity: AchievementRarity.common,
      requiredValue: 10,
      xpReward: 100,
      groupId: 'countries_learned',
      milestones: [5],
    ),
    Achievement(
      id: 'countries_25',
      name: 'Geography Enthusiast',
      nameArabic: 'متحمس الجغرافيا',
      description: 'Learn about 25 countries',
      descriptionArabic: 'تعلم عن 25 دولة',
      iconPath: 'assets/images/icons/achievement_countries_25.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.common,
      requiredValue: 25,
      xpReward: 150,
      groupId: 'countries_learned',
      prerequisites: ['countries_10'],
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
      rarity: AchievementRarity.rare,
      requiredValue: 50,
      xpReward: 250,
      groupId: 'countries_learned',
      prerequisites: ['countries_25'],
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
      rarity: AchievementRarity.rare,
      requiredValue: 100,
      xpReward: 500,
      groupId: 'countries_learned',
      prerequisites: ['countries_50'],
    ),
    Achievement(
      id: 'countries_150',
      name: 'Global Scholar',
      nameArabic: 'عالم عالمي',
      description: 'Learn about 150 countries',
      descriptionArabic: 'تعلم عن 150 دولة',
      iconPath: 'assets/images/icons/achievement_countries_150.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 150,
      xpReward: 750,
      groupId: 'countries_learned',
      prerequisites: ['countries_100'],
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
      rarity: AchievementRarity.legendary,
      requiredValue: 195,
      xpReward: 1000,
      groupId: 'countries_learned',
      prerequisites: ['countries_150'],
    ),
    // Capital achievements
    Achievement(
      id: 'capitals_10',
      name: 'Capital Beginner',
      nameArabic: 'مبتدئ العواصم',
      description: 'Learn 10 capitals',
      descriptionArabic: 'تعلم 10 عواصم',
      iconPath: 'assets/images/icons/achievement_capitals.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 10,
      xpReward: 100,
      groupId: 'capitals_learned',
    ),
    Achievement(
      id: 'capitals_50',
      name: 'Capital Expert',
      nameArabic: 'خبير العواصم',
      description: 'Learn 50 capitals',
      descriptionArabic: 'تعلم 50 عاصمة',
      iconPath: 'assets/images/icons/achievement_capitals_50.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 50,
      xpReward: 300,
      groupId: 'capitals_learned',
      prerequisites: ['capitals_10'],
    ),
    Achievement(
      id: 'capitals_100',
      name: 'Capital Master',
      nameArabic: 'أستاذ العواصم',
      description: 'Learn 100 capitals',
      descriptionArabic: 'تعلم 100 عاصمة',
      iconPath: 'assets/images/icons/achievement_capitals_100.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 100,
      xpReward: 500,
      groupId: 'capitals_learned',
      prerequisites: ['capitals_50'],
    ),
    // Flag achievements
    Achievement(
      id: 'flags_10',
      name: 'Flag Collector',
      nameArabic: 'جامع الأعلام',
      description: 'Learn 10 flags',
      descriptionArabic: 'تعلم 10 أعلام',
      iconPath: 'assets/images/icons/achievement_flags.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 10,
      xpReward: 100,
      groupId: 'flags_learned',
    ),
    Achievement(
      id: 'flags_50',
      name: 'Flag Expert',
      nameArabic: 'خبير الأعلام',
      description: 'Learn 50 flags',
      descriptionArabic: 'تعلم 50 علم',
      iconPath: 'assets/images/icons/achievement_flags_50.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 50,
      xpReward: 300,
      groupId: 'flags_learned',
      prerequisites: ['flags_10'],
    ),
    Achievement(
      id: 'flags_100',
      name: 'Vexillologist',
      nameArabic: 'عالم الأعلام',
      description: 'Learn 100 flags',
      descriptionArabic: 'تعلم 100 علم',
      iconPath: 'assets/images/icons/achievement_flags_100.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 100,
      xpReward: 500,
      groupId: 'flags_learned',
      prerequisites: ['flags_50'],
    ),
    Achievement(
      id: 'flags_all',
      name: 'Flag Master',
      nameArabic: 'سيد الأعلام',
      description: 'Learn all 195 flags',
      descriptionArabic: 'تعلم جميع الأعلام',
      iconPath: 'assets/images/icons/achievement_flags_all.png',
      category: AchievementCategory.learning,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 195,
      xpReward: 1000,
      groupId: 'flags_learned',
      prerequisites: ['flags_100'],
    ),

    // ============================================================================
    // QUIZ ACHIEVEMENTS (15)
    // ============================================================================
    Achievement(
      id: 'first_quiz',
      name: 'Quiz Beginner',
      nameArabic: 'مبتدئ الاختبارات',
      description: 'Complete your first quiz',
      descriptionArabic: 'أكمل أول اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_first.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 50,
      groupId: 'quizzes_completed',
    ),
    Achievement(
      id: 'quizzes_10',
      name: 'Quiz Regular',
      nameArabic: 'منتظم الاختبارات',
      description: 'Complete 10 quizzes',
      descriptionArabic: 'أكمل 10 اختبارات',
      iconPath: 'assets/images/icons/achievement_quiz_10.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 10,
      xpReward: 100,
      groupId: 'quizzes_completed',
    ),
    Achievement(
      id: 'quizzes_50',
      name: 'Quiz Enthusiast',
      nameArabic: 'متحمس الاختبارات',
      description: 'Complete 50 quizzes',
      descriptionArabic: 'أكمل 50 اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_50.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 50,
      xpReward: 300,
      groupId: 'quizzes_completed',
    ),
    Achievement(
      id: 'quizzes_100',
      name: 'Quiz Veteran',
      nameArabic: 'محترف الاختبارات',
      description: 'Complete 100 quizzes',
      descriptionArabic: 'أكمل 100 اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_100.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 100,
      xpReward: 500,
      groupId: 'quizzes_completed',
    ),
    Achievement(
      id: 'quizzes_500',
      name: 'Quiz Legend',
      nameArabic: 'أسطورة الاختبارات',
      description: 'Complete 500 quizzes',
      descriptionArabic: 'أكمل 500 اختبار',
      iconPath: 'assets/images/icons/achievement_quiz_500.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 500,
      xpReward: 1000,
      groupId: 'quizzes_completed',
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
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 200,
      groupId: 'perfect_scores',
    ),
    Achievement(
      id: 'perfect_3',
      name: 'Perfectionist',
      nameArabic: 'الكمال',
      description: 'Get 3 perfect scores',
      descriptionArabic: 'احصل على 3 نتائج مثالية',
      iconPath: 'assets/images/icons/achievement_perfect_3.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 3,
      xpReward: 300,
      groupId: 'perfect_scores',
      prerequisites: ['perfect_quiz'],
    ),
    Achievement(
      id: 'perfect_10',
      name: 'Flawless',
      nameArabic: 'بلا عيب',
      description: 'Get 10 perfect scores',
      descriptionArabic: 'احصل على 10 نتائج مثالية',
      iconPath: 'assets/images/icons/achievement_perfect_10.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 10,
      xpReward: 500,
      groupId: 'perfect_scores',
      prerequisites: ['perfect_3'],
    ),
    Achievement(
      id: 'perfect_streak_3',
      name: 'Hot Streak',
      nameArabic: 'سلسلة ساخنة',
      description: '3 perfect scores in a row',
      descriptionArabic: '3 نتائج مثالية متتالية',
      iconPath: 'assets/images/icons/achievement_streak_perfect.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.epic,
      requiredValue: 3,
      xpReward: 400,
    ),
    Achievement(
      id: 'perfect_streak_5',
      name: 'On Fire',
      nameArabic: 'متألق',
      description: '5 perfect scores in a row',
      descriptionArabic: '5 نتائج مثالية متتالية',
      iconPath: 'assets/images/icons/achievement_streak_perfect_5.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 5,
      xpReward: 600,
      prerequisites: ['perfect_streak_3'],
    ),
    Achievement(
      id: 'speed_demon_bronze',
      name: 'Quick Thinker',
      nameArabic: 'سريع التفكير',
      description: 'Answer 10 questions in under 3 seconds each',
      descriptionArabic: 'أجب على 10 أسئلة في أقل من 3 ثوان',
      iconPath: 'assets/images/icons/achievement_speed.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 10,
      xpReward: 150,
      groupId: 'speed_answers',
    ),
    Achievement(
      id: 'speed_demon_silver',
      name: 'Lightning Fast',
      nameArabic: 'بسرعة البرق',
      description: 'Answer 50 questions in under 3 seconds each',
      descriptionArabic: 'أجب على 50 سؤال في أقل من 3 ثوان',
      iconPath: 'assets/images/icons/achievement_speed_50.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 50,
      xpReward: 300,
      groupId: 'speed_answers',
      prerequisites: ['speed_demon_bronze'],
    ),
    Achievement(
      id: 'speed_demon_gold',
      name: 'Speed Demon',
      nameArabic: 'شيطان السرعة',
      description: 'Answer 100 questions in under 3 seconds each',
      descriptionArabic: 'أجب على 100 سؤال في أقل من 3 ثوان',
      iconPath: 'assets/images/icons/achievement_speed_100.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.epic,
      requiredValue: 100,
      xpReward: 500,
      groupId: 'speed_answers',
      prerequisites: ['speed_demon_silver'],
    ),
    Achievement(
      id: 'no_hints_master',
      name: 'No Help Needed',
      nameArabic: 'لا حاجة للمساعدة',
      description: 'Perfect score without using hints',
      descriptionArabic: 'نتيجة مثالية بدون استخدام تلميحات',
      iconPath: 'assets/images/icons/achievement_no_hints.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 300,
    ),
    Achievement(
      id: 'marathon_complete',
      name: 'Marathon Runner',
      nameArabic: 'عداء الماراثون',
      description: 'Complete a 50-question marathon',
      descriptionArabic: 'أكمل ماراثون من 50 سؤال',
      iconPath: 'assets/images/icons/achievement_marathon.png',
      category: AchievementCategory.quiz,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 400,
    ),

    // ============================================================================
    // STREAK ACHIEVEMENTS (10)
    // ============================================================================
    Achievement(
      id: 'streak_3',
      name: 'Getting Started',
      nameArabic: 'البداية',
      description: 'Maintain a 3-day streak',
      descriptionArabic: 'حافظ على سلسلة 3 أيام',
      iconPath: 'assets/images/icons/achievement_streak_3.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 3,
      xpReward: 75,
      groupId: 'streak_days',
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
      rarity: AchievementRarity.common,
      requiredValue: 7,
      xpReward: 150,
      groupId: 'streak_days',
      prerequisites: ['streak_3'],
    ),
    Achievement(
      id: 'streak_14',
      name: 'Two Week Champion',
      nameArabic: 'بطل الأسبوعين',
      description: 'Maintain a 14-day streak',
      descriptionArabic: 'حافظ على سلسلة 14 يوم',
      iconPath: 'assets/images/icons/achievement_streak_14.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 14,
      xpReward: 250,
      groupId: 'streak_days',
      prerequisites: ['streak_7'],
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
      rarity: AchievementRarity.rare,
      requiredValue: 30,
      xpReward: 500,
      groupId: 'streak_days',
      prerequisites: ['streak_14'],
    ),
    Achievement(
      id: 'streak_60',
      name: 'Two Month Hero',
      nameArabic: 'بطل الشهرين',
      description: 'Maintain a 60-day streak',
      descriptionArabic: 'حافظ على سلسلة 60 يوم',
      iconPath: 'assets/images/icons/achievement_streak_60.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.epic,
      requiredValue: 60,
      xpReward: 750,
      groupId: 'streak_days',
      prerequisites: ['streak_30'],
    ),
    Achievement(
      id: 'streak_100',
      name: 'Century Legend',
      nameArabic: 'أسطورة المئة',
      description: 'Maintain a 100-day streak',
      descriptionArabic: 'حافظ على سلسلة 100 يوم',
      iconPath: 'assets/images/icons/achievement_streak_100.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 100,
      xpReward: 1000,
      groupId: 'streak_days',
      prerequisites: ['streak_60'],
    ),
    Achievement(
      id: 'streak_180',
      name: 'Half Year Hero',
      nameArabic: 'بطل نصف السنة',
      description: 'Maintain a 180-day streak',
      descriptionArabic: 'حافظ على سلسلة 180 يوم',
      iconPath: 'assets/images/icons/achievement_streak_180.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.legendary,
      requiredValue: 180,
      xpReward: 1500,
      groupId: 'streak_days',
      prerequisites: ['streak_100'],
    ),
    Achievement(
      id: 'streak_365',
      name: 'Year-Round Explorer',
      nameArabic: 'مستكشف طوال السنة',
      description: 'Maintain a 365-day streak',
      descriptionArabic: 'حافظ على سلسلة 365 يوم',
      iconPath: 'assets/images/icons/achievement_streak_365.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 365,
      xpReward: 2500,
      groupId: 'streak_days',
      prerequisites: ['streak_180'],
    ),
    Achievement(
      id: 'streak_recovered',
      name: 'Never Give Up',
      nameArabic: 'لا تستسلم أبداً',
      description: 'Use streak freeze to save your streak',
      descriptionArabic: 'استخدم تجميد السلسلة لإنقاذ سلسلتك',
      iconPath: 'assets/images/icons/achievement_streak_freeze.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 100,
      isPremiumOnly: true,
    ),
    Achievement(
      id: 'weekend_warrior',
      name: 'Weekend Warrior',
      nameArabic: 'محارب عطلة نهاية الأسبوع',
      description: 'Complete quizzes every weekend for a month',
      descriptionArabic: 'أكمل اختبارات كل عطلة نهاية أسبوع لمدة شهر',
      iconPath: 'assets/images/icons/achievement_weekend.png',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 8,
      xpReward: 400,
    ),

    // ============================================================================
    // EXPLORATION ACHIEVEMENTS (10)
    // ============================================================================
    Achievement(
      id: 'africa_complete',
      name: 'African Explorer',
      nameArabic: 'مستكشف أفريقيا',
      description: 'Learn about all African countries',
      descriptionArabic: 'تعلم عن جميع الدول الأفريقية',
      iconPath: 'assets/images/icons/achievement_africa.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 54,
      xpReward: 400,
      groupId: 'continent_complete',
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
      rarity: AchievementRarity.rare,
      requiredValue: 44,
      xpReward: 400,
      groupId: 'continent_complete',
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
      rarity: AchievementRarity.rare,
      requiredValue: 48,
      xpReward: 400,
      groupId: 'continent_complete',
    ),
    Achievement(
      id: 'north_america_complete',
      name: 'North American Explorer',
      nameArabic: 'مستكشف أمريكا الشمالية',
      description: 'Learn about all North American countries',
      descriptionArabic: 'تعلم عن جميع دول أمريكا الشمالية',
      iconPath: 'assets/images/icons/achievement_north_america.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 23,
      xpReward: 300,
      groupId: 'continent_complete',
    ),
    Achievement(
      id: 'south_america_complete',
      name: 'South American Explorer',
      nameArabic: 'مستكشف أمريكا الجنوبية',
      description: 'Learn about all South American countries',
      descriptionArabic: 'تعلم عن جميع دول أمريكا الجنوبية',
      iconPath: 'assets/images/icons/achievement_south_america.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 12,
      xpReward: 250,
      groupId: 'continent_complete',
    ),
    Achievement(
      id: 'oceania_complete',
      name: 'Oceania Explorer',
      nameArabic: 'مستكشف أوقيانوسيا',
      description: 'Learn about all Oceanian countries',
      descriptionArabic: 'تعلم عن جميع دول أوقيانوسيا',
      iconPath: 'assets/images/icons/achievement_oceania.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 14,
      xpReward: 250,
      groupId: 'continent_complete',
    ),
    Achievement(
      id: 'all_continents',
      name: 'Continental Master',
      nameArabic: 'سيد القارات',
      description: 'Complete all 6 inhabited continents',
      descriptionArabic: 'أكمل جميع القارات الست المأهولة',
      iconPath: 'assets/images/icons/achievement_all_continents.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 6,
      xpReward: 1000,
      prerequisites: [
        'africa_complete',
        'europe_complete',
        'asia_complete',
        'north_america_complete',
        'south_america_complete',
        'oceania_complete',
      ],
    ),
    Achievement(
      id: 'island_nations',
      name: 'Island Hopper',
      nameArabic: 'قافز الجزر',
      description: 'Learn about 25 island nations',
      descriptionArabic: 'تعلم عن 25 دولة جزرية',
      iconPath: 'assets/images/icons/achievement_islands.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 25,
      xpReward: 350,
    ),
    Achievement(
      id: 'landlocked',
      name: 'Landlocked Expert',
      nameArabic: 'خبير الدول الحبيسة',
      description: 'Learn about all landlocked countries',
      descriptionArabic: 'تعلم عن جميع الدول الحبيسة',
      iconPath: 'assets/images/icons/achievement_landlocked.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 44,
      xpReward: 400,
    ),
    Achievement(
      id: 'un_members',
      name: 'UN Expert',
      nameArabic: 'خبير الأمم المتحدة',
      description: 'Learn about all UN member states',
      descriptionArabic: 'تعلم عن جميع الدول الأعضاء في الأمم المتحدة',
      iconPath: 'assets/images/icons/achievement_un.png',
      category: AchievementCategory.exploration,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 193,
      xpReward: 750,
    ),

    // ============================================================================
    // SOCIAL ACHIEVEMENTS (10)
    // ============================================================================
    Achievement(
      id: 'first_friend',
      name: 'Friendly Explorer',
      nameArabic: 'مستكشف ودود',
      description: 'Add your first friend',
      descriptionArabic: 'أضف أول صديق',
      iconPath: 'assets/images/icons/achievement_friend.png',
      category: AchievementCategory.social,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 100,
      groupId: 'friends_count',
    ),
    Achievement(
      id: 'friends_5',
      name: 'Social Explorer',
      nameArabic: 'مستكشف اجتماعي',
      description: 'Have 5 friends',
      descriptionArabic: 'أضف 5 أصدقاء',
      iconPath: 'assets/images/icons/achievement_friends_5.png',
      category: AchievementCategory.social,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.common,
      requiredValue: 5,
      xpReward: 200,
      groupId: 'friends_count',
      prerequisites: ['first_friend'],
    ),
    Achievement(
      id: 'friends_10',
      name: 'Social Butterfly',
      nameArabic: 'فراشة اجتماعية',
      description: 'Have 10 friends',
      descriptionArabic: 'أضف 10 أصدقاء',
      iconPath: 'assets/images/icons/achievement_friends_10.png',
      category: AchievementCategory.social,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 10,
      xpReward: 350,
      groupId: 'friends_count',
      prerequisites: ['friends_5'],
    ),
    Achievement(
      id: 'first_duel',
      name: 'Challenger',
      nameArabic: 'المتحدي',
      description: 'Complete your first duel',
      descriptionArabic: 'أكمل أول مبارزة',
      iconPath: 'assets/images/icons/achievement_duel.png',
      category: AchievementCategory.social,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 100,
      groupId: 'duels_count',
    ),
    Achievement(
      id: 'duel_winner',
      name: 'Duel Victor',
      nameArabic: 'منتصر المبارزة',
      description: 'Win your first duel',
      descriptionArabic: 'اربح أول مبارزة',
      iconPath: 'assets/images/icons/achievement_duel_win.png',
      category: AchievementCategory.social,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 150,
      groupId: 'duels_won',
    ),
    Achievement(
      id: 'duels_won_10',
      name: 'Duel Master',
      nameArabic: 'أستاذ المبارزات',
      description: 'Win 10 duels',
      descriptionArabic: 'اربح 10 مبارزات',
      iconPath: 'assets/images/icons/achievement_duel_master.png',
      category: AchievementCategory.social,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 10,
      xpReward: 400,
      groupId: 'duels_won',
      prerequisites: ['duel_winner'],
    ),
    Achievement(
      id: 'duels_won_50',
      name: 'Duel Champion',
      nameArabic: 'بطل المبارزات',
      description: 'Win 50 duels',
      descriptionArabic: 'اربح 50 مبارزة',
      iconPath: 'assets/images/icons/achievement_duel_champion.png',
      category: AchievementCategory.social,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 50,
      xpReward: 750,
      groupId: 'duels_won',
      prerequisites: ['duels_won_10'],
    ),
    Achievement(
      id: 'leaderboard_top_100',
      name: 'Rising Star',
      nameArabic: 'نجم صاعد',
      description: 'Reach top 100 on leaderboard',
      descriptionArabic: 'وصول إلى أفضل 100 في لوحة المتصدرين',
      iconPath: 'assets/images/icons/achievement_leaderboard_100.png',
      category: AchievementCategory.social,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 400,
      groupId: 'leaderboard_rank',
    ),
    Achievement(
      id: 'leaderboard_top_10',
      name: 'Elite Explorer',
      nameArabic: 'مستكشف النخبة',
      description: 'Reach top 10 on leaderboard',
      descriptionArabic: 'وصول إلى أفضل 10 في لوحة المتصدرين',
      iconPath: 'assets/images/icons/achievement_leaderboard_10.png',
      category: AchievementCategory.social,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 1,
      xpReward: 1000,
      groupId: 'leaderboard_rank',
      prerequisites: ['leaderboard_top_100'],
    ),
    Achievement(
      id: 'shared_achievement',
      name: 'Show Off',
      nameArabic: 'المتباهي',
      description: 'Share an achievement',
      descriptionArabic: 'شارك إنجازاً',
      iconPath: 'assets/images/icons/achievement_share.png',
      category: AchievementCategory.social,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 50,
    ),

    // ============================================================================
    // CHALLENGE ACHIEVEMENTS (10)
    // ============================================================================
    Achievement(
      id: 'first_daily_challenge',
      name: 'Daily Starter',
      nameArabic: 'بادئ اليوم',
      description: 'Complete your first daily challenge',
      descriptionArabic: 'أكمل أول تحدٍّ يومي',
      iconPath: 'assets/images/icons/achievement_daily_first.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 75,
      groupId: 'daily_challenges',
    ),
    Achievement(
      id: 'daily_challenges_7',
      name: 'Weekly Challenger',
      nameArabic: 'متحدي الأسبوع',
      description: 'Complete 7 daily challenges',
      descriptionArabic: 'أكمل 7 تحديات يومية',
      iconPath: 'assets/images/icons/achievement_daily_7.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.common,
      requiredValue: 7,
      xpReward: 200,
      groupId: 'daily_challenges',
    ),
    Achievement(
      id: 'daily_challenges_30',
      name: 'Monthly Challenger',
      nameArabic: 'متحدي الشهر',
      description: 'Complete 30 daily challenges',
      descriptionArabic: 'أكمل 30 تحدٍّ يومي',
      iconPath: 'assets/images/icons/achievement_daily_30.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 30,
      xpReward: 500,
      groupId: 'daily_challenges',
    ),
    Achievement(
      id: 'daily_challenges_100',
      name: 'Challenge Champion',
      nameArabic: 'بطل التحديات',
      description: 'Complete 100 daily challenges',
      descriptionArabic: 'أكمل 100 تحدٍّ يومي',
      iconPath: 'assets/images/icons/achievement_daily_100.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 100,
      xpReward: 1000,
      groupId: 'daily_challenges',
    ),
    Achievement(
      id: 'first_weekly_goal',
      name: 'Goal Setter',
      nameArabic: 'واضع الأهداف',
      description: 'Complete your first weekly goal',
      descriptionArabic: 'أكمل أول هدف أسبوعي',
      iconPath: 'assets/images/icons/achievement_weekly_first.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 100,
      groupId: 'weekly_goals',
    ),
    Achievement(
      id: 'weekly_goals_4',
      name: 'Goal Achiever',
      nameArabic: 'محقق الأهداف',
      description: 'Complete 4 weekly goals',
      descriptionArabic: 'أكمل 4 أهداف أسبوعية',
      iconPath: 'assets/images/icons/achievement_weekly_4.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 4,
      xpReward: 300,
      groupId: 'weekly_goals',
    ),
    Achievement(
      id: 'weekly_goals_12',
      name: 'Goal Master',
      nameArabic: 'سيد الأهداف',
      description: 'Complete 12 weekly goals',
      descriptionArabic: 'أكمل 12 هدف أسبوعي',
      iconPath: 'assets/images/icons/achievement_weekly_12.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.epic,
      requiredValue: 12,
      xpReward: 600,
      groupId: 'weekly_goals',
    ),
    Achievement(
      id: 'tournament_participant',
      name: 'Tournament Rookie',
      nameArabic: 'مبتدئ البطولات',
      description: 'Participate in your first tournament',
      descriptionArabic: 'شارك في أول بطولة',
      iconPath: 'assets/images/icons/achievement_tournament.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 200,
      groupId: 'tournaments',
    ),
    Achievement(
      id: 'tournament_winner',
      name: 'Tournament Champion',
      nameArabic: 'بطل البطولة',
      description: 'Win a tournament',
      descriptionArabic: 'اربح بطولة',
      iconPath: 'assets/images/icons/achievement_tournament_win.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.epic,
      requiredValue: 1,
      xpReward: 750,
      groupId: 'tournaments',
    ),
    Achievement(
      id: 'blitz_survivor',
      name: 'Blitz Survivor',
      nameArabic: 'ناجي البرق',
      description: 'Survive a timed blitz with 80%+ accuracy',
      descriptionArabic: 'انجُ من وضع البرق بدقة 80%+',
      iconPath: 'assets/images/icons/achievement_blitz.png',
      category: AchievementCategory.challenge,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 350,
    ),

    // ============================================================================
    // SPECIAL ACHIEVEMENTS (5)
    // ============================================================================
    Achievement(
      id: 'early_adopter',
      name: 'Early Adopter',
      nameArabic: 'متبني مبكر',
      description: 'Joined during the first month of launch',
      descriptionArabic: 'انضممت خلال الشهر الأول من الإطلاق',
      iconPath: 'assets/images/icons/achievement_early.png',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.legendary,
      requiredValue: 1,
      xpReward: 500,
    ),
    Achievement(
      id: 'premium_supporter',
      name: 'Premium Explorer',
      nameArabic: 'مستكشف مميز',
      description: 'Upgrade to Premium',
      descriptionArabic: 'ترقية إلى بريميوم',
      iconPath: 'assets/images/icons/achievement_premium.png',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 300,
      isPremiumOnly: true,
    ),
    Achievement(
      id: 'feedback_hero',
      name: 'Feedback Hero',
      nameArabic: 'بطل التعليقات',
      description: 'Submit helpful feedback',
      descriptionArabic: 'قدم ملاحظات مفيدة',
      iconPath: 'assets/images/icons/achievement_feedback.png',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 200,
    ),
    Achievement(
      id: 'app_rater',
      name: 'App Supporter',
      nameArabic: 'داعم التطبيق',
      description: 'Rate the app on the store',
      descriptionArabic: 'قيّم التطبيق في المتجر',
      iconPath: 'assets/images/icons/achievement_rate.png',
      category: AchievementCategory.special,
      tier: AchievementTier.bronze,
      rarity: AchievementRarity.common,
      requiredValue: 1,
      xpReward: 100,
    ),
    Achievement(
      id: 'comeback_kid',
      name: 'Comeback Kid',
      nameArabic: 'العائد',
      description: 'Return after 30+ days away',
      descriptionArabic: 'عُد بعد 30+ يوم من الغياب',
      iconPath: 'assets/images/icons/achievement_comeback.png',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 150,
    ),

    // ============================================================================
    // HIDDEN ACHIEVEMENTS (5)
    // ============================================================================
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      nameArabic: 'بومة الليل',
      description: 'Complete a quiz at 3 AM',
      descriptionArabic: 'أكمل اختبار في الساعة 3 صباحاً',
      iconPath: 'assets/images/icons/achievement_night.png',
      category: AchievementCategory.hidden,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 150,
      isHidden: true,
    ),
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      nameArabic: 'طائر مبكر',
      description: 'Complete a quiz at 5 AM',
      descriptionArabic: 'أكمل اختبار في الساعة 5 صباحاً',
      iconPath: 'assets/images/icons/achievement_early_bird.png',
      category: AchievementCategory.hidden,
      tier: AchievementTier.silver,
      rarity: AchievementRarity.rare,
      requiredValue: 1,
      xpReward: 150,
      isHidden: true,
    ),
    Achievement(
      id: 'lucky_seven',
      name: 'Lucky Seven',
      nameArabic: 'السبعة المحظوظة',
      description: 'Score exactly 77% on a quiz',
      descriptionArabic: 'احصل على 77% بالضبط في اختبار',
      iconPath: 'assets/images/icons/achievement_lucky.png',
      category: AchievementCategory.hidden,
      tier: AchievementTier.gold,
      rarity: AchievementRarity.epic,
      requiredValue: 1,
      xpReward: 277,
      isHidden: true,
    ),
    Achievement(
      id: 'globe_trotter',
      name: 'Globe Trotter',
      nameArabic: 'جوّال العالم',
      description: 'Take quizzes in 5 different countries',
      descriptionArabic: 'اختبر نفسك من 5 دول مختلفة',
      iconPath: 'assets/images/icons/achievement_globe_trotter.png',
      category: AchievementCategory.hidden,
      tier: AchievementTier.platinum,
      rarity: AchievementRarity.legendary,
      requiredValue: 5,
      xpReward: 500,
      isHidden: true,
    ),
    Achievement(
      id: 'perfectionist_extreme',
      name: 'Perfectionist Extreme',
      nameArabic: 'الكمال المتطرف',
      description: '10 perfect scores in 10 different quiz types',
      descriptionArabic: '10 نتائج مثالية في 10 أنواع اختبارات مختلفة',
      iconPath: 'assets/images/icons/achievement_perfect_extreme.png',
      category: AchievementCategory.hidden,
      tier: AchievementTier.diamond,
      rarity: AchievementRarity.legendary,
      requiredValue: 10,
      xpReward: 1000,
      isHidden: true,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by group
  static List<Achievement> getByGroup(String groupId) {
    return all.where((a) => a.groupId == groupId).toList();
  }

  /// Get visible (non-hidden) achievements
  static List<Achievement> get visible => all.where((a) => !a.isHidden).toList();

  /// Get hidden achievements
  static List<Achievement> get hidden => all.where((a) => a.isHidden).toList();

  /// Get achievements count by category
  static Map<AchievementCategory, int> get countByCategory {
    final counts = <AchievementCategory, int>{};
    for (final category in AchievementCategory.values) {
      counts[category] = getByCategory(category).length;
    }
    return counts;
  }

  /// Total achievements count
  static int get totalCount => all.length;
}
