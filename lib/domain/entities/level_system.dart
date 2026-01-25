import 'package:flutter/material.dart';

/// Level tier definition for the extended leveling system
/// 8 tiers spanning 60+ levels
@immutable
class LevelTier {
  const LevelTier({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.minLevel,
    required this.maxLevel,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.badgeAsset,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final int minLevel;
  final int maxLevel;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String badgeAsset;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;

  /// Check if a level belongs to this tier
  bool containsLevel(int level) => level >= minLevel && level <= maxLevel;
}

/// All level tiers in the game
class LevelTiers {
  LevelTiers._();

  static const LevelTier novice = LevelTier(
    id: 'novice',
    nameEn: 'Novice',
    nameAr: 'مبتدئ',
    minLevel: 1,
    maxLevel: 5,
    primaryColor: Color(0xFF8B9DC3), // Soft blue-gray
    secondaryColor: Color(0xFFB8C5D9),
    icon: Icons.explore_outlined,
    badgeAsset: 'assets/images/badges/novice.png',
  );

  static const LevelTier apprentice = LevelTier(
    id: 'apprentice',
    nameEn: 'Apprentice',
    nameAr: 'متدرب',
    minLevel: 6,
    maxLevel: 10,
    primaryColor: Color(0xFF6B8E23), // Olive drab
    secondaryColor: Color(0xFF9ACD32),
    icon: Icons.explore,
    badgeAsset: 'assets/images/badges/apprentice.png',
  );

  static const LevelTier journeyman = LevelTier(
    id: 'journeyman',
    nameEn: 'Journeyman',
    nameAr: 'رحّال',
    minLevel: 11,
    maxLevel: 20,
    primaryColor: Color(0xFF4169E1), // Royal blue
    secondaryColor: Color(0xFF6495ED),
    icon: Icons.public,
    badgeAsset: 'assets/images/badges/journeyman.png',
  );

  static const LevelTier expert = LevelTier(
    id: 'expert',
    nameEn: 'Expert',
    nameAr: 'خبير',
    minLevel: 21,
    maxLevel: 30,
    primaryColor: Color(0xFF9932CC), // Dark orchid
    secondaryColor: Color(0xFFBA55D3),
    icon: Icons.language,
    badgeAsset: 'assets/images/badges/expert.png',
  );

  static const LevelTier master = LevelTier(
    id: 'master',
    nameEn: 'Master',
    nameAr: 'أستاذ',
    minLevel: 31,
    maxLevel: 40,
    primaryColor: Color(0xFFFFD700), // Gold
    secondaryColor: Color(0xFFFFE066),
    icon: Icons.emoji_events,
    badgeAsset: 'assets/images/badges/master.png',
  );

  static const LevelTier grandmaster = LevelTier(
    id: 'grandmaster',
    nameEn: 'Grandmaster',
    nameAr: 'أسطورة',
    minLevel: 41,
    maxLevel: 50,
    primaryColor: Color(0xFF00CED1), // Dark turquoise (sapphire-like)
    secondaryColor: Color(0xFF48D1CC),
    icon: Icons.workspace_premium,
    badgeAsset: 'assets/images/badges/grandmaster.png',
  );

  static const LevelTier legend = LevelTier(
    id: 'legend',
    nameEn: 'Legend',
    nameAr: 'خارق',
    minLevel: 51,
    maxLevel: 60,
    primaryColor: Color(0xFFE5E4E2), // Platinum
    secondaryColor: Color(0xFFF5F5F5),
    icon: Icons.auto_awesome,
    badgeAsset: 'assets/images/badges/legend.png',
  );

  static const LevelTier mythic = LevelTier(
    id: 'mythic',
    nameEn: 'Mythic',
    nameAr: 'أسطوري',
    minLevel: 61,
    maxLevel: 999, // Effectively no cap
    primaryColor: Color(0xFFFF69B4), // Rainbow/prismatic effect base
    secondaryColor: Color(0xFFFF1493),
    icon: Icons.stars,
    badgeAsset: 'assets/images/badges/mythic.png',
  );

  static const List<LevelTier> all = [
    novice,
    apprentice,
    journeyman,
    expert,
    master,
    grandmaster,
    legend,
    mythic,
  ];

  /// Get tier for a given level
  static LevelTier getTierForLevel(int level) {
    for (final tier in all) {
      if (tier.containsLevel(level)) {
        return tier;
      }
    }
    return mythic; // Default to mythic for very high levels
  }

  /// Get tier by ID
  static LevelTier? getTierById(String id) {
    try {
      return all.firstWhere((tier) => tier.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Reward type for level-up rewards
enum LevelRewardType {
  xpBoost,
  achievement,
  badge,
  feature,
  title,
  cosmetic,
}

/// Level reward definition
@immutable
class LevelReward {
  const LevelReward({
    required this.type,
    required this.value,
    this.descriptionEn,
    this.descriptionAr,
  });

  final LevelRewardType type;
  final dynamic value;
  final String? descriptionEn;
  final String? descriptionAr;

  String? getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;
}

/// Complete level information
@immutable
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.tier,
    required this.xpRequired,
    required this.xpForNextLevel,
    this.rewards = const [],
  });

  final int level;
  final LevelTier tier;
  final int xpRequired;
  final int xpForNextLevel;
  final List<LevelReward> rewards;

  /// Check if this is the first level of a new tier
  bool get isNewTier => level == tier.minLevel;

  /// Get progress within the current tier (0.0 to 1.0)
  double get tierProgress {
    final tierLevels = tier.maxLevel - tier.minLevel + 1;
    final levelInTier = level - tier.minLevel;
    return levelInTier / tierLevels;
  }
}

/// Extended level system with 50+ levels
class ExtendedLevelSystem {
  ExtendedLevelSystem._();

  /// Maximum practical level (can go higher for mythic tier)
  static const int maxDisplayLevel = 60;

  /// XP formula: Progressive curve with tier-based scaling
  /// - Levels 1-10: Gentle curve for new players
  /// - Levels 11-30: Moderate progression
  /// - Levels 31-50: Steeper curve for dedicated players
  /// - Levels 51+: Legendary grind
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;

    // Tier 1: Novice (1-5) - Very gentle
    if (level <= 5) {
      return 100 * (level - 1) * level; // 0, 200, 600, 1200, 2000
    }

    // Tier 2: Apprentice (6-10)
    if (level <= 10) {
      const baseXp = 2000; // XP at level 5
      return baseXp + 600 * (level - 5) * (level - 4); // Steeper growth
    }

    // Tier 3: Journeyman (11-20)
    if (level <= 20) {
      const baseXp = 8000; // XP at level 10
      final progressLevel = level - 10;
      return baseXp + 1500 * progressLevel + 150 * progressLevel * progressLevel;
    }

    // Tier 4: Expert (21-30)
    if (level <= 30) {
      const baseXp = 35000; // XP at level 20
      final progressLevel = level - 20;
      return baseXp + 3000 * progressLevel + 300 * progressLevel * progressLevel;
    }

    // Tier 5: Master (31-40)
    if (level <= 40) {
      const baseXp = 100000; // XP at level 30
      final progressLevel = level - 30;
      return baseXp + 8000 * progressLevel + 800 * progressLevel * progressLevel;
    }

    // Tier 6: Grandmaster (41-50)
    if (level <= 50) {
      const baseXp = 300000; // XP at level 40
      final progressLevel = level - 40;
      return baseXp + 20000 * progressLevel + 2000 * progressLevel * progressLevel;
    }

    // Tier 7: Legend (51-60)
    if (level <= 60) {
      const baseXp = 750000; // XP at level 50
      final progressLevel = level - 50;
      return baseXp + 50000 * progressLevel + 5000 * progressLevel * progressLevel;
    }

    // Tier 8: Mythic (61+)
    const baseXp = 2000000; // XP at level 60
    final progressLevel = level - 60;
    return baseXp + 100000 * progressLevel + 10000 * progressLevel * progressLevel;
  }

  /// Calculate level from total XP
  static int levelFromXp(int totalXp) {
    var level = 1;
    while (xpRequiredForLevel(level + 1) <= totalXp) {
      level++;
      // Safety cap to prevent infinite loops
      if (level > 999) break;
    }
    return level;
  }

  /// Get complete level info for a level number
  static LevelInfo getLevelInfo(int level) {
    final tier = LevelTiers.getTierForLevel(level);
    final xpRequired = xpRequiredForLevel(level);
    final xpForNext = xpRequiredForLevel(level + 1) - xpRequired;

    return LevelInfo(
      level: level,
      tier: tier,
      xpRequired: xpRequired,
      xpForNextLevel: xpForNext,
      rewards: _getRewardsForLevel(level),
    );
  }

  /// Get level info from total XP
  static LevelInfo getLevelInfoFromXp(int totalXp) {
    final level = levelFromXp(totalXp);
    return getLevelInfo(level);
  }

  /// Calculate progress to next level (0.0 to 1.0)
  static double progressToNextLevel(int totalXp) {
    final currentLevel = levelFromXp(totalXp);
    final currentLevelXp = xpRequiredForLevel(currentLevel);
    final nextLevelXp = xpRequiredForLevel(currentLevel + 1);

    final xpInCurrentLevel = totalXp - currentLevelXp;
    final xpNeededForNext = nextLevelXp - currentLevelXp;

    if (xpNeededForNext <= 0) return 1.0;
    return (xpInCurrentLevel / xpNeededForNext).clamp(0.0, 1.0);
  }

  /// Check if XP gain triggers a level up
  static LevelUpResult? checkLevelUp(int previousXp, int newXp) {
    final previousLevel = levelFromXp(previousXp);
    final newLevel = levelFromXp(newXp);

    if (newLevel > previousLevel) {
      final levelInfos = <LevelInfo>[];
      for (var l = previousLevel + 1; l <= newLevel; l++) {
        levelInfos.add(getLevelInfo(l));
      }
      return LevelUpResult(
        previousLevel: previousLevel,
        newLevel: newLevel,
        levelInfos: levelInfos,
      );
    }
    return null;
  }

  /// Get rewards for reaching a specific level
  static List<LevelReward> _getRewardsForLevel(int level) {
    final rewards = <LevelReward>[];

    // Tier milestone rewards (first level of each tier)
    final tier = LevelTiers.getTierForLevel(level);
    if (level == tier.minLevel && level > 1) {
      rewards.add(LevelReward(
        type: LevelRewardType.badge,
        value: tier.badgeAsset,
        descriptionEn: 'Unlocked ${tier.nameEn} Badge',
        descriptionAr: 'فتح شارة ${tier.nameAr}',
      ));
      rewards.add(LevelReward(
        type: LevelRewardType.title,
        value: tier.id,
        descriptionEn: 'New Title: ${tier.nameEn}',
        descriptionAr: 'لقب جديد: ${tier.nameAr}',
      ));
    }

    // XP boost milestones
    if (level == 10) {
      rewards.add(const LevelReward(
        type: LevelRewardType.xpBoost,
        value: 0.05, // 5% XP boost
        descriptionEn: '+5% XP Boost',
        descriptionAr: '+5% زيادة نقاط الخبرة',
      ));
    } else if (level == 25) {
      rewards.add(const LevelReward(
        type: LevelRewardType.xpBoost,
        value: 0.10, // 10% XP boost
        descriptionEn: '+10% XP Boost',
        descriptionAr: '+10% زيادة نقاط الخبرة',
      ));
    } else if (level == 50) {
      rewards.add(const LevelReward(
        type: LevelRewardType.xpBoost,
        value: 0.15, // 15% XP boost
        descriptionEn: '+15% XP Boost',
        descriptionAr: '+15% زيادة نقاط الخبرة',
      ));
    }

    // Feature unlocks
    if (level == 5) {
      rewards.add(const LevelReward(
        type: LevelRewardType.feature,
        value: 'daily_challenges',
        descriptionEn: 'Daily Challenges Unlocked',
        descriptionAr: 'تم فتح التحديات اليومية',
      ));
    } else if (level == 10) {
      rewards.add(const LevelReward(
        type: LevelRewardType.feature,
        value: 'weekly_goals',
        descriptionEn: 'Weekly Goals Unlocked',
        descriptionAr: 'تم فتح الأهداف الأسبوعية',
      ));
    } else if (level == 15) {
      rewards.add(const LevelReward(
        type: LevelRewardType.feature,
        value: 'friends_system',
        descriptionEn: 'Friends System Unlocked',
        descriptionAr: 'تم فتح نظام الأصدقاء',
      ));
    } else if (level == 20) {
      rewards.add(const LevelReward(
        type: LevelRewardType.feature,
        value: 'tournaments',
        descriptionEn: 'Tournaments Unlocked',
        descriptionAr: 'تم فتح البطولات',
      ));
    }

    return rewards;
  }

  /// Calculate XP bonus multiplier based on level
  /// Higher level players earn slightly more XP
  static double getXpMultiplier(int level) {
    if (level < 10) return 1.0;
    if (level < 25) return 1.05;
    if (level < 40) return 1.10;
    if (level < 50) return 1.15;
    return 1.20; // Legend/Mythic bonus
  }
}

/// Result of a level up check
@immutable
class LevelUpResult {
  const LevelUpResult({
    required this.previousLevel,
    required this.newLevel,
    required this.levelInfos,
  });

  final int previousLevel;
  final int newLevel;
  final List<LevelInfo> levelInfos;

  /// Number of levels gained
  int get levelsGained => newLevel - previousLevel;

  /// Check if reached a new tier
  bool get reachedNewTier {
    final previousTier = LevelTiers.getTierForLevel(previousLevel);
    final newTier = LevelTiers.getTierForLevel(newLevel);
    return previousTier.id != newTier.id;
  }

  /// Get the new tier if reached
  LevelTier? get newTier {
    if (reachedNewTier) {
      return LevelTiers.getTierForLevel(newLevel);
    }
    return null;
  }

  /// Get all rewards from level ups
  List<LevelReward> get allRewards {
    return levelInfos.expand((info) => info.rewards).toList();
  }
}

/// Level display utilities
class LevelDisplay {
  LevelDisplay._();

  /// Format level with tier prefix (e.g., "Novice 3" or "Master 5")
  static String formatLevelWithTier(int level, {required bool isArabic}) {
    final tier = LevelTiers.getTierForLevel(level);
    final levelInTier = level - tier.minLevel + 1;
    final tierName = tier.getName(isArabic);
    return isArabic ? '$tierName $levelInTier' : '$tierName $levelInTier';
  }

  /// Format XP with K/M suffix for large numbers
  static String formatXp(int xp) {
    if (xp >= 1000000) {
      return '${(xp / 1000000).toStringAsFixed(1)}M';
    }
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(xp >= 10000 ? 0 : 1)}K';
    }
    return xp.toString();
  }

  /// Get color gradient for level badge
  static List<Color> getLevelGradient(int level) {
    final tier = LevelTiers.getTierForLevel(level);
    return [tier.primaryColor, tier.secondaryColor];
  }

  /// Get glow color for level effects
  static Color getLevelGlowColor(int level) {
    final tier = LevelTiers.getTierForLevel(level);
    return tier.primaryColor.withValues(alpha: 0.5);
  }
}
