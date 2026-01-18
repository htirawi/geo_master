import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Main theme configuration for the app
class AppTheme {
  AppTheme({required this.isArabic});

  final bool isArabic;

  /// Light theme
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
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(Brightness.light),
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
      sliderTheme: _sliderTheme,
      tabBarTheme: _tabBarTheme(Brightness.light, textTheme),
      floatingActionButtonTheme: _fabTheme,
      listTileTheme: _listTileTheme(Brightness.light),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: AppDimensions.iconM,
      ),
      extensions: const [
        _lightCustomColors,
      ],
    );
  }

  /// Dark theme
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
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      chipTheme: _chipTheme(Brightness.dark),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.dividerDark,
      ),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme(Brightness.dark, textTheme),
      bottomSheetTheme: _bottomSheetTheme(Brightness.dark),
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme,
      tabBarTheme: _tabBarTheme(Brightness.dark, textTheme),
      floatingActionButtonTheme: _fabTheme,
      listTileTheme: _listTileTheme(Brightness.dark),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppDimensions.iconM,
      ),
      extensions: const [
        _darkCustomColors,
      ],
    );
  }

  // Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.dividerLight,
    outline: AppColors.dividerLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.secondaryDark,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.secondaryLight,
    error: AppColors.errorLight,
    onError: AppColors.error,
    errorContainer: AppColors.error,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.dividerDark,
    outline: AppColors.dividerDark,
  );

  // App Bar Theme
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
      ),
      iconTheme: IconThemeData(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      ),
      systemOverlayStyle: isLight
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  // Card Theme
  CardThemeData _cardTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return CardThemeData(
      elevation: AppDimensions.cardElevation,
      color: isLight ? AppColors.cardLight : AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingS),
    );
  }

  // Elevated Button Theme
  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Outlined Button Theme
  OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Text Button Theme
  TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Input Decoration Theme
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
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: TextStyle(
        color: isLight ? AppColors.textHintLight : AppColors.textHintDark,
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    );
  }

  // Bottom Navigation Bar Theme
  BottomNavigationBarThemeData _bottomNavigationBarTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor:
          isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      selectedIconTheme: const IconThemeData(size: AppDimensions.iconM),
      unselectedIconTheme: const IconThemeData(size: AppDimensions.iconM),
      showUnselectedLabels: true,
      elevation: 8,
    );
  }

  // Chip Theme
  ChipThemeData _chipTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ChipThemeData(
      backgroundColor: isLight ? AppColors.cardLight : AppColors.cardDark,
      selectedColor: AppColors.primaryLight,
      disabledColor: isLight ? AppColors.dividerLight : AppColors.dividerDark,
      labelStyle: TextStyle(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      ),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
    );
  }

  // Snack Bar Theme
  SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: const TextStyle(color: Colors.white),
    );
  }

  // Dialog Theme
  DialogThemeData _dialogTheme(Brightness brightness, TextTheme textTheme) {
    final isLight = brightness == Brightness.light;
    return DialogThemeData(
      backgroundColor: isLight ? AppColors.cardLight : AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      ),
    );
  }

  // Bottom Sheet Theme
  BottomSheetThemeData _bottomSheetTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return BottomSheetThemeData(
      backgroundColor: isLight ? AppColors.cardLight : AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
    );
  }

  // Switch Theme
  SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondaryLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.dividerLight;
      }),
    );
  }

  // Checkbox Theme
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
    );
  }

  // Radio Theme
  RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondaryLight;
      }),
    );
  }

  // Slider Theme
  SliderThemeData get _sliderTheme {
    return const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.dividerLight,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primaryLight,
    );
  }

  // Tab Bar Theme
  TabBarThemeData _tabBarTheme(Brightness brightness, TextTheme textTheme) {
    final isLight = brightness == Brightness.light;
    return TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor:
          isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // Floating Action Button Theme
  FloatingActionButtonThemeData get _fabTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    );
  }

  // List Tile Theme
  ListTileThemeData _listTileTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingXS,
      ),
      iconColor:
          isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      textColor:
          isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
    );
  }

  // Custom Colors Extension
  static const CustomColors _lightCustomColors = CustomColors(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    xpGold: AppColors.xpGold,
    streak: AppColors.streak,
    achievement: AppColors.achievement,
    premium: AppColors.premiumGold,
    regionAfrica: AppColors.regionAfrica,
    regionAsia: AppColors.regionAsia,
    regionEurope: AppColors.regionEurope,
    regionNorthAmerica: AppColors.regionNorthAmerica,
    regionSouthAmerica: AppColors.regionSouthAmerica,
    regionOceania: AppColors.regionOceania,
  );

  static const CustomColors _darkCustomColors = CustomColors(
    success: AppColors.successLight,
    warning: AppColors.warningLight,
    info: AppColors.infoLight,
    xpGold: AppColors.xpGold,
    streak: AppColors.streak,
    achievement: AppColors.achievement,
    premium: AppColors.premiumGold,
    regionAfrica: AppColors.regionAfrica,
    regionAsia: AppColors.regionAsia,
    regionEurope: AppColors.regionEurope,
    regionNorthAmerica: AppColors.regionNorthAmerica,
    regionSouthAmerica: AppColors.regionSouthAmerica,
    regionOceania: AppColors.regionOceania,
  );
}

