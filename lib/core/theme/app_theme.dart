import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Explorer's Journey Theme Configuration
///
/// Main theme configuration implementing the "Cartographer's Ink" design system.
/// Supports both light and dark modes with locale-aware typography.
class AppTheme {
  AppTheme({required this.isArabic});

  final bool isArabic;

  /// Light theme - Explorer's Day
  ThemeData get lightTheme {
    final textTheme = AppTypography.getTextTheme(isArabic: isArabic);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: _appBarTheme(Brightness.light, textTheme),
      cardTheme: _cardTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.light),
      textButtonTheme: _textButtonTheme,
      filledButtonTheme: _filledButtonTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(Brightness.light),
      navigationBarTheme: _navigationBarTheme(Brightness.light),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      chipTheme: _chipTheme(Brightness.light),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.dividerLight,
      ),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme(Brightness.light, textTheme),
      bottomSheetTheme: _bottomSheetTheme(Brightness.light),
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme(Brightness.light),
      tabBarTheme: _tabBarTheme(Brightness.light, textTheme),
      floatingActionButtonTheme: _fabTheme,
      listTileTheme: _listTileTheme(Brightness.light),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: AppDimensions.iconMD,
      ),
      extensions: const [
        _lightCustomColors,
      ],
    );
  }

  /// Dark theme - Explorer's Night
  ThemeData get darkTheme {
    final textTheme = AppTypography.getTextTheme(isArabic: isArabic);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: _appBarTheme(Brightness.dark, textTheme),
      cardTheme: _cardTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.dark),
      textButtonTheme: _textButtonTheme,
      filledButtonTheme: _filledButtonTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(Brightness.dark),
      navigationBarTheme: _navigationBarTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      chipTheme: _chipTheme(Brightness.dark),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.dividerDark,
      ),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme(Brightness.dark, textTheme),
      bottomSheetTheme: _bottomSheetTheme(Brightness.dark),
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme(Brightness.dark),
      tabBarTheme: _tabBarTheme(Brightness.dark, textTheme),
      floatingActionButtonTheme: _fabTheme,
      listTileTheme: _listTileTheme(Brightness.dark),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppDimensions.iconMD,
      ),
      extensions: const [
        _darkCustomColors,
      ],
    );
  }

  // ============================================================================
  // COLOR SCHEMES
  // ============================================================================

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    // Primary - Cartographer's Navy
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.primaryDark,

    // Secondary - Treasure Gold
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.accentSurface,
    onSecondaryContainer: AppColors.accentDark,

    // Tertiary - Ocean
    tertiary: AppColors.oceanMid,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.oceanSurface,
    onTertiaryContainer: AppColors.oceanDeep,

    // Error
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.errorDark,

    // Surface & Background
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.dividerLight,
    outline: AppColors.dividerLight,
    outlineVariant: AppColors.mountainSnow,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    // Primary - Lighter for dark mode
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.primarySurface,

    // Secondary - Treasure Gold
    secondary: AppColors.accentLight,
    onSecondary: AppColors.accentDark,
    secondaryContainer: AppColors.accent,
    onSecondaryContainer: AppColors.accentSurface,

    // Tertiary - Ocean
    tertiary: AppColors.oceanShallow,
    onTertiary: AppColors.oceanDeep,
    tertiaryContainer: AppColors.oceanMid,
    onTertiaryContainer: AppColors.oceanSurface,

    // Error
    error: AppColors.errorLight,
    onError: AppColors.errorDark,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.errorSurface,

    // Surface & Background
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.dividerDark,
    outline: AppColors.dividerDark,
    outlineVariant: AppColors.mountainPeak,
  );

  // ============================================================================
  // APP BAR THEME
  // ============================================================================

  AppBarTheme _appBarTheme(Brightness brightness, TextTheme textTheme) {
    final isLight = brightness == Brightness.light;
    return AppBarTheme(
      elevation: AppDimensions.appBarElevation,
      scrolledUnderElevation: 0,
      backgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      foregroundColor:
          isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        size: AppDimensions.iconMD,
      ),
      actionsIconTheme: IconThemeData(
        color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        size: AppDimensions.iconMD,
      ),
      systemOverlayStyle: isLight
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  // ============================================================================
  // CARD THEME
  // ============================================================================

  CardThemeData _cardTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return CardThemeData(
      elevation: AppDimensions.elevation1,
      color: isLight ? AppColors.cardLight : AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      margin: const EdgeInsets.all(AppDimensions.xs),
    );
  }

  // ============================================================================
  // BUTTON THEMES
  // ============================================================================

  ElevatedButtonThemeData _elevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMD),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.mountainStone.withValues(alpha: 0.3),
        disabledForegroundColor: AppColors.mountainPeak,
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  OutlinedButtonThemeData _outlinedButtonTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMD),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        side: BorderSide(
          color: isLight ? AppColors.primary : AppColors.primaryLight,
          width: 1.5,
        ),
        foregroundColor: isLight ? AppColors.primary : AppColors.primaryLight,
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.buttonTextSmall,
      ),
    );
  }

  FilledButtonThemeData _filledButtonTheme(Brightness brightness) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMD),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  // ============================================================================
  // INPUT DECORATION THEME
  // ============================================================================

  InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final borderColor =
        isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final fillColor =
        isLight ? AppColors.surfaceLight : AppColors.surfaceDark;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
      ),
      hintStyle: TextStyle(
        color: isLight ? AppColors.textHintLight : AppColors.textHintDark,
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(color: AppColors.error),
      prefixIconColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      suffixIconColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
    );
  }

  // ============================================================================
  // NAVIGATION THEMES
  // ============================================================================

  BottomNavigationBarThemeData _bottomNavigationBarTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor:
          isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
      selectedIconTheme: const IconThemeData(size: AppDimensions.iconMD),
      unselectedIconTheme: const IconThemeData(size: AppDimensions.iconMD),
      selectedLabelStyle: AppTypography.navLabel.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTypography.navLabel,
      showUnselectedLabels: true,
      elevation: 8,
    );
  }

  NavigationBarThemeData _navigationBarTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return NavigationBarThemeData(
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.primary,
            size: AppDimensions.iconMD,
          );
        }
        return IconThemeData(
          color: isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
          size: AppDimensions.iconMD,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.navLabel.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.navLabel.copyWith(
          color: isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
        );
      }),
      height: AppDimensions.bottomNavHeight,
      elevation: 0,
    );
  }

  // ============================================================================
  // CHIP THEME
  // ============================================================================

  ChipThemeData _chipTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ChipThemeData(
      backgroundColor: isLight
          ? AppColors.mountainSnow
          : AppColors.surfaceDark,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      disabledColor: isLight ? AppColors.dividerLight : AppColors.dividerDark,
      labelStyle: AppTypography.chipLabel.copyWith(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      ),
      secondaryLabelStyle: AppTypography.chipLabel.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide.none,
    );
  }

  // ============================================================================
  // SNACK BAR THEME
  // ============================================================================

  SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: AppColors.accent,
      insetPadding: const EdgeInsets.all(AppDimensions.md),
    );
  }

  // ============================================================================
  // DIALOG THEME
  // ============================================================================

  DialogThemeData _dialogTheme(Brightness brightness, TextTheme textTheme) {
    final isLight = brightness == Brightness.light;
    return DialogThemeData(
      backgroundColor: isLight ? AppColors.cardLight : AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      ),
    );
  }

  // ============================================================================
  // BOTTOM SHEET THEME
  // ============================================================================

  BottomSheetThemeData _bottomSheetTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return BottomSheetThemeData(
      backgroundColor: isLight ? AppColors.cardLight : AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      dragHandleColor: isLight ? AppColors.dividerLight : AppColors.dividerDark,
      dragHandleSize: const Size(40, 4),
    );
  }

  // ============================================================================
  // SWITCH THEME
  // ============================================================================

  SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.mountainStone;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withValues(alpha: 0.3);
        }
        return AppColors.dividerLight;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        return Colors.transparent;
      }),
    );
  }

  // ============================================================================
  // CHECKBOX THEME
  // ============================================================================

  CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      side: const BorderSide(color: AppColors.mountainStone, width: 1.5),
    );
  }

  // ============================================================================
  // RADIO THEME
  // ============================================================================

  RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.mountainStone;
      }),
    );
  }

  // ============================================================================
  // SLIDER THEME
  // ============================================================================

  SliderThemeData _sliderTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: isLight ? AppColors.dividerLight : AppColors.dividerDark,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    );
  }

  // ============================================================================
  // TAB BAR THEME
  // ============================================================================

  TabBarThemeData _tabBarTheme(Brightness brightness, TextTheme textTheme) {
    final isLight = brightness == Brightness.light;
    return TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor:
          isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.labelLarge,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    );
  }

  // ============================================================================
  // FAB THEME
  // ============================================================================

  FloatingActionButtonThemeData get _fabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: AppDimensions.elevation2,
      highlightElevation: AppDimensions.elevation3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
    );
  }

  // ============================================================================
  // LIST TILE THEME
  // ============================================================================

  ListTileThemeData _listTileTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xxs,
      ),
      iconColor:
          isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      textColor:
          isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
    );
  }

  // ============================================================================
  // CUSTOM COLORS EXTENSION
  // ============================================================================

  static const CustomColors _lightCustomColors = CustomColors(
    // Semantic
    success: AppColors.success,
    successSurface: AppColors.successSurface,
    warning: AppColors.warning,
    warningSurface: AppColors.warningSurface,
    info: AppColors.info,
    infoSurface: AppColors.infoSurface,

    // Gamification
    xpGold: AppColors.xpGold,
    streak: AppColors.streak,
    achievement: AppColors.achievement,
    levelUp: AppColors.levelUp,

    // Premium
    premium: AppColors.premiumGold,
    premiumSurface: AppColors.premiumSurface,

    // Continents
    africa: AppColors.africa,
    asia: AppColors.asia,
    europe: AppColors.europe,
    northAmerica: AppColors.northAmerica,
    southAmerica: AppColors.southAmerica,
    oceania: AppColors.oceania,
    antarctica: AppColors.antarctica,

    // Quiz
    quizCorrect: AppColors.quizCorrect,
    quizIncorrect: AppColors.quizIncorrect,

    // Natural world
    oceanMid: AppColors.oceanMid,
    forestLight: AppColors.forestLight,
    desertWarm: AppColors.desertWarm,
    mountainStone: AppColors.mountainStone,
  );

  static const CustomColors _darkCustomColors = CustomColors(
    // Semantic
    success: AppColors.successLight,
    successSurface: AppColors.successDark,
    warning: AppColors.warningLight,
    warningSurface: AppColors.warningDark,
    info: AppColors.infoLight,
    infoSurface: AppColors.infoDark,

    // Gamification
    xpGold: AppColors.xpGold,
    streak: AppColors.streak,
    achievement: AppColors.achievementLight,
    levelUp: AppColors.levelUpLight,

    // Premium
    premium: AppColors.premiumGold,
    premiumSurface: AppColors.premiumPurple,

    // Continents
    africa: AppColors.africa,
    asia: AppColors.asia,
    europe: AppColors.europe,
    northAmerica: AppColors.northAmerica,
    southAmerica: AppColors.southAmerica,
    oceania: AppColors.oceania,
    antarctica: AppColors.antarctica,

    // Quiz
    quizCorrect: AppColors.successLight,
    quizIncorrect: AppColors.errorLight,

    // Natural world
    oceanMid: AppColors.oceanShallow,
    forestLight: AppColors.forestMoss,
    desertWarm: AppColors.desertDusk,
    mountainStone: AppColors.mountainSnow,
  );
}

