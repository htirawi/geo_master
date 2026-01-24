import 'package:flutter/material.dart';

/// App color palette - Explorer's Journey Theme
/// "Cartographer's Ink" - Designed to evoke the excitement of world exploration
abstract final class AppColors {
  // ============================================================================
  // PRIMARY PALETTE - "Cartographer's Ink"
  // Deep navy for trust, adventure, exploration
  // ============================================================================
  static const Color primary = Color(0xFF1A365D);
  static const Color primaryLight = Color(0xFF2D4A7C);
  static const Color primaryDark = Color(0xFF0F2744);
  static const Color primarySurface = Color(0xFFE8EDF5);

  // Accent Gold - Achievement, discovery, treasure
  static const Color accent = Color(0xFFD4A84B);
  static const Color accentLight = Color(0xFFE8C97D);
  static const Color accentDark = Color(0xFFB8942F);
  static const Color accentSurface = Color(0xFFFAF5E8);

  // ============================================================================
  // SECONDARY PALETTE - "Natural World"
  // ============================================================================

  // Ocean depths to shallow waters
  static const Color oceanDeep = Color(0xFF064E7C);
  static const Color oceanMid = Color(0xFF0891B2);
  static const Color oceanShallow = Color(0xFF67E8F9);
  static const Color oceanSurface = Color(0xFFE0F7FA);

  // Forest greens - Nature, growth, exploration
  static const Color forestDense = Color(0xFF166534);
  static const Color forestLight = Color(0xFF22C55E);
  static const Color forestMoss = Color(0xFF84CC16);
  static const Color forestSurface = Color(0xFFE8F5E9);

  // Desert & Sand - Adventure, warmth
  static const Color desertWarm = Color(0xFFD97706);
  static const Color desertSand = Color(0xFFFDE68A);
  static const Color desertDusk = Color(0xFFF59E0B);
  static const Color desertSurface = Color(0xFFFEF9E7);

  // Mountain & Stone - Strength, achievement
  static const Color mountainPeak = Color(0xFF6B7280);
  static const Color mountainStone = Color(0xFF9CA3AF);
  static const Color mountainSnow = Color(0xFFF3F4F6);
  static const Color mountainSurface = Color(0xFFF9FAFB);

  // ============================================================================
  // CONTINENT COLORS - Distinct & Memorable
  // ============================================================================
  static const Color africa = Color(0xFFFF6B35);        // Warm sunset orange
  static const Color asia = Color(0xFFE63946);          // Rich crimson
  static const Color europe = Color(0xFF457B9D);        // Classic blue
  static const Color northAmerica = Color(0xFF2A9D8F);  // Teal green
  static const Color southAmerica = Color(0xFFE9C46A);  // Golden yellow
  static const Color oceania = Color(0xFF00B4D8);       // Bright cyan
  static const Color antarctica = Color(0xFFCAF0F8);    // Ice blue

