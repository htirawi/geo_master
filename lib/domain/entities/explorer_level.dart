import 'package:flutter/material.dart';

/// Explorer levels for gamification progression
enum ExplorerLevel {
  novice(
    xpRequired: 0,
    titleEn: 'Novice Explorer',
    titleAr: 'مستكشف مبتدئ',
    icon: Icons.explore_outlined,
    color: Color(0xFF8B9DC3),
  ),
  apprentice(
    xpRequired: 500,
    titleEn: 'Apprentice Explorer',
    titleAr: 'مستكشف متدرب',
    icon: Icons.explore,
    color: Color(0xFF6B8E23),
  ),
  journeyman(
    xpRequired: 1500,
    titleEn: 'Journeyman Explorer',
    titleAr: 'مستكشف رحّال',
    icon: Icons.public,
    color: Color(0xFF4169E1),
  ),
  expert(
    xpRequired: 5000,
    titleEn: 'Expert Explorer',
    titleAr: 'مستكشف خبير',
    icon: Icons.language,
    color: Color(0xFF9932CC),
  ),
  master(
    xpRequired: 15000,
    titleEn: 'Master Explorer',
    titleAr: 'مستكشف بارع',
    icon: Icons.emoji_events,
    color: Color(0xFFFFD700),
  ),
  grandmaster(
    xpRequired: 50000,
    titleEn: 'Grandmaster Explorer',
    titleAr: 'أسطورة الاستكشاف',
    icon: Icons.workspace_premium,
    color: Color(0xFFE5E4E2),
  ),
  legend(
    xpRequired: 100000,
    titleEn: 'Legend',
    titleAr: 'أسطورة',
    icon: Icons.auto_awesome,
    color: Color(0xFFB9F2FF),
  );

  const ExplorerLevel({
    required this.xpRequired,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.color,
  });

  /// XP required to reach this level
  final int xpRequired;

  /// English title
  final String titleEn;

  /// Arabic title
  final String titleAr;

  /// Icon for this level
  final IconData icon;

  /// Color theme for this level
  final Color color;

  /// Get localized title
  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  /// Get short title for compact displays
  String getShortTitle(bool isArabic) {
    switch (this) {
      case ExplorerLevel.novice:
        return isArabic ? 'مبتدئ' : 'Novice';
      case ExplorerLevel.apprentice:
        return isArabic ? 'متدرب' : 'Apprentice';
      case ExplorerLevel.journeyman:
        return isArabic ? 'رحّال' : 'Journeyman';
      case ExplorerLevel.expert:
        return isArabic ? 'خبير' : 'Expert';
      case ExplorerLevel.master:
        return isArabic ? 'بارع' : 'Master';
      case ExplorerLevel.grandmaster:
        return isArabic ? 'أسطورة' : 'Grandmaster';
      case ExplorerLevel.legend:
        return isArabic ? 'أسطورة' : 'Legend';
    }
  }

  /// Get the next level (null if at max)
  ExplorerLevel? get nextLevel {
    const levels = ExplorerLevel.values;
    final currentIndex = levels.indexOf(this);
    if (currentIndex < levels.length - 1) {
      return levels[currentIndex + 1];
    }
    return null;
  }

  /// Get the previous level (null if at first)
  ExplorerLevel? get previousLevel {
    const levels = ExplorerLevel.values;
    final currentIndex = levels.indexOf(this);
    if (currentIndex > 0) {
      return levels[currentIndex - 1];
    }
    return null;
  }

  /// Get XP needed for next level
  int? get xpForNextLevel {
    final next = nextLevel;
    if (next != null) {
      return next.xpRequired - xpRequired;
    }
    return null;
  }

  /// Get the level for a given XP amount
  static ExplorerLevel fromXp(int xp) {
    final levels = ExplorerLevel.values.reversed.toList();
    for (final level in levels) {
      if (xp >= level.xpRequired) {
        return level;
      }
    }
    return ExplorerLevel.novice;
  }

  /// Calculate progress percentage to next level
  static double progressToNextLevel(int currentXp) {
    final currentLevel = fromXp(currentXp);
    final nextLevel = currentLevel.nextLevel;

    if (nextLevel == null) {
      return 1.0; // Max level
    }

    final xpInCurrentLevel = currentXp - currentLevel.xpRequired;
    final xpNeededForNext = nextLevel.xpRequired - currentLevel.xpRequired;

    return (xpInCurrentLevel / xpNeededForNext).clamp(0.0, 1.0);
  }

  /// Check if XP amount triggers a level up from a previous XP
  static ExplorerLevel? checkLevelUp(int previousXp, int newXp) {
    final previousLevel = fromXp(previousXp);
    final newLevel = fromXp(newXp);

    if (newLevel.index > previousLevel.index) {
      return newLevel;
    }
    return null;
  }
}

/// Level badge widget for displaying user's current level
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    this.size = LevelBadgeSize.medium,
    this.showTitle = true,
  });

  final ExplorerLevel level;
  final LevelBadgeSize size;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final iconSize = switch (size) {
      LevelBadgeSize.small => 20.0,
      LevelBadgeSize.medium => 28.0,
      LevelBadgeSize.large => 40.0,
    };

    final badgeSize = switch (size) {
      LevelBadgeSize.small => 32.0,
      LevelBadgeSize.medium => 44.0,
      LevelBadgeSize.large => 64.0,
    };

    final fontSize = switch (size) {
      LevelBadgeSize.small => 10.0,
      LevelBadgeSize.medium => 12.0,
      LevelBadgeSize.large => 14.0,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                level.color,
                level.color.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: level.color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            level.icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(width: 10),
          Text(
            level.getShortTitle(isArabic),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: level.color,
              fontSize: fontSize,
            ),
          ),
        ],
      ],
    );
  }
}

enum LevelBadgeSize { small, medium, large }
