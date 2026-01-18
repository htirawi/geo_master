import 'package:flutter/material.dart';

/// App color palette - Explorer's Journey Theme
/// Inspired by Earth's natural beauty: oceans, forests, deserts, mountains
abstract final class AppColors {
  // Primary Colors - Deep Ocean Blue (exploration, discovery)
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  // Secondary/Accent Colors - Sunset Orange (adventure, energy)
  static const Color secondary = Color(0xFFFF6D00);
  static const Color secondaryLight = Color(0xFFFF9E40);
  static const Color secondaryDark = Color(0xFFC43C00);

  // Tertiary Colors - Forest Teal (nature, growth)
  static const Color tertiary = Color(0xFF00897B);
  static const Color tertiaryLight = Color(0xFF4DB6AC);
  static const Color tertiaryDark = Color(0xFF005B4F);

  // Explorer Theme - Earth Tones
  static const Color earth = Color(0xFF8D6E63);
  static const Color earthLight = Color(0xFFBE9C91);
  static const Color earthDark = Color(0xFF5D4037);
  static const Color sand = Color(0xFFFFF8E1);
  static const Color sandDark = Color(0xFFFFE082);
  static const Color forest = Color(0xFF2E7D32);
  static const Color ocean = Color(0xFF0277BD);
  static const Color oceanDeep = Color(0xFF01579B);
  static const Color mountain = Color(0xFF546E7A);
  static const Color glacier = Color(0xFFB3E5FC);
  static const Color sunset = Color(0xFFFF7043);
  static const Color sunrise = Color(0xFFFFB74D);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFA5D6A7);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFE082);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF90CAF9);

  // Gamification Colors
  static const Color xpGold = Color(0xFFFFD700);
  static const Color streak = Color(0xFFFF6B6B);
  static const Color achievement = Color(0xFF9C27B0);
  static const Color levelUp = Color(0xFF00BCD4);

  // Premium Colors
  static const Color premium = Color(0xFF6A1B9A);
  static const Color premiumGold = Color(0xFFDAA520);
  static const Color premiumPurple = Color(0xFF6A1B9A);

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF4A5568);
  static const Color textTertiaryLight = Color(0xFF718096);
  static const Color textHintLight = Color(0xFFA0AEC0);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color dividerDark = Color(0xFF424242);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textHintDark = Color(0xFF757575);

  // Quiz Colors
  static const Color quizCorrect = Color(0xFF4CAF50);
  static const Color quizIncorrect = Color(0xFFE53935);
  static const Color quizSelected = Color(0xFF1E88E5);
  static const Color quizUnselected = Color(0xFFE0E0E0);

  // Map Colors
  static const Color mapHighlight = Color(0xFF1E88E5);
  static const Color mapVisited = Color(0xFF4CAF50);
  static const Color mapUnvisited = Color(0xFFE0E0E0);

  // Region Colors (for map visualization)
  static const Color regionAfrica = Color(0xFFFF7043);
  static const Color regionAsia = Color(0xFFFFCA28);
  static const Color regionEurope = Color(0xFF42A5F5);
  static const Color regionNorthAmerica = Color(0xFF66BB6A);
  static const Color regionSouthAmerica = Color(0xFFAB47BC);
  static const Color regionOceania = Color(0xFF26C6DA);
  static const Color regionAntarctica = Color(0xFF78909C);
  // Alias for combined Americas
  static const Color regionAmericas = Color(0xFF66BB6A);

  // Gradients - Explorer Theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryDark, secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumGold, premiumPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Explorer Journey Gradients
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [oceanDeep, ocean, glacier],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF9800), Color(0xFFFFEB3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), forest, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient earthGradient = LinearGradient(
    colors: [earthDark, earth, earthLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF64B5F6), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient adventureGradient = LinearGradient(
    colors: [primary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient compassGradient = RadialGradient(
    colors: [sand, earthLight, earth],
    center: Alignment.center,
    radius: 1.0,
  );

  static const LinearGradient explorerCardGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Difficulty Colors
  static const Color difficultyEasy = Color(0xFF4CAF50);
  static const Color difficultyMedium = Color(0xFFFF9800);
  static const Color difficultyHard = Color(0xFFE53935);

  // Subscription Tier Colors
  static const Color tierFree = Color(0xFF9E9E9E);
  static const Color tierBasic = Color(0xFF1E88E5);
  static const Color tierPro = Color(0xFFFFD700);
  static const Color tierPremium = Color(0xFF6A1B9A);
}