/// Custom color extension for app-specific colors
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    // Semantic
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
    required this.infoSurface,

    // Gamification
    required this.xpGold,
    required this.streak,
    required this.achievement,
    required this.levelUp,

    // Premium
    required this.premium,
    required this.premiumSurface,

    // Continents
    required this.africa,
    required this.asia,
    required this.europe,
    required this.northAmerica,
    required this.southAmerica,
    required this.oceania,
    required this.antarctica,

    // Quiz
    required this.quizCorrect,
    required this.quizIncorrect,

    // Natural world
    required this.oceanMid,
    required this.forestLight,
    required this.desertWarm,
    required this.mountainStone,
  });

  // Semantic colors
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color info;
  final Color infoSurface;

  // Gamification colors
  final Color xpGold;
  final Color streak;
  final Color achievement;
  final Color levelUp;

  // Premium colors
  final Color premium;
  final Color premiumSurface;

  // Continent colors
  final Color africa;
  final Color asia;
  final Color europe;
  final Color northAmerica;
  final Color southAmerica;
  final Color oceania;
  final Color antarctica;

  // Quiz colors
  final Color quizCorrect;
  final Color quizIncorrect;

  // Natural world colors
  final Color oceanMid;
  final Color forestLight;
  final Color desertWarm;
  final Color mountainStone;

  // Legacy aliases for backwards compatibility
  Color get regionAfrica => africa;
  Color get regionAsia => asia;
  Color get regionEurope => europe;
  Color get regionNorthAmerica => northAmerica;
  Color get regionSouthAmerica => southAmerica;
  Color get regionOceania => oceania;

  /// Get continent color by name
  Color getContinentColor(String continent) {
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
        return AppColors.primary;
    }
  }

  @override
  CustomColors copyWith({
    Color? success,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
    Color? infoSurface,
    Color? xpGold,
    Color? streak,
    Color? achievement,
    Color? levelUp,
    Color? premium,
    Color? premiumSurface,
    Color? africa,
    Color? asia,
    Color? europe,
    Color? northAmerica,
    Color? southAmerica,
    Color? oceania,
    Color? antarctica,
    Color? quizCorrect,
    Color? quizIncorrect,
    Color? oceanMid,
    Color? forestLight,
    Color? desertWarm,
    Color? mountainStone,
  }) {
    return CustomColors(
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      xpGold: xpGold ?? this.xpGold,
      streak: streak ?? this.streak,
      achievement: achievement ?? this.achievement,
      levelUp: levelUp ?? this.levelUp,
      premium: premium ?? this.premium,
      premiumSurface: premiumSurface ?? this.premiumSurface,
      africa: africa ?? this.africa,
      asia: asia ?? this.asia,
      europe: europe ?? this.europe,
      northAmerica: northAmerica ?? this.northAmerica,
      southAmerica: southAmerica ?? this.southAmerica,
      oceania: oceania ?? this.oceania,
      antarctica: antarctica ?? this.antarctica,
      quizCorrect: quizCorrect ?? this.quizCorrect,
      quizIncorrect: quizIncorrect ?? this.quizIncorrect,
      oceanMid: oceanMid ?? this.oceanMid,
      forestLight: forestLight ?? this.forestLight,
      desertWarm: desertWarm ?? this.desertWarm,
      mountainStone: mountainStone ?? this.mountainStone,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      xpGold: Color.lerp(xpGold, other.xpGold, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      achievement: Color.lerp(achievement, other.achievement, t)!,
      levelUp: Color.lerp(levelUp, other.levelUp, t)!,
      premium: Color.lerp(premium, other.premium, t)!,
      premiumSurface: Color.lerp(premiumSurface, other.premiumSurface, t)!,
      africa: Color.lerp(africa, other.africa, t)!,
      asia: Color.lerp(asia, other.asia, t)!,
      europe: Color.lerp(europe, other.europe, t)!,
      northAmerica: Color.lerp(northAmerica, other.northAmerica, t)!,
      southAmerica: Color.lerp(southAmerica, other.southAmerica, t)!,
      oceania: Color.lerp(oceania, other.oceania, t)!,
      antarctica: Color.lerp(antarctica, other.antarctica, t)!,
      quizCorrect: Color.lerp(quizCorrect, other.quizCorrect, t)!,
      quizIncorrect: Color.lerp(quizIncorrect, other.quizIncorrect, t)!,
      oceanMid: Color.lerp(oceanMid, other.oceanMid, t)!,
      forestLight: Color.lerp(forestLight, other.forestLight, t)!,
      desertWarm: Color.lerp(desertWarm, other.desertWarm, t)!,
      mountainStone: Color.lerp(mountainStone, other.mountainStone, t)!,
    );
  }
}

/// Extension to get custom colors from context
extension CustomColorsExtension on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>() ??
      const CustomColors(
        success: AppColors.success,
        successSurface: AppColors.successSurface,
        warning: AppColors.warning,
        warningSurface: AppColors.warningSurface,
        info: AppColors.info,
        infoSurface: AppColors.infoSurface,
        xpGold: AppColors.xpGold,
        streak: AppColors.streak,
        achievement: AppColors.achievement,
        levelUp: AppColors.levelUp,
        premium: AppColors.premiumGold,
        premiumSurface: AppColors.premiumSurface,
        africa: AppColors.africa,
        asia: AppColors.asia,
        europe: AppColors.europe,
        northAmerica: AppColors.northAmerica,
        southAmerica: AppColors.southAmerica,
        oceania: AppColors.oceania,
        antarctica: AppColors.antarctica,
        quizCorrect: AppColors.quizCorrect,
        quizIncorrect: AppColors.quizIncorrect,
        oceanMid: AppColors.oceanMid,
        forestLight: AppColors.forestLight,
        desertWarm: AppColors.desertWarm,
        mountainStone: AppColors.mountainStone,
      );
}
