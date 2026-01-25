import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Button - Primary button component for the Explorer's Journey theme
///
/// Features:
/// - Multiple variants (primary, secondary, accent, outlined, ghost, danger, success)
/// - Loading state with spinner
/// - Icon support (leading and trailing)
/// - Haptic feedback
/// - Responsive sizing (small, medium, large)
/// - Gradient backgrounds
/// - Disabled state
class ExplorerButton extends StatefulWidget {
  const ExplorerButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.variant = ExplorerButtonVariant.primary,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
    this.gradient,
  });

  /// Primary button - Navy background
  const ExplorerButton.primary({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.primary,
        gradient = null;

  /// Secondary button - Outlined style
  const ExplorerButton.secondary({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.secondary,
        gradient = null;

  /// Accent button - Gold/treasure color
  const ExplorerButton.accent({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.accent,
        gradient = null;

  /// Outlined button - Transparent with border
  const ExplorerButton.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.outlined,
        gradient = null;

  /// Ghost button - Minimal style
  const ExplorerButton.ghost({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.ghost,
        gradient = null;

  /// Danger button - Error/destructive actions
  const ExplorerButton.danger({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.danger,
        gradient = null;

  /// Success button - Confirmation actions
  const ExplorerButton.success({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  })  : variant = ExplorerButtonVariant.success,
        gradient = null;

  /// Gradient button - Custom gradient background
  const ExplorerButton.gradient({
    super.key,
    required this.onPressed,
    required this.label,
    required LinearGradient this.gradient,
    this.icon,
    this.trailingIcon,
    this.size = ExplorerButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = true,
    this.hapticFeedback = true,
  }) : variant = ExplorerButtonVariant.gradient;

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final ExplorerButtonVariant variant;
  final ExplorerButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final bool hapticFeedback;
  final LinearGradient? gradient;

  @override
  State<ExplorerButton> createState() => _ExplorerButtonState();
}

class _ExplorerButtonState extends State<ExplorerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      if (!_reduceMotion) {
        _controller.forward();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (!_reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    if (!_reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final config = _getButtonConfig(isDark, isDisabled);

    final Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _reduceMotion ? 1.0 : _scaleAnimation.value,
          child: child,
        );
      },
      child: Semantics(
        button: true,
        enabled: !isDisabled,
        label: widget.label,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: _reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            height: config.height,
            padding: EdgeInsets.symmetric(horizontal: config.horizontalPadding),
            decoration: BoxDecoration(
              color: widget.variant == ExplorerButtonVariant.gradient
                  ? null
                  : config.backgroundColor,
              gradient: widget.variant == ExplorerButtonVariant.gradient
                  ? widget.gradient
                  : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: config.border,
              boxShadow: _isPressed || isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: config.backgroundColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: _buildContent(config),
          ),
        ),
      ),
    );

    if (widget.isExpanded) {
      return button;
    }

    return IntrinsicWidth(child: button);
  }

  Widget _buildContent(_ButtonConfig config) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: config.iconSize,
          height: config.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(config.foregroundColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: config.iconSize,
            color: config.foregroundColor,
          ),
          SizedBox(width: config.iconSpacing),
        ],
        Text(
          widget.label,
          style: config.textStyle.copyWith(
            color: config.foregroundColor,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: config.iconSpacing),
          Icon(
            widget.trailingIcon,
            size: config.iconSize,
            color: config.foregroundColor,
          ),
        ],
      ],
    );
  }

  _ButtonConfig _getButtonConfig(bool isDark, bool isDisabled) {
    // Size config
    double height;
    double horizontalPadding;
    double iconSize;
    double iconSpacing;
    TextStyle textStyle;

    switch (widget.size) {
      case ExplorerButtonSize.small:
        height = AppDimensions.buttonHeightSM;
        horizontalPadding = AppDimensions.md;
        iconSize = AppDimensions.iconXS;
        iconSpacing = AppDimensions.xxs;
        textStyle = AppTypography.buttonTextSmall;
      case ExplorerButtonSize.medium:
        height = AppDimensions.buttonHeightMD;
        horizontalPadding = AppDimensions.lg;
        iconSize = AppDimensions.iconSM;
        iconSpacing = AppDimensions.xs;
        textStyle = AppTypography.buttonText;
      case ExplorerButtonSize.large:
        height = AppDimensions.buttonHeightLG;
        horizontalPadding = AppDimensions.xl;
        iconSize = AppDimensions.iconMD;
        iconSpacing = AppDimensions.xs;
        textStyle = AppTypography.buttonText;
    }

    // Variant config
    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    if (isDisabled) {
      backgroundColor = AppColors.mountainStone.withValues(alpha: 0.2);
      foregroundColor = AppColors.mountainStone;
      border = null;
    } else {
      switch (widget.variant) {
        case ExplorerButtonVariant.primary:
          backgroundColor = AppColors.primary;
          foregroundColor = Colors.white;
          border = null;
        case ExplorerButtonVariant.secondary:
          backgroundColor = isDark
              ? AppColors.primaryDark.withValues(alpha: 0.3)
              : AppColors.primarySurface;
          foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
          border = null;
        case ExplorerButtonVariant.accent:
          backgroundColor = AppColors.accent;
          foregroundColor = Colors.white;
          border = null;
        case ExplorerButtonVariant.outlined:
          backgroundColor = Colors.transparent;
          foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
          border = Border.all(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          );
        case ExplorerButtonVariant.ghost:
          backgroundColor = Colors.transparent;
          foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
          border = null;
        case ExplorerButtonVariant.danger:
          backgroundColor = AppColors.error;
          foregroundColor = Colors.white;
          border = null;
        case ExplorerButtonVariant.success:
          backgroundColor = AppColors.success;
          foregroundColor = Colors.white;
          border = null;
        case ExplorerButtonVariant.gradient:
          backgroundColor = Colors.transparent;
          foregroundColor = Colors.white;
          border = null;
      }
    }

    return _ButtonConfig(
      height: height,
      horizontalPadding: horizontalPadding,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      border: border,
    );
  }
}

class _ButtonConfig {
  const _ButtonConfig({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.iconSpacing,
    required this.textStyle,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
  });

  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double iconSpacing;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color foregroundColor;
  final Border? border;
}

enum ExplorerButtonVariant {
  primary,
  secondary,
  accent,
  outlined,
  ghost,
  danger,
  success,
  gradient,
}

enum ExplorerButtonSize {
  small,
  medium,
  large,
}
