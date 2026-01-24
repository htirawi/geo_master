import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography system - Explorer's Journey Theme
///
/// Font Pairing:
/// - Headlines: Playfair Display (elegant, cartographic feel)
/// - Body: Inter (clean, highly readable)
/// - Arabic: Tajawal (modern, professional)
/// - Numbers/Stats: JetBrains Mono (technical, precise)
abstract final class AppTypography {
  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  /// English headline font - elegant, cartographic
  static const String fontFamilyHeadline = 'Playfair Display';

  /// English body font - clean, readable
  static const String fontFamilyBody = 'Inter';

  /// Arabic font - modern, professional
  static const String fontFamilyArabic = 'Tajawal';

  /// Monospace font for stats/numbers - technical, precise
  static const String fontFamilyMono = 'JetBrains Mono';

  /// Legacy aliases for backwards compatibility
  static const String fontFamilyEnglish = fontFamilyBody;

  // ============================================================================
  // STANDARD TEXT STYLES (Material Design-like)
  // ============================================================================

  /// Display Large - 48px Playfair Display
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.12,
      );

  /// Display Medium - 36px Playfair Display
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.16,
      );

  /// Headline Large - 28px Playfair Display
  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
      );

  /// Headline Medium - 24px Inter
  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.29,
      );

  /// Headline Small - 20px Inter
  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      );

  /// Title Large - 22px Inter
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
      );

  /// Title Medium - 16px Inter
  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Title Small - 14px Inter
  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      );

  /// Body Large - 16px Inter
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Body Medium - 14px Inter
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      );

  /// Body Small - 12px Inter
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );

  /// Label Large - 14px Inter
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      );

  /// Label Medium - 12px Inter
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );

  /// Label Small - 10px Inter
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      );

  // ============================================================================
  // TEXT THEME GETTERS
  // ============================================================================

  /// Get text theme based on locale
  static TextTheme getTextTheme({required bool isArabic}) {
    return isArabic ? _arabicTextTheme : _englishTextTheme;
  }

  /// English text theme using Inter for body, Playfair Display for display/headlines
  static TextTheme get _englishTextTheme {
    // Base text theme with Inter
    final baseTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        // Body text - Inter (clean, readable)
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        // Title text - Inter
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        // Label text - Inter
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      ),
    );

    // Apply Playfair Display to display and headline styles
    return baseTheme.copyWith(
      // Display text - Playfair Display (elegant, cartographic)
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.22,
      ),
      // Headline text - Playfair Display
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),
    );
  }

  /// Arabic text theme using Tajawal
  static TextTheme get _arabicTextTheme {
    return GoogleFonts.tajawalTextTheme(
      const TextTheme(
        // Display text
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.25,
        ),
        // Headline text
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Title text
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.45,
        ),
        // Body text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.55,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
        ),
        // Label text
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.45,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.45,
        ),
      ),
    );
  }

  // ============================================================================
  // CUSTOM STYLES - QUIZ & GAMIFICATION
  // ============================================================================

  /// Large timer display (JetBrains Mono)
  static TextStyle get quizTimer => GoogleFonts.jetBrainsMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  /// Streak number display (JetBrains Mono)
  static TextStyle get streakNumber => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  /// XP amount display (JetBrains Mono)
  static TextStyle get xpAmount => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Large stat number (JetBrains Mono)
  static TextStyle get statLarge => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  /// Medium stat number (JetBrains Mono)
  static TextStyle get statMedium => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Small stat number (JetBrains Mono)
  static TextStyle get statSmall => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Score percentage display
  static TextStyle get scorePercentage => GoogleFonts.jetBrainsMono(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
      );

  // ============================================================================
  // CUSTOM STYLES - COUNTRY/GEOGRAPHY
  // ============================================================================

  /// Country name in cards/details (Playfair Display)
  static TextStyle get countryName => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Capital name display
  static TextStyle get capitalName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Continent label
  static TextStyle get continentLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Region title (Playfair Display)
  static TextStyle get regionTitle => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  // ============================================================================
  // CUSTOM STYLES - UI ELEMENTS
  // ============================================================================

  /// Button text
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Small button text
  static TextStyle get buttonTextSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      );

  /// Navigation label
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      );

  /// Chip label
  static TextStyle get chipLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
      );

  /// Badge text
  static TextStyle get badgeText => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  /// Hero title (Playfair Display - large)
  static TextStyle get heroTitle => GoogleFonts.playfairDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
      );

  /// Section header (Inter - bold)
  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  /// Card title
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Card subtitle
  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  /// Caption text
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  /// Overline text
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  // ============================================================================
  // CUSTOM STYLES - QUIZ SPECIFIC
  // ============================================================================

  /// Quiz question text
  static TextStyle get quizQuestion => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Quiz option text
  static TextStyle get quizOption => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Quiz result title (Playfair Display)
  static TextStyle get quizResultTitle => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  /// Fun fact text
  static TextStyle get funFact => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        fontStyle: FontStyle.italic,
        height: 1.5,
      );

  // ============================================================================
  // CUSTOM STYLES - PASSPORT/PROFILE
  // ============================================================================

  /// Passport title (elegant)
  static TextStyle get passportTitle => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );

  /// Passport stamp text
  static TextStyle get passportStamp => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Explorer rank title
  static TextStyle get explorerRank => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  /// Level display
  static TextStyle get levelDisplay => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get headline font based on locale
  static TextStyle getHeadlineStyle({
    required bool isArabic,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    if (isArabic) {
      return GoogleFonts.tajawal(
        fontSize: fontSize,
        fontWeight: fontWeight,
      );
    }
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get body font based on locale
  static TextStyle getBodyStyle({
    required bool isArabic,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    if (isArabic) {
      return GoogleFonts.tajawal(
        fontSize: fontSize,
        fontWeight: fontWeight,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get monospace style for numbers/stats
  static TextStyle getMonoStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
