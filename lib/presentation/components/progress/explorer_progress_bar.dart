import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Explorer Progress Bar - Animated progress indicator
///
/// Features:
/// - Animated progress fill
/// - Gradient fill option
/// - Multiple variants (standard, thin, thick)
/// - Rounded or flat ends
/// - Label support
class ExplorerProgressBar extends StatefulWidget {
  const ExplorerProgressBar({
    super.key,
    required this.progress,
    this.height = AppDimensions.progressBarHeight,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.borderRadius,
    this.showLabel = false,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// Thin progress bar variant
  const ExplorerProgressBar.thin({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.borderRadius,
    this.showLabel = false,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  }) : height = AppDimensions.progressBarHeightThin;

  /// Thick progress bar variant
  const ExplorerProgressBar.thick({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.borderRadius,
    this.showLabel = false,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  }) : height = AppDimensions.progressBarHeightThick;

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Height of the progress bar
  final double height;

  /// Background track color
  final Color? backgroundColor;

  /// Progress fill color
  final Color? progressColor;

  /// Gradient for progress fill (overrides progressColor)
  final Gradient? gradient;

  /// Border radius of the bar
  final BorderRadiusGeometry? borderRadius;

  /// Whether to show percentage label
  final bool showLabel;

  /// Label text style
  final TextStyle? labelStyle;

  /// Animation duration
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  @override
  State<ExplorerProgressBar> createState() => _ExplorerProgressBarState();
}

class _ExplorerProgressBarState extends State<ExplorerProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ExplorerProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final progressColor = widget.progressColor ?? AppColors.primary;
    final radius = widget.borderRadius ??
        BorderRadius.circular(widget.height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).toInt()}%',
                style: widget.labelStyle ??
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.gradient == null ? progressColor : null,
                      gradient: widget.gradient,
                      borderRadius: radius,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress bar with mastery color coding
class MasteryProgressBar extends StatelessWidget {
  const MasteryProgressBar({
    super.key,
    required this.progress,
    this.height = AppDimensions.progressBarHeight,
    this.showLabel = false,
  });

  final double progress;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ExplorerProgressBar(
      progress: progress,
      height: height,
      progressColor: AppColors.getMasteryColor(progress * 100),
      showLabel: showLabel,
    );
  }
}

/// XP progress bar with gold gradient
class XPProgressBar extends StatelessWidget {
  const XPProgressBar({
    super.key,
    required this.progress,
    this.height = AppDimensions.progressBarHeight,
    this.showLabel = false,
  });

  final double progress;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ExplorerProgressBar(
      progress: progress,
      height: height,
      gradient: AppColors.xpGradient,
      showLabel: showLabel,
    );
  }
}
