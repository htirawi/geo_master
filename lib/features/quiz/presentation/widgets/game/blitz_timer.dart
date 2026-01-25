import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

/// Blitz mode timer widget with animated countdown
class BlitzTimer extends StatelessWidget {
  const BlitzTimer({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
    required this.pulseAnimation,
  });

  final int timeRemaining;
  final int totalTime;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final progress = timeRemaining / totalTime;
    final isLow = timeRemaining <= 5;
    final color = isLow ? AppColors.error : AppColors.primary;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final Widget content = Semantics(
      label: '$timeRemaining seconds remaining',
      liveRegion: isLow, // Announce urgently when time is low
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    final scale = reduceMotion
                        ? 1.0
                        : (isLow ? 1.0 + (pulseAnimation.value * 0.1) : 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.timer,
                        color: color,
                        size: AppDimensions.iconMD,
                        semanticLabel: 'Timer',
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  '$timeRemaining',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  's',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Semantics(
              label: '${(progress * 100).round()}% time remaining',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.xxs),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.2),
                  color: color,
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (reduceMotion) {
      return content;
    }

    return content.animate().fadeIn(duration: 200.ms);
  }
}
