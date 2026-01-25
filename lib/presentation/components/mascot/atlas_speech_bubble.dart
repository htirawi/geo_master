import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'atlas_animated.dart';
import 'atlas_provider.dart';

/// Atlas with speech bubble for displaying messages
/// RTL-aware - bubble appears on correct side based on locale
class AtlasSpeechBubble extends StatelessWidget {
  const AtlasSpeechBubble({
    super.key,
    required this.message,
    this.atlasState = AtlasState.idle,
    this.atlasSize = 80,
    this.bubbleWidth,
    this.showAtlas = true,
    this.onTap,
    this.autoDismiss = false,
    this.dismissDuration = const Duration(seconds: 5),
    this.animateIn = true,
  });

  /// The message to display
  final String message;

  /// Atlas animation state
  final AtlasState atlasState;

  /// Size of Atlas avatar
  final double atlasSize;

  /// Width of the speech bubble (null = auto)
  final double? bubbleWidth;

  /// Whether to show Atlas avatar
  final bool showAtlas;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Whether to auto-dismiss
  final bool autoDismiss;

  /// Duration before auto-dismiss
  final Duration dismissDuration;

  /// Whether to animate entrance
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    Widget content = GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          if (showAtlas && !isArabic) ...[
            AtlasAnimated(
              state: atlasState,
              size: atlasSize,
            ),
            const SizedBox(width: 8),
          ],

          // Speech bubble
          Flexible(
            child: _SpeechBubble(
              message: message,
              pointsLeft: !isArabic,
              width: bubbleWidth,
            ),
          ),

          if (showAtlas && isArabic) ...[
            const SizedBox(width: 8),
            AtlasAnimated(
              state: atlasState,
              size: atlasSize,
            ),
          ],
        ],
      ),
    );

    if (animateIn) {
      content = content.animate().fadeIn().slideY(
            begin: 0.2,
            end: 0,
            curve: Curves.easeOutBack,
          );
    }

    return content;
  }
}

/// Speech bubble widget with pointer
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.message,
    required this.pointsLeft,
    this.width,
  });

  final String message;
  final bool pointsLeft;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return CustomPaint(
      painter: _SpeechBubblePainter(
        color: theme.colorScheme.surface,
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        pointsLeft: pointsLeft,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: EdgeInsets.only(
          left: pointsLeft ? 10 : 0,
          right: pointsLeft ? 0 : 10,
        ),
        child: Text(
          message,
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 14,
            height: 1.4,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }
}

/// Custom painter for speech bubble with pointer
class _SpeechBubblePainter extends CustomPainter {
  _SpeechBubblePainter({
    required this.color,
    required this.borderColor,
    required this.pointsLeft,
    required this.shadowColor,
  });

  final Color color;
  final Color borderColor;
  final bool pointsLeft;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    const radius = AppDimensions.radiusMD;
    const pointerWidth = 10.0;
    const pointerHeight = 8.0;

    final path = Path();

    if (pointsLeft) {
      // Pointer on left
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width, size.height - radius);
      path.arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius, size.height);
      path.arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
      );
      // Pointer
      path.lineTo(0, size.height - 15);
      path.lineTo(-pointerWidth, size.height - 15 - pointerHeight / 2);
      path.lineTo(0, size.height - 15 - pointerHeight);
      path.lineTo(0, radius);
      path.arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      );
    } else {
      // Pointer on right
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      );
      // Pointer
      path.lineTo(size.width, size.height - 15 - pointerHeight);
      path.lineTo(
        size.width + pointerWidth,
        size.height - 15 - pointerHeight / 2,
      );
      path.lineTo(size.width, size.height - 15);
      path.lineTo(size.width, size.height - radius);
      path.arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius, size.height);
      path.arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(0, radius);
      path.arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      );
    }

    path.close();

    // Draw shadow
    canvas.drawPath(path.shift(const Offset(2, 2)), shadowPaint);

    // Draw fill
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Atlas greeting card with speech bubble
class AtlasGreetingCard extends StatelessWidget {
  const AtlasGreetingCard({
    super.key,
    this.greeting,
    this.onDismiss,
  });

  /// Custom greeting message (null = auto time-based)
  final String? greeting;

  /// Callback when dismissed
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final message = greeting ??
        AtlasGreetings.getTimeBasedGreeting(isArabic: isArabic);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.oceanMid.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AtlasSpeechBubble(
              message: message,
              atlasState: AtlasState.wave,
              atlasSize: 60,
              onTap: onDismiss,
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              iconSize: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
}
