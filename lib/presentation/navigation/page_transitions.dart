import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';

/// Custom page transitions for Explorer's Journey theme
///
/// Provides smooth, themed transitions between screens:
/// - Slide + fade for drill-down navigation
/// - Zoom + fade for feature screens
/// - Bottom sheet style for modals

/// Slide up transition (for detail screens, drill-down)
class SlideUpTransitionPage<T> extends CustomTransitionPage<T> {
  SlideUpTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.durationMedium,
          reverseTransitionDuration: AppDimensions.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

/// Slide horizontal transition (for peer-level navigation)
class SlideHorizontalTransitionPage<T> extends CustomTransitionPage<T> {
  SlideHorizontalTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
    bool reverse = false,
  }) : super(
          transitionDuration: AppDimensions.durationMedium,
          reverseTransitionDuration: AppDimensions.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final beginOffset = reverse
                ? const Offset(-0.15, 0)
                : const Offset(0.15, 0);

            return SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Zoom + fade transition (for feature screens like quiz, achievements)
class ZoomFadeTransitionPage<T> extends CustomTransitionPage<T> {
  ZoomFadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.durationMedium,
          reverseTransitionDuration: AppDimensions.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeInCubic,
            );

            return ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Modal/bottom sheet style transition
class ModalTransitionPage<T> extends CustomTransitionPage<T> {
  ModalTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.durationMedium,
          reverseTransitionDuration: AppDimensions.durationFast,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
}

/// Fade-only transition (subtle, for same-level content changes)
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.durationFast,
          reverseTransitionDuration: AppDimensions.durationFast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
}

/// Shared axis transition (Material Design 3 style)
/// Used for related content that shares a spatial relationship
class SharedAxisTransitionPage<T> extends CustomTransitionPage<T> {
  SharedAxisTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
          transitionDuration: AppDimensions.durationMedium,
          reverseTransitionDuration: AppDimensions.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return _SharedAxisTransition(
              animation: curvedAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );

  final SharedAxisTransitionType transitionType;
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Offset beginOffset;

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        beginOffset = const Offset(0.1, 0);
      case SharedAxisTransitionType.vertical:
        beginOffset = const Offset(0, 0.1);
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Hero-enabled page for shared element transitions
/// Used primarily for country card → country detail transitions
class HeroTransitionPage<T> extends CustomTransitionPage<T> {
  HeroTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.durationSlow,
          reverseTransitionDuration: AppDimensions.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: curvedAnimation,
                  curve: const Interval(0.0, 0.5),
                ),
              ),
              child: child,
            );
          },
        );
}

/// Extension methods for easy page creation in routes
extension GoRouterPageExtensions on Widget {
  /// Create a slide up transition page
  CustomTransitionPage<void> slideUpPage({String? name, Object? arguments}) {
    return SlideUpTransitionPage(
      child: this,
      name: name,
      arguments: arguments,
    );
  }

  /// Create a zoom fade transition page
  CustomTransitionPage<void> zoomFadePage({String? name, Object? arguments}) {
    return ZoomFadeTransitionPage(
      child: this,
      name: name,
      arguments: arguments,
    );
  }

  /// Create a fade transition page
  CustomTransitionPage<void> fadePage({String? name, Object? arguments}) {
    return FadeTransitionPage(
      child: this,
      name: name,
      arguments: arguments,
    );
  }

  /// Create a hero-enabled transition page
  CustomTransitionPage<void> heroPage({String? name, Object? arguments}) {
    return HeroTransitionPage(
      child: this,
      name: name,
      arguments: arguments,
    );
  }
}
