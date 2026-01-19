import 'package:flutter/material.dart';

/// Centralized animation constants for consistent animations throughout the app
class AnimationConstants {
  AnimationConstants._();

  // ============ Standard Durations ============

  /// Ultra fast - for micro-interactions (ripples, icon toggles)
  static const Duration ultraFast = Duration(milliseconds: 100);

  /// Fast - for quick UI feedback (button presses, chip selections)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal - for standard transitions (page elements, cards)
  static const Duration normal = Duration(milliseconds: 200);

  /// Medium - for more noticeable animations (dialogs, modals)
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow - for emphasis animations (onboarding, celebrations)
  static const Duration slow = Duration(milliseconds: 400);

  /// Extra slow - for dramatic effect (splash, loading)
  static const Duration extraSlow = Duration(milliseconds: 500);

  // ============ Page Transitions ============

  /// Default page transition duration
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// Modal/dialog transition duration
  static const Duration modalTransition = Duration(milliseconds: 250);

  // ============ Background/Ambient Animations ============

  /// Subtle ambient animation (floating elements)
  static const Duration ambient = Duration(seconds: 4);

  /// Slow ambient rotation/movement
  static const Duration ambientSlow = Duration(seconds: 10);

  /// Very slow background animations
  static const Duration backgroundSlow = Duration(seconds: 15);

  /// Ultra slow for subtle background effects
  static const Duration backgroundUltraSlow = Duration(seconds: 25);

  // ============ Standard Curves ============

  /// Standard ease-out for most UI animations
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Ease-in-out for symmetric animations
  static const Curve symmetricCurve = Curves.easeInOutCubic;

  /// Bounce effect for playful interactions
  static const Curve bounceCurve = Curves.elasticOut;

  /// Decelerate for elements entering view
  static const Curve enterCurve = Curves.decelerate;

  /// Accelerate for elements leaving view
  static const Curve exitCurve = Curves.easeIn;

  /// Spring-like effect
  static const Curve springCurve = Curves.elasticOut;

  // ============ Stagger Delays ============

  /// Delay between staggered list item animations
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Longer stagger for emphasis
  static const Duration staggerDelayLong = Duration(milliseconds: 100);

  // ============ Repeat Animations ============

  /// Typing indicator animation duration
  static const Duration typingIndicator = Duration(milliseconds: 1500);

  /// Cursor blink duration
  static const Duration cursorBlink = Duration(seconds: 1);

  /// Progress pulse animation
  static const Duration progressPulse = Duration(milliseconds: 1000);

  // ============ Helper Methods ============

  /// Get stagger delay for index in a list
  static Duration getStaggerDelay(int index, {Duration? baseDelay}) {
    return Duration(
      milliseconds: (baseDelay ?? staggerDelay).inMilliseconds * index,
    );
  }

  /// Get fade-in animation for list items
  static Widget fadeInStagger({
    required Widget child,
    required int index,
    Duration? delay,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? normal,
      curve: standardCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
