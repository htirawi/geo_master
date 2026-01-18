import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

/// Premium glass morphism card with blur effect
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10,
    this.opacity = 0.1,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  /// Light glass card for light backgrounds
  factory GlassCard.light({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      color: Colors.white,
      opacity: 0.7,
      blur: 10,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      onTap: onTap,
      child: child,
    );
  }

  /// Dark glass card for dark backgrounds
  factory GlassCard.dark({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      color: Colors.black,
      opacity: 0.3,
      blur: 15,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      onTap: onTap,
      child: child,
    );
  }

  /// Gradient glass card with custom gradient overlay
  factory GlassCard.gradient({
    required Widget child,
    required Gradient gradient,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      gradient: gradient,
      opacity: 0.15,
      blur: 10,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      onTap: onTap,
      child: child,
    );
  }

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusL);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: gradient == null
                ? (color ?? Colors.white).withValues(alpha: opacity)
                : null,
            gradient: gradient != null
                ? LinearGradient(
                    colors: (gradient as LinearGradient)
                        .colors
                        .map((c) => c.withValues(alpha: opacity))
                        .toList(),
                    begin: (gradient as LinearGradient).begin,
                    end: (gradient as LinearGradient).end,
                  )
                : null,
            border: border,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Animated glass card with hover/press effects
class AnimatedGlassCard extends StatefulWidget {
  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.isDark = false,
  });
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..setEntry(0, 0, _isPressed ? 0.97 : 1.0)
          ..setEntry(1, 1, _isPressed ? 0.97 : 1.0),
        child: widget.isDark
            ? GlassCard.dark(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                margin: widget.margin,
                borderRadius: widget.borderRadius,
                child: widget.child,
              )
            : GlassCard.light(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                margin: widget.margin,
                borderRadius: widget.borderRadius,
                child: widget.child,
              ),
      ),
    );
  }
}
