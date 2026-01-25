import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  Breakpoints._();

  /// Mobile breakpoint (small phones)
  static const double xs = 320;

  /// Mobile breakpoint (standard phones)
  static const double sm = 375;

  /// Large mobile breakpoint
  static const double md = 428;

  /// Tablet breakpoint
  static const double lg = 600;

  /// Large tablet breakpoint
  static const double xl = 900;

  /// Desktop breakpoint
  static const double xxl = 1200;
}

/// Device type based on screen width
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive utility class for adapting layouts
class Responsive {
  Responsive._();

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.xxl) return DeviceType.desktop;
    if (width >= Breakpoints.lg) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Get responsive value based on device type
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Get responsive padding based on screen width
  static double padding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.xxl) return 48;
    if (width >= Breakpoints.xl) return 40;
    if (width >= Breakpoints.lg) return 32;
    if (width >= Breakpoints.md) return 24;
    if (width >= Breakpoints.sm) return 20;
    return 16;
  }

  /// Get responsive font scale factor
  static double fontScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.xxl) return 1.2;
    if (width >= Breakpoints.xl) return 1.15;
    if (width >= Breakpoints.lg) return 1.1;
    return 1.0;
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, {double base = 24}) {
    return base * fontScale(context);
  }

  /// Get maximum content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.xxl) return 1000;
    if (width >= Breakpoints.xl) return 800;
    if (width >= Breakpoints.lg) return 600;
    return width;
  }

  /// Get grid column count based on screen width
  static int gridColumns(BuildContext context, {int mobileColumns = 2}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.xxl) return mobileColumns * 3;
    if (width >= Breakpoints.xl) return mobileColumns * 2 + 1;
    if (width >= Breakpoints.lg) return mobileColumns * 2;
    return mobileColumns;
  }
}

/// Widget that builds different layouts based on device type
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Mobile layout (required)
  final Widget mobile;

  /// Tablet layout (optional, falls back to mobile)
  final Widget? tablet;

  /// Desktop layout (optional, falls back to tablet or mobile)
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.xxl) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Breakpoints.lg) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Widget that centers content with a maximum width
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal,
    this.vertical,
    this.all,
  });

  final Widget child;
  final double? horizontal;
  final double? vertical;
  final double? all;

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.fontScale(context);
    final allPadding = all != null ? all! * scale : null;
    final h = horizontal != null ? horizontal! * scale : null;
    final v = vertical != null ? vertical! * scale : null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: allPadding ?? h ?? Responsive.padding(context),
        vertical: allPadding ?? v ?? 0,
      ),
      child: child,
    );
  }
}

/// Responsive utilities class with scaleFactor-based scaling
///
/// Usage:
/// ```dart
/// final responsive = ResponsiveUtils.of(context);
/// Text('Hello', style: TextStyle(fontSize: responsive.sp(16)));
/// SizedBox(height: responsive.sp(24));
/// EdgeInsets.all(responsive.sp(16));
/// ```
class ResponsiveUtils {
  ResponsiveUtils._(this.context) {
    _screenWidth = MediaQuery.sizeOf(context).width;
    _screenHeight = MediaQuery.sizeOf(context).height;
    // Base width is iPhone 8 (375px) - scales proportionally
    scaleFactor = (_screenWidth / _baseWidth).clamp(0.85, 1.4);
  }

  static const double _baseWidth = 375.0;

  final BuildContext context;
  late final double _screenWidth;
  late final double _screenHeight;
  late final double scaleFactor;

  /// Factory constructor for easy access
  static ResponsiveUtils of(BuildContext context) => ResponsiveUtils._(context);

  /// Screen width
  double get screenWidth => _screenWidth;

  /// Screen height
  double get screenHeight => _screenHeight;

  /// Scaled pixels - use for ALL dimensions (fontSize, padding, margins, etc.)
  /// This ensures consistent proportional scaling across all device sizes
  double sp(double size) => size * scaleFactor;

  /// Width percentage - get percentage of screen width
  double wp(double percentage) => _screenWidth * (percentage / 100);

  /// Height percentage - get percentage of screen height
  double hp(double percentage) => _screenHeight * (percentage / 100);

  /// Check if device is a phone (width < 600)
  bool get isPhone => _screenWidth < 600;

  /// Check if device is a tablet (600 <= width < 1200)
  bool get isTablet => _screenWidth >= 600 && _screenWidth < 1200;

  /// Check if device is desktop (width >= 1200)
  bool get isDesktop => _screenWidth >= 1200;

  /// Check if device is in landscape
  bool get isLandscape => _screenWidth > _screenHeight;

  /// Get responsive grid columns
  int get gridColumns {
    if (_screenWidth >= 1200) return 4;
    if (_screenWidth >= 600) return 3;
    return 2;
  }

  /// Get responsive grid columns with custom mobile count
  int gridColumnsCustom({int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (_screenWidth >= 1200) return desktop;
    if (_screenWidth >= 600) return tablet;
    return mobile;
  }

  /// Get responsive value based on device type
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  /// Scaled EdgeInsets.all
  EdgeInsets insets(double value) => EdgeInsets.all(sp(value));

  /// Scaled EdgeInsets.symmetric
  EdgeInsets insetsSymmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: sp(horizontal),
        vertical: sp(vertical),
      );

  /// Scaled EdgeInsets.only
  EdgeInsets insetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: sp(left),
        top: sp(top),
        right: sp(right),
        bottom: sp(bottom),
      );

  /// Scaled BorderRadius.circular
  BorderRadius radius(double value) => BorderRadius.circular(sp(value));

  /// Scaled SizedBox height
  SizedBox verticalSpace(double height) => SizedBox(height: sp(height));

  /// Scaled SizedBox width
  SizedBox horizontalSpace(double width) => SizedBox(width: sp(width));
}

/// Extension on BuildContext for responsive utilities
extension ResponsiveContextExtension on BuildContext {
  /// Get ResponsiveUtils instance
  ResponsiveUtils get r => ResponsiveUtils.of(this);

  /// Shorthand for sp() scaling
  double sp(double size) => ResponsiveUtils.of(this).sp(size);

  /// Get device type
  DeviceType get deviceType => Responsive.getDeviceType(this);

  /// Get responsive value
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) =>
      Responsive.value(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  /// Get responsive padding
  double get responsivePadding => Responsive.padding(this);

  /// Get font scale factor
  double get fontScale => Responsive.fontScale(this);

  /// Get max content width
  double get maxContentWidth => Responsive.maxContentWidth(this);
}
