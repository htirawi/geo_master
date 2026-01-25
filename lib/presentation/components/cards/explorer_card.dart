import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Explorer Card - Versatile card component for the Explorer's Journey theme
///
/// Features:
/// - Multiple variants (elevated, filled, outlined, glass)
/// - Gradient backgrounds
/// - Press animations
/// - Haptic feedback
/// - Custom border radius
/// - Shadow customization
class ExplorerCard extends StatefulWidget {
  const ExplorerCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.variant = ExplorerCardVariant.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.elevation,
    this.shadowColor,
    this.hapticFeedback = true,
    this.animatePress = true,
  });

  /// Elevated card with shadow
  const ExplorerCard.elevated({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = AppDimensions.elevation1,
    this.shadowColor,
    this.hapticFeedback = true,
    this.animatePress = true,
  })  : variant = ExplorerCardVariant.elevated,
        gradient = null,
        border = null;

  /// Filled card with solid background
  const ExplorerCard.filled({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.hapticFeedback = true,
    this.animatePress = true,
  })  : variant = ExplorerCardVariant.filled,
        gradient = null,
        border = null,
        elevation = 0,
        shadowColor = null;

  /// Outlined card with border
  const ExplorerCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.hapticFeedback = true,
    this.animatePress = true,
  })  : variant = ExplorerCardVariant.outlined,
        gradient = null,
        elevation = 0,
        shadowColor = null;

  /// Glass card with blur effect
  const ExplorerCard.glass({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.hapticFeedback = true,
    this.animatePress = true,
  })  : variant = ExplorerCardVariant.glass,
        backgroundColor = null,
        gradient = null,
        border = null,
        elevation = 0,
        shadowColor = null;

  /// Gradient card with custom gradient background
  const ExplorerCard.gradient({
    super.key,
    required this.child,
    required Gradient this.gradient,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.hapticFeedback = true,
    this.animatePress = true,
  })  : variant = ExplorerCardVariant.gradient,
        backgroundColor = null,
        border = null;

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ExplorerCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final double? elevation;
  final Color? shadowColor;
  final bool hapticFeedback;
  final bool animatePress;

  @override
  State<ExplorerCard> createState() => _ExplorerCardState();
}

class _ExplorerCardState extends State<ExplorerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.animatePress && !_reduceMotion) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getCardConfig(isDark);

    Widget card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _reduceMotion ? 1.0 : _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildCard(config),
    );

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    // Only wrap with Semantics if the card is interactive
    if (widget.onTap != null || widget.onLongPress != null) {
      return Semantics(
        button: true,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? _handleTapDown : null,
          onTapUp: widget.onTap != null ? _handleTapUp : null,
          onTapCancel: widget.onTap != null ? _handleTapCancel : null,
          onTap: widget.onTap != null ? _handleTap : null,
          onLongPress: widget.onLongPress,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildCard(_CardConfig config) {
    if (widget.variant == ExplorerCardVariant.glass) {
      return ClipRRect(
        borderRadius: config.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurMedium,
            sigmaY: AppDimensions.blurMedium,
          ),
          child: Container(
            padding: config.padding,
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: config.borderRadius,
              border: Border.all(
                color: AppColors.glassStroke,
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        ),
      );
    }

    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: widget.variant == ExplorerCardVariant.gradient
            ? null
            : config.backgroundColor,
        gradient: widget.gradient,
        borderRadius: config.borderRadius,
        border: config.border,
        boxShadow: config.elevation > 0
            ? [
                BoxShadow(
                  color: config.shadowColor,
                  blurRadius: config.elevation * 2,
                  offset: Offset(0, config.elevation),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );
  }

  _CardConfig _getCardConfig(bool isDark) {
    final borderRadius = widget.borderRadius ??
        BorderRadius.circular(AppDimensions.radiusMD);
    final padding = widget.padding ??
        const EdgeInsets.all(AppDimensions.md);

    Color backgroundColor;
    BoxBorder? border;
    double elevation;
    Color shadowColor;

    switch (widget.variant) {
      case ExplorerCardVariant.elevated:
        backgroundColor = widget.backgroundColor ??
            (isDark ? AppColors.cardDark : AppColors.cardLight);
        border = null;
        elevation = widget.elevation ?? AppDimensions.elevation1;
        shadowColor = widget.shadowColor ??
            AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08);

      case ExplorerCardVariant.filled:
        backgroundColor = widget.backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.mountainSnow);
        border = null;
        elevation = 0;
        shadowColor = Colors.transparent;

      case ExplorerCardVariant.outlined:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        border = widget.border ??
            Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 1,
            );
        elevation = 0;
        shadowColor = Colors.transparent;

      case ExplorerCardVariant.glass:
        backgroundColor = isDark
            ? AppColors.glassDark
            : AppColors.glassWhite;
        border = null;
        elevation = 0;
        shadowColor = Colors.transparent;

      case ExplorerCardVariant.gradient:
        backgroundColor = Colors.transparent;
        border = null;
        elevation = widget.elevation ?? AppDimensions.elevation1;
        shadowColor = widget.shadowColor ??
            AppColors.primary.withValues(alpha: 0.2);
    }

    return _CardConfig(
      borderRadius: borderRadius,
      padding: padding,
      backgroundColor: backgroundColor,
      border: border,
      elevation: elevation,
      shadowColor: shadowColor,
    );
  }
}

class _CardConfig {
  const _CardConfig({
    required this.borderRadius,
    required this.padding,
    required this.backgroundColor,
    this.border,
    required this.elevation,
    required this.shadowColor,
  });

  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BoxBorder? border;
  final double elevation;
  final Color shadowColor;
}

enum ExplorerCardVariant {
  elevated,
  filled,
  outlined,
  glass,
  gradient,
}