/// Custom color extension for app-specific colors
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.xpGold,
    required this.streak,
    required this.achievement,
    required this.premium,
    required this.regionAfrica,
    required this.regionAsia,
    required this.regionEurope,
    required this.regionNorthAmerica,
    required this.regionSouthAmerica,
    required this.regionOceania,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color xpGold;
  final Color streak;
  final Color achievement;
  final Color premium;
  final Color regionAfrica;
  final Color regionAsia;
  final Color regionEurope;
  final Color regionNorthAmerica;
  final Color regionSouthAmerica;
  final Color regionOceania;

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? xpGold,
    Color? streak,
    Color? achievement,
    Color? premium,
    Color? regionAfrica,
    Color? regionAsia,
    Color? regionEurope,
    Color? regionNorthAmerica,
    Color? regionSouthAmerica,
    Color? regionOceania,
  }) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      xpGold: xpGold ?? this.xpGold,
      streak: streak ?? this.streak,
      achievement: achievement ?? this.achievement,
      premium: premium ?? this.premium,
      regionAfrica: regionAfrica ?? this.regionAfrica,
      regionAsia: regionAsia ?? this.regionAsia,
      regionEurope: regionEurope ?? this.regionEurope,
      regionNorthAmerica: regionNorthAmerica ?? this.regionNorthAmerica,
      regionSouthAmerica: regionSouthAmerica ?? this.regionSouthAmerica,
      regionOceania: regionOceania ?? this.regionOceania,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      xpGold: Color.lerp(xpGold, other.xpGold, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      achievement: Color.lerp(achievement, other.achievement, t)!,
      premium: Color.lerp(premium, other.premium, t)!,
      regionAfrica: Color.lerp(regionAfrica, other.regionAfrica, t)!,
      regionAsia: Color.lerp(regionAsia, other.regionAsia, t)!,
      regionEurope: Color.lerp(regionEurope, other.regionEurope, t)!,
      regionNorthAmerica:
          Color.lerp(regionNorthAmerica, other.regionNorthAmerica, t)!,
      regionSouthAmerica:
          Color.lerp(regionSouthAmerica, other.regionSouthAmerica, t)!,
      regionOceania: Color.lerp(regionOceania, other.regionOceania, t)!,
    );
  }
}

/// Extension to get custom colors from context
extension CustomColorsExtension on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>() ??
      const CustomColors(
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
        xpGold: AppColors.xpGold,
        streak: AppColors.streak,
        achievement: AppColors.achievement,
        premium: AppColors.premiumGold,
        regionAfrica: AppColors.regionAfrica,
        regionAsia: AppColors.regionAsia,
        regionEurope: AppColors.regionEurope,
        regionNorthAmerica: AppColors.regionNorthAmerica,
        regionSouthAmerica: AppColors.regionSouthAmerica,
        regionOceania: AppColors.regionOceania,
      );
}
