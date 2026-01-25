import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';

/// Animated counter widget for XP, scores, and other numeric displays
/// Features smooth counting animation with optional sound effects
class AnimatedCounter extends ConsumerStatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.prefix,
    this.suffix,
    this.style,
    this.playSound = false,
    this.soundInterval = 5,
    this.curve = Curves.easeOut,
    this.onComplete,
    this.startValue = 0,
    this.showPlusSign = false,
    this.color,
    this.fontSize,
    this.autoStart = true,
  });

  /// The target value to count to
  final int value;

  /// Duration of the counting animation
  final Duration duration;

  /// Prefix text (e.g., "+", "XP: ")
  final String? prefix;

  /// Suffix text (e.g., " XP", " pts")
  final String? suffix;

  /// Custom text style
  final TextStyle? style;

  /// Whether to play tick sounds during counting
  final bool playSound;

  /// How often to play sound (every N increments)
  final int soundInterval;

  /// Animation curve
  final Curve curve;

  /// Callback when counting completes
  final VoidCallback? onComplete;

  /// Starting value (defaults to 0)
  final int startValue;

  /// Whether to show a + sign for positive values
  final bool showPlusSign;

  /// Custom color (overrides style color)
  final Color? color;

  /// Custom font size (overrides style fontSize)
  final double? fontSize;

  /// Whether to start animation automatically
  final bool autoStart;

  @override
  ConsumerState<AnimatedCounter> createState() => AnimatedCounterState();
}

class AnimatedCounterState extends ConsumerState<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _lastSoundValue = 0;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.startValue.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addListener(_onAnimationUpdate);
    _controller.addStatusListener(_onAnimationStatus);

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: widget.startValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _hasCompleted = false;
      _controller.forward(from: 0);
    }
  }

  void _onAnimationUpdate() {
    if (widget.playSound && mounted) {
      final currentValue = _animation.value.round();
      if (currentValue - _lastSoundValue >= widget.soundInterval) {
        _lastSoundValue = currentValue;
        _playTickSound();
      }
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_hasCompleted) {
      _hasCompleted = true;
      widget.onComplete?.call();
    }
  }

  Future<void> _playTickSound() async {
    try {
      final audioService = ref.read(audioServiceProvider);
      await audioService.playXpTick();
    } catch (_) {
      // Ignore audio errors
    }
  }

  /// Start the counting animation
  void start() {
    _hasCompleted = false;
    _controller.forward(from: 0);
  }

  /// Reset the counter
  void reset() {
    _hasCompleted = false;
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final defaultStyle = (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
      fontSize: widget.fontSize ?? 32,
      fontWeight: FontWeight.bold,
      color: widget.color ?? AppColors.xpGold,
    );

    final textStyle = widget.style ?? defaultStyle;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value.round();
        final sign = widget.showPlusSign && currentValue > 0 ? '+' : '';

        return Text(
          '${widget.prefix ?? ''}$sign$currentValue${widget.suffix ?? ''}',
          style: textStyle.copyWith(
            color: widget.color ?? textStyle.color,
            fontSize: widget.fontSize ?? textStyle.fontSize,
          ),
        );
      },
    );
  }
}

/// XP Counter with default styling for XP displays
class XpCounter extends StatelessWidget {
  const XpCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.playSound = true,
    this.onComplete,
    this.fontSize = 32,
    this.showPlusSign = true,
  });

  final int value;
  final Duration duration;
  final bool playSound;
  final VoidCallback? onComplete;
  final double fontSize;
  final bool showPlusSign;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedCounter(
      value: value,
      duration: duration,
      suffix: ' XP',
      playSound: playSound,
      soundInterval: (value / 20).clamp(1, 10).round(),
      onComplete: onComplete,
      showPlusSign: showPlusSign,
      color: AppColors.xpGold,
      fontSize: fontSize,
      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
        fontWeight: FontWeight.bold,
      ),
    ).animate().shimmer(
          duration: 2000.ms,
          color: AppColors.xpGold.withValues(alpha: 0.3),
        );
  }
}

/// Score counter for quiz results
class ScoreCounter extends StatelessWidget {
  const ScoreCounter({
    super.key,
    required this.score,
    required this.total,
    this.duration = const Duration(milliseconds: 1200),
    this.fontSize = 48,
    this.onComplete,
  });

  final int score;
  final int total;
  final Duration duration;
  final double fontSize;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AnimatedCounter(
          value: score,
          duration: duration,
          onComplete: onComplete,
          fontSize: fontSize,
          color: theme.colorScheme.primary,
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' / $total',
          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: fontSize * 0.6,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Percentage counter for accuracy displays
class PercentageCounter extends StatelessWidget {
  const PercentageCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.fontSize = 36,
    this.color,
    this.onComplete,
  });

  final double value;
  final Duration duration;
  final double fontSize;
  final Color? color;
  final VoidCallback? onComplete;

  Color get _defaultColor {
    if (value >= 90) return AppColors.success;
    if (value >= 70) return AppColors.primary;
    if (value >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedCounter(
      value: value.round(),
      duration: duration,
      suffix: '%',
      onComplete: onComplete,
      fontSize: fontSize,
      color: color ?? _defaultColor,
      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
