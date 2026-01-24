import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Loading Spinner - Custom globe/compass loading indicator
///
/// Features:
/// - Globe spinning animation
/// - Compass needle variant
/// - Multiple sizes
/// - Optional loading text
class ExplorerLoading extends StatefulWidget {
  const ExplorerLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.variant = LoadingVariant.compass,
    this.color,
    this.message,
  });

  /// Small loading indicator
  const ExplorerLoading.small({
    super.key,
    this.variant = LoadingVariant.compass,
    this.color,
    this.message,
  }) : size = LoadingSize.small;

  /// Large loading indicator
  const ExplorerLoading.large({
    super.key,
    this.variant = LoadingVariant.compass,
    this.color,
    this.message,
  }) : size = LoadingSize.large;

  /// Globe variant
  const ExplorerLoading.globe({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
  }) : variant = LoadingVariant.globe;

  final LoadingSize size;
  final LoadingVariant variant;
  final Color? color;
  final String? message;

  @override
  State<ExplorerLoading> createState() => _ExplorerLoadingState();
}

class _ExplorerLoadingState extends State<ExplorerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _indicatorSize {
    switch (widget.size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.medium:
        return 40.0;
      case LoadingSize.large:
        return 64.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _indicatorSize,
          height: _indicatorSize,
          child: widget.variant == LoadingVariant.compass
              ? _buildCompassLoader(color)
              : _buildGlobeLoader(color, isDark),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppDimensions.sm),
          Text(
            widget.message!,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompassLoader(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CompassPainter(
            progress: _controller.value,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildGlobeLoader(Color color, bool isDark) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlobePainter(
            progress: _controller.value,
            primaryColor: color,
            secondaryColor:
                isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw rotating arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * 0.8;
    final startAngle = progress * 2 * math.pi - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw compass needle
    final needleLength = radius * 0.6;
    final needleAngle = progress * 2 * math.pi;

    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // North needle (red part)
    final northPath = Path();
    final northTip = Offset(
      center.dx + needleLength * math.cos(needleAngle - math.pi / 2),
      center.dy + needleLength * math.sin(needleAngle - math.pi / 2),
    );
    final leftBase = Offset(
      center.dx + 4 * math.cos(needleAngle - math.pi),
      center.dy + 4 * math.sin(needleAngle - math.pi),
    );
    final rightBase = Offset(
      center.dx + 4 * math.cos(needleAngle),
      center.dy + 4 * math.sin(needleAngle),
    );

    northPath.moveTo(northTip.dx, northTip.dy);
    northPath.lineTo(leftBase.dx, leftBase.dy);
    northPath.lineTo(rightBase.dx, rightBase.dy);
    northPath.close();

    canvas.drawPath(northPath, needlePaint);

    // South needle (lighter)
    final southPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final southPath = Path();
    final southTip = Offset(
      center.dx + needleLength * math.cos(needleAngle + math.pi / 2),
      center.dy + needleLength * math.sin(needleAngle + math.pi / 2),
    );

    southPath.moveTo(southTip.dx, southTip.dy);
    southPath.lineTo(leftBase.dx, leftBase.dy);
    southPath.lineTo(rightBase.dx, rightBase.dy);
    southPath.close();

    canvas.drawPath(southPath, southPaint);

    // Center dot
    canvas.drawCircle(center, 3, needlePaint);
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GlobePainter extends CustomPainter {
  _GlobePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw globe outline
    final outlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, outlinePaint);

    // Draw equator
    final equatorPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      equatorPaint,
    );

    // Draw rotating meridian
    final meridianPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final meridianOffset = progress * 2 - 1; // -1 to 1

    // Draw ellipse for meridian
    final meridianRect = Rect.fromCenter(
      center: center,
      width: radius * 2 * meridianOffset.abs(),
      height: radius * 2,
    );

    if (meridianOffset.abs() > 0.1) {
      canvas.drawOval(meridianRect, meridianPaint);
    }

    // Draw latitude lines
    for (var i = 1; i <= 2; i++) {
      final latRadius = radius * (1 - i * 0.3);
      final latY = center.dy + (i % 2 == 0 ? -1 : 1) * radius * 0.5;
      canvas.drawLine(
        Offset(center.dx - latRadius, latY),
        Offset(center.dx + latRadius, latY),
        equatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GlobePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

enum LoadingSize {
  small,
  medium,
  large,
}

enum LoadingVariant {
  compass,
  globe,
}

/// Full page loading overlay
class ExplorerLoadingOverlay extends StatelessWidget {
  const ExplorerLoadingOverlay({
    super.key,
    this.message,
    this.variant = LoadingVariant.compass,
  });

  final String? message;
  final LoadingVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
          .withValues(alpha: 0.9),
      child: Center(
        child: ExplorerLoading.large(
          variant: variant,
          message: message ?? 'Loading...',
        ),
      ),
    );
  }
}