  // Legacy region color aliases (for backwards compatibility)
  static const Color regionAfrica = africa;
  static const Color regionAsia = asia;
  static const Color regionEurope = europe;
  static const Color regionNorthAmerica = northAmerica;
  static const Color regionSouthAmerica = southAmerica;
  static const Color regionOceania = oceania;
  static const Color regionAntarctica = antarctica;
  static const Color regionAmericas = northAmerica;

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFD1FAE5);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFDBEAFE);

  // ============================================================================
  // GAMIFICATION COLORS
  // ============================================================================
  static const Color xpGold = Color(0xFFFFD700);
  static const Color xpGoldLight = Color(0xFFFFE566);
  static const Color xpGoldDark = Color(0xFFCCAA00);

  static const Color streak = Color(0xFFFF6B6B);
  static const Color streakLight = Color(0xFFFF9999);
  static const Color streakDark = Color(0xFFE63946);

  static const Color achievement = Color(0xFF9333EA);
  static const Color achievementLight = Color(0xFFC084FC);
  static const Color achievementDark = Color(0xFF7C3AED);

  static const Color levelUp = Color(0xFF06B6D4);
  static const Color levelUpLight = Color(0xFF67E8F9);
  static const Color levelUpDark = Color(0xFF0891B2);

  // ============================================================================
  // PREMIUM COLORS
  // ============================================================================
  static const Color premium = Color(0xFFDAA520);       // Goldenrod
  static const Color premiumGold = Color(0xFFDAA520);
  static const Color premiumPurple = Color(0xFF6A1B9A);
  static const Color premiumSurface = Color(0xFFFAF3E0);

  // ============================================================================
  // LIGHT THEME COLORS
  // ============================================================================
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF64748B);
  static const Color textHintLight = Color(0xFF94A3B8);

  // ============================================================================
  // DARK THEME COLORS
  // ============================================================================
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);

  // ============================================================================
  // QUIZ COLORS
  // ============================================================================
  static const Color quizCorrect = success;
  static const Color quizIncorrect = error;
  static const Color quizSelected = primary;
  static const Color quizUnselected = Color(0xFFE2E8F0);
  static const Color quizHint = info;

  // ============================================================================
  // MAP COLORS
  // ============================================================================
  static const Color mapHighlight = primary;
  static const Color mapVisited = success;
  static const Color mapUnvisited = Color(0xFFE2E8F0);
  static const Color mapMastered = accent;
  static const Color mapInProgress = oceanMid;

  // ============================================================================
  // DIFFICULTY COLORS
  // ============================================================================
  static const Color difficultyEasy = forestLight;
  static const Color difficultyMedium = desertWarm;
  static const Color difficultyHard = error;

  // ============================================================================
  // SUBSCRIPTION TIER COLORS
  // ============================================================================
  static const Color tierFree = mountainStone;
  static const Color tierBasic = oceanMid;
  static const Color tierPro = accent;
  static const Color tierPremium = premiumPurple;

  // ============================================================================
  // LEGACY COLORS (for backwards compatibility)
  // ============================================================================
  static const Color secondary = desertWarm;
  static const Color secondaryLight = desertDusk;
  static const Color secondaryDark = Color(0xFFC43C00);
  static const Color tertiary = oceanMid;
  static const Color tertiaryLight = oceanShallow;
  static const Color tertiaryDark = oceanDeep;
  static const Color earth = Color(0xFF8D6E63);
  static const Color earthLight = Color(0xFFBE9C91);
  static const Color earthDark = Color(0xFF5D4037);
  static const Color sand = desertSand;
  static const Color sandDark = Color(0xFFFFE082);
  static const Color forest = forestDense;
  static const Color ocean = oceanMid;
  static const Color mountain = mountainPeak;
  static const Color glacier = oceanShallow;
  static const Color sunset = africa;
  static const Color sunrise = desertDusk;

  // ============================================================================
  // GRADIENTS - Explorer Theme
  // ============================================================================

  // Hero gradient for headers - The Explorer's Journey
  static const LinearGradient explorerGradient = LinearGradient(
    colors: [primaryDark, primary, oceanMid],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Achievement/Premium gradient - Treasure Glow
  static const LinearGradient treasureGradient = LinearGradient(
    colors: [accent, desertDusk, desertWarm],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Map overlay gradient
  static LinearGradient get mapGradient => RadialGradient(
    colors: [
      Colors.transparent,
      primary.withValues(alpha: 0.8),
    ],
    center: Alignment.center,
    radius: 1.5,
  ) as LinearGradient; // Note: This returns RadialGradient actually

  static const RadialGradient mapOverlayGradient = RadialGradient(
    colors: [
      Color(0x00000000),
      Color(0xCC1A365D),
    ],
    center: Alignment.center,
    radius: 1.5,
  );

  // Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient (warm adventure)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [desertWarm, desertDusk, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumGold, Color(0xFF8B5CF6), premiumPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [successDark, success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ocean gradient - Deep sea exploration
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [oceanDeep, oceanMid, oceanShallow],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Sunset gradient - Adventure awaits
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF5722), desertWarm, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Forest gradient - Nature exploration
  static const LinearGradient forestGradient = LinearGradient(
    colors: [forestDense, forestLight, forestMoss],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Earth gradient - Grounded adventure
  static const LinearGradient earthGradient = LinearGradient(
    colors: [earthDark, earth, earthLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sky gradient - Endless possibilities
  static const LinearGradient skyGradient = LinearGradient(
    colors: [primary, info, infoSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Adventure gradient - Primary to tertiary
  static const LinearGradient adventureGradient = LinearGradient(
    colors: [primary, oceanMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compass gradient - Navigation feel
  static const RadialGradient compassGradient = RadialGradient(
    colors: [desertSand, accentLight, accent],
    center: Alignment.center,
    radius: 1.0,
  );

  // Explorer card gradient
  static const LinearGradient explorerCardGradient = LinearGradient(
    colors: [primary, oceanMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Streak fire gradient
  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakDark, streak, streakLight],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // XP/Achievement gradient
  static const LinearGradient xpGradient = LinearGradient(
    colors: [xpGoldDark, xpGold, xpGoldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Level up celebration gradient
  static const LinearGradient levelUpGradient = LinearGradient(
    colors: [achievementDark, achievement, achievementLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass effect colors
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassDark = Colors.black.withValues(alpha: 0.15);
  static Color glassStroke = Colors.white.withValues(alpha: 0.2);

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get continent color by name
  static Color getContinentColor(String continent) {
    switch (continent.toLowerCase()) {
      case 'africa':
        return africa;
      case 'asia':
        return asia;
      case 'europe':
        return europe;
      case 'north america':
      case 'northamerica':
        return northAmerica;
      case 'south america':
      case 'southamerica':
        return southAmerica;
      case 'oceania':
      case 'australia':
        return oceania;
      case 'antarctica':
        return antarctica;
      default:
        return primary;
    }
  }

  /// Get difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return difficultyEasy;
      case 'medium':
        return difficultyMedium;
      case 'hard':
        return difficultyHard;
      default:
        return difficultyMedium;
    }
  }

  /// Get mastery color based on percentage
  static Color getMasteryColor(double percentage) {
    if (percentage >= 90) return accent;       // Mastered - Gold
    if (percentage >= 70) return success;      // Good - Green
    if (percentage >= 50) return oceanMid;     // Progress - Blue
    if (percentage >= 25) return desertWarm;   // Learning - Orange
    return mountainStone;                       // Starting - Gray
  }
}
