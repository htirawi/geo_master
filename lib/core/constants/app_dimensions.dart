import 'package:flutter/material.dart';

/// App dimensions and spacing constants - Explorer's Journey Theme
///
/// Based on 8px grid system for consistent visual rhythm
abstract final class AppDimensions {
  // ============================================================================
  // SPACING SYSTEM (8px grid)
  // ============================================================================

  /// 4px - Extra extra small
  static const double xxs = 4.0;

  /// 8px - Extra small
  static const double xs = 8.0;

  /// 12px - Small
  static const double sm = 12.0;

  /// 16px - Medium (base unit)
  static const double md = 16.0;

  /// 24px - Large
  static const double lg = 24.0;

  /// 32px - Extra large
  static const double xl = 32.0;

  /// 48px - Extra extra large
  static const double xxl = 48.0;

  /// 64px - Extra extra extra large
  static const double xxxl = 64.0;

  // Legacy padding aliases (for backwards compatibility)
  static const double paddingXS = xxs;
  static const double paddingS = xs;
  static const double paddingM = md;
  static const double paddingL = lg;
  static const double paddingXL = xl;
  static const double paddingXXL = xxl;
  static const double paddingSM = xs;
  static const double paddingMD = md;
  static const double paddingLG = lg;

  // Spacing aliases
  static const double spacingXS = xxs;
  static const double spacingSM = xs;
  static const double spacingMD = md;
  static const double spacingLG = lg;
  static const double spacingXL = xl;
  static const double spacingXXL = xxl;

  // ============================================================================
  // SCREEN PADDING
  // ============================================================================

  /// Default horizontal screen padding
  static const double screenPaddingHorizontal = md;

  /// Default vertical screen padding
  static const double screenPaddingVertical = lg;

