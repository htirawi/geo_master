import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Progress Ring - Circular progress indicator
///
/// Features:
/// - Animated progress fill
/// - Center content (label, icon, etc.)
/// - Gradient stroke option
/// - Multiple size variants
/// - Customizable stroke width
class ExplorerProgressRing extends StatefulWidget {
  const ExplorerProgressRing({
    super.key,
    required this.progress,
    this.size = AppDimensions.progressRingMD,
    this.strokeWidth = AppDimensions.progressRingStroke,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.centerChild,
    this.showPercentage = false,
    this.percentageStyle,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
    this.startAngle = -90,
  });

  /// Small progress ring
  const ExplorerProgressRing.small({
    super.key,
    required this.progress,
    this.strokeWidth = AppDimensions.progressRingStroke,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.centerChild,
    this.showPercentage = false,
    this.percentageStyle,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
    this.startAngle = -90,
  }) : size = AppDimensions.progressRingSM;

  /// Large progress ring
  const ExplorerProgressRing.large({
    super.key,
    required this.progress,
    this.strokeWidth = 6.0,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.centerChild,
    this.showPercentage = false,
    this.percentageStyle,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
    this.startAngle = -90,
  }) : size = AppDimensions.progressRingLG;

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Size of the ring (diameter)
  final double size;

  /// Stroke width of the ring
  final double strokeWidth;

  /// Background track color
  final Color? backgroundColor;

  /// Progress stroke color
  final Color? progressColor;

  /// Gradient for progress stroke (overrides progressColor)
  final Gradient? gradient;

  /// Child widget to show in center
  final Widget? centerChild;

  /// Whether to show percentage in center (ignored if centerChild is set)
  final bool showPercentage;

  /// Percentage text style
  final TextStyle? percentageStyle;

  /// Animation duration
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  /// Start angle in degrees (-90 = top)
  final double startAngle;

  @override
  State<ExplorerProgressRing> createState() => _ExplorerProgressRingState();
}

class _ExplorerProgressRingState extends State<ExplorerProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  void didUpdateWidget(ExplorerProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      final previousValue = _animation.value;
      _animation = Tween<double>(
        begin: previousValue,
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

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: 1.0,
              strokeWidth: widget.strokeWidth,
              color: bgColor,
              startAngle: widget.startAngle,
            ),
          ),
          // Progress ring - wrapped in RepaintBoundary for performance
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: widget.gradient != null
                      ? _GradientRingPainter(
                          progress: _animation.value,
                          strokeWidth: widget.strokeWidth,
                          gradient: widget.gradient!,
                          startAngle: widget.startAngle,
                        )
                      : _RingPainter(
                          progress: _animation.value,
                          strokeWidth: widget.strokeWidth,
                          color: progressColor,
                          startAngle: widget.startAngle,
                        ),
                );
              },
            ),
          ),
          // Center content
          if (widget.centerChild != null)
            widget.centerChild!
          else if (widget.showPercentage)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: widget.percentageStyle ??
                      AppTypography.statSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    final startRadians = startAngle * math.pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRadians,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
    required this.startAngle,
  });

  final double progress;
  final double strokeWidth;
  final Gradient gradient;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    final startRadians = startAngle * math.pi / 180;

    canvas.drawArc(
      rect,
      startRadians,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Progress ring with mastery color coding
class MasteryProgressRing extends StatelessWidget {
  const MasteryProgressRing({
    super.key,
    required this.progress,
    this.size = AppDimensions.progressRingMD,
    this.strokeWidth = AppDimensions.progressRingStroke,
    this.showPercentage = true,
    this.centerChild,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final Widget? centerChild;

  @override
  Widget build(BuildContext context) {
    return ExplorerProgressRing(
      progress: progress,
      size: size,
      strokeWidth: strokeWidth,
      progressColor: AppColors.getMasteryColor(progress * 100),
      showPercentage: centerChild == null && showPercentage,
      centerChild: centerChild,
    );
  }
}

/// XP progress ring with gold gradient
class XPProgressRing extends StatelessWidget {
  const XPProgressRing({
    super.key,
    required this.progress,
    this.size = AppDimensions.progressRingMD,
    this.strokeWidth = AppDimensions.progressRingStroke,
    this.showPercentage = false,
    this.centerChild,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final Widget? centerChild;

  @override
  Widget build(BuildContext context) {
    return ExplorerProgressRing(
      progress: progress,
      size: size,
      strokeWidth: strokeWidth,
      gradient: AppColors.xpGradient,
      showPercentage: centerChild == null && showPercentage,
      centerChild: centerChild,
    );
  }
}