  /// Screen edge insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  /// Content padding (no vertical padding)
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
  );

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// 4px - Extra small radius
  static const double radiusXS = 4.0;

  /// 8px - Small radius (buttons, chips)
  static const double radiusSM = 8.0;

  /// 12px - Medium radius (cards, inputs)
  static const double radiusMD = 12.0;

  /// 16px - Large radius (modals, sheets)
  static const double radiusLG = 16.0;

  /// 24px - Extra large radius (feature cards)
  static const double radiusXL = 24.0;

  /// 32px - Extra extra large radius
  static const double radiusXXL = 32.0;

  /// Full/pill radius
  static const double radiusFull = 9999.0;

  /// Circular radius (legacy alias)
  static const double radiusCircular = radiusFull;

  // Legacy radius aliases
  static const double radiusS = radiusSM;
  static const double radiusM = radiusMD;
  static const double radiusL = radiusLG;

  // BorderRadius presets
  static final BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);
  static final BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================

  /// Subtle lift - elevation 1
  static const double elevation1 = 2.0;

  /// Card elevation - elevation 2
  static const double elevation2 = 4.0;

  /// Modal/floating - elevation 3
  static const double elevation3 = 8.0;

  /// High elevation
  static const double elevation4 = 16.0;

  // Legacy aliases
  static const double cardElevation = elevation1;
  static const double cardElevationHigh = elevation3;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// 16px - Extra small icon
  static const double iconXS = 16.0;

  /// 20px - Small icon
  static const double iconSM = 20.0;

  /// 24px - Medium icon (default)
  static const double iconMD = 24.0;

  /// 32px - Large icon
  static const double iconLG = 32.0;

  /// 48px - Extra large icon
  static const double iconXL = 48.0;

  /// 64px - Extra extra large icon
  static const double iconXXL = 64.0;

  // Legacy aliases
  static const double iconS = iconSM;
  static const double iconM = iconMD;
  static const double iconL = iconLG;

  // ============================================================================
  // AVATAR SIZES
  // ============================================================================

  /// 24px - Extra small avatar
  static const double avatarXS = 24.0;

  /// 32px - Small avatar
  static const double avatarSM = 32.0;

  /// 48px - Medium avatar
  static const double avatarMD = 48.0;

  /// 64px - Large avatar
  static const double avatarLG = 64.0;

  /// 96px - Extra large avatar
  static const double avatarXL = 96.0;

  /// 128px - Extra extra large avatar
  static const double avatarXXL = 128.0;

  // Legacy aliases
  static const double avatarS = avatarSM;
  static const double avatarM = avatarMD;
  static const double avatarL = avatarLG;

  // ============================================================================
  // BUTTON DIMENSIONS
  // ============================================================================

  /// 36px - Small button height
  static const double buttonHeightSM = 36.0;

  /// 48px - Medium button height (default)
  static const double buttonHeightMD = 48.0;

  /// 56px - Large button height
  static const double buttonHeightLG = 56.0;

  // Legacy aliases
  static const double buttonHeightS = buttonHeightSM;
  static const double buttonHeightM = buttonHeightMD;
  static const double buttonHeightL = buttonHeightLG;

  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 44.0;

  // ============================================================================
  // INPUT DIMENSIONS
  // ============================================================================

  /// 48px - Standard input field height
  static const double inputHeight = 48.0;

  /// 40px - Small input field height
  static const double inputHeightSM = 40.0;

  /// 56px - Large input field height
  static const double inputHeightLG = 56.0;

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  /// Bottom navigation bar height
  static const double bottomNavHeight = 64.0;

  /// Bottom nav icon size
  static const double bottomNavIconSize = 24.0;

  /// Floating bottom nav margin
  static const double bottomNavMargin = 16.0;

  /// Bottom nav border radius
  static const double bottomNavRadius = 24.0;

  /// App bar height
  static const double appBarHeight = 56.0;

  /// App bar elevation
  static const double appBarElevation = 0.0;

  /// Large app bar height (for collapsible headers)
  static const double appBarHeightLarge = 120.0;

  // ============================================================================
  // FLAG DIMENSIONS
  // ============================================================================

  /// 32px - Small flag width
  static const double flagWidthSM = 32.0;

  /// 48px - Medium flag width
  static const double flagWidthMD = 48.0;

  /// 80px - Large flag width
  static const double flagWidthLG = 80.0;

  /// 120px - Extra large flag width
  static const double flagWidthXL = 120.0;

  /// 200px - Hero flag width
  static const double flagWidthHero = 200.0;

  // Legacy aliases
  static const double flagWidthS = flagWidthSM;
  static const double flagWidthM = flagWidthMD;
  static const double flagWidthL = flagWidthLG;

  /// Flag aspect ratio (3:2)
  static const double flagAspectRatio = 3 / 2;

  // ============================================================================
  // QUIZ DIMENSIONS
  // ============================================================================

  /// Quiz option card height
  static const double quizOptionHeight = 56.0;

  /// Quiz timer display size
  static const double quizTimerSize = 64.0;

  /// Quiz progress bar height
  static const double quizProgressHeight = 6.0;

  /// Quiz lives icon size
  static const double quizLivesSize = 28.0;

  /// Question card min height
  static const double quizQuestionMinHeight = 120.0;

  // ============================================================================
  // QUIZ RESULT DIMENSIONS
  // ============================================================================

  /// Result icon container size (circle)
  static const double resultIconContainerSize = 120.0;

  /// Result icon size (inside container)
  static const double resultIconSize = 60.0;

  // ============================================================================
  // PROGRESS INDICATORS
  // ============================================================================

  /// Standard progress bar height
  static const double progressBarHeight = 8.0;

  /// Thin progress bar height
  static const double progressBarHeightThin = 4.0;

  /// Thick progress bar height
  static const double progressBarHeightThick = 12.0;

  /// Progress ring size (small)
  static const double progressRingSM = 40.0;

  /// Progress ring size (medium)
  static const double progressRingMD = 64.0;

  /// Progress ring size (large)
  static const double progressRingLG = 96.0;

  /// Progress ring stroke width
  static const double progressRingStroke = 4.0;

  // ============================================================================
  // MAP DIMENSIONS
  // ============================================================================

  /// Default map zoom level
  static const double mapZoomDefault = 4.0;

  /// Country detail zoom level
  static const double mapZoomCountry = 6.0;

  /// Map marker size
  static const double mapMarkerSize = 40.0;

  /// Map control button size
  static const double mapControlSize = 44.0;

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================

  /// Country card height (grid view)
  static const double countryCardHeight = 160.0;

  /// Country card height (list view)
  static const double countryCardListHeight = 80.0;

  /// Feature card height
  static const double featureCardHeight = 200.0;

  /// Stat card size
  static const double statCardSize = 100.0;

  /// Achievement badge size
  static const double achievementBadgeSM = 48.0;
  static const double achievementBadgeMD = 64.0;
  static const double achievementBadgeLG = 96.0;

  // Legacy aliases
  static const double badgeSizeS = achievementBadgeSM;
  static const double badgeSizeM = achievementBadgeMD;
  static const double badgeSizeL = achievementBadgeLG;

  // ============================================================================
  // GAMIFICATION DIMENSIONS
  // ============================================================================

  /// Streak flame icon size
  static const double streakFlameSize = 32.0;

  /// XP badge size
  static const double xpBadgeSize = 24.0;

  /// Level badge size
  static const double levelBadgeSize = 48.0;

  /// Leaderboard avatar size
  static const double leaderboardAvatarSize = 40.0;

  /// Podium height multiplier
  static const double podiumHeightMultiplier = 1.5;

  // ============================================================================
  // ANIMATION DURATIONS (in milliseconds)
  // ============================================================================

  /// 100ms - Ultra fast (micro-interactions)
  static const int animationUltraFast = 100;

  /// 150ms - Fast (button presses)
  static const int animationFast = 150;

  /// 200ms - Normal (standard transitions)
  static const int animationNormal = 200;

  /// 300ms - Medium (dialogs, complex animations)
  static const int animationMedium = 300;

  /// 400ms - Slow (emphasis animations)
  static const int animationSlow = 400;

  /// 500ms - Extra slow (dramatic effects)
  static const int animationExtraSlow = 500;

  /// 800ms - Very slow (celebrations)
  static const int animationVerySlow = 800;

  // Legacy aliases
  static const int animationDurationFast = animationNormal;
  static const int animationDurationMedium = animationMedium;
  static const int animationDurationSlow = animationExtraSlow;

  // Duration objects
  static const Duration durationUltraFast = Duration(milliseconds: animationUltraFast);
  static const Duration durationFast = Duration(milliseconds: animationFast);
  static const Duration durationNormal = Duration(milliseconds: animationNormal);
  static const Duration durationMedium = Duration(milliseconds: animationMedium);
  static const Duration durationSlow = Duration(milliseconds: animationSlow);
  static const Duration durationExtraSlow = Duration(milliseconds: animationExtraSlow);
  static const Duration durationVerySlow = Duration(milliseconds: animationVerySlow);

  // ============================================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================================

  /// Mobile breakpoint (< 600px)
  static const double mobileBreakpoint = 600.0;

  /// Tablet breakpoint (600px - 900px)
  static const double tabletBreakpoint = 900.0;

  /// Desktop breakpoint (> 1200px)
  static const double desktopBreakpoint = 1200.0;

  // ============================================================================
  // GRID SYSTEM
  // ============================================================================

  /// Grid spacing (gap between items)
  static const double gridSpacing = md;

  /// Grid columns on mobile
  static const int gridColumnsMobile = 2;

  /// Grid columns on tablet
  static const int gridColumnsTablet = 3;

  /// Grid columns on desktop
  static const int gridColumnsDesktop = 4;

  // ============================================================================
  // SHIMMER/SKELETON LOADING
  // ============================================================================

  /// Shimmer base opacity
  static const double shimmerBaseOpacity = 0.3;

  /// Shimmer highlight opacity
  static const double shimmerHighlightOpacity = 0.6;

  /// Skeleton border radius
  static const double shimmerRadius = radiusSM;

  // ============================================================================
  // DIVIDERS
  // ============================================================================

  /// Thin divider
  static const double dividerThin = 0.5;

  /// Standard divider
  static const double dividerStandard = 1.0;

  /// Thick divider
  static const double dividerThick = 2.0;

  // ============================================================================
  // BLUR VALUES
  // ============================================================================

  /// Light blur (glass effect)
  static const double blurLight = 8.0;

  /// Medium blur
  static const double blurMedium = 16.0;

  /// Heavy blur
  static const double blurHeavy = 24.0;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get responsive grid column count
  static int getGridColumns(double screenWidth) {
    if (screenWidth >= desktopBreakpoint) return gridColumnsDesktop;
    if (screenWidth >= tabletBreakpoint) return gridColumnsTablet;
    return gridColumnsMobile;
  }

  /// Check if screen is mobile
  static bool isMobile(double screenWidth) => screenWidth < mobileBreakpoint;

  /// Check if screen is tablet
  static bool isTablet(double screenWidth) =>
      screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;

  /// Check if screen is desktop
  static bool isDesktop(double screenWidth) => screenWidth >= desktopBreakpoint;

  /// Get responsive horizontal padding
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth >= desktopBreakpoint) return xl;
    if (screenWidth >= tabletBreakpoint) return lg;
    return md;
  }
}
