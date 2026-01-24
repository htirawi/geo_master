import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';

/// Onboarding background with animated gradient, orbs, and floating flags.
///
/// Used across all onboarding screens for consistent "Explorer's Journey" theme.
/// The background creates an immersive space exploration feel with:
/// - Deep gradient from navy to dark blue
/// - Animated gradient orbs for visual depth
/// - Floating flag emojis that gently move
class OnboardingBackground extends StatefulWidget {
  const OnboardingBackground({
    super.key,
    this.child,
    this.showFlags = true,
    this.flagCount = 18,
    this.primaryOrbColor,
    this.secondaryOrbColor,
  });

  /// The content to display over the background
  final Widget? child;

  /// Whether to show floating flag emojis
  final bool showFlags;

  /// Number of floating flags to display
  final int flagCount;

  /// Custom primary orb color (defaults to AppColors.secondary)
  final Color? primaryOrbColor;

  /// Custom secondary orb color (defaults to AppColors.tertiary)
  final Color? secondaryOrbColor;

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Comprehensive flag list including Arabic and world countries
  static const List<String> _worldFlags = [
    // Arabic countries
    '🇯🇴', '🇵🇸', '🇸🇦', '🇦🇪', '🇰🇼', '🇱🇧', '🇹🇳', '🇩🇿',
    '🇪🇬', '🇲🇦', '🇮🇶', '🇸🇾', '🇾🇪', '🇴🇲', '🇧🇭', '🇶🇦',
    '🇱🇾', '🇸🇩',
    // World countries
    '🇺🇸', '🇬🇧', '🇫🇷', '🇩🇪', '🇯🇵', '🇨🇳', '🇧🇷', '🇮🇳',
    '🇦🇺', '🇨🇦', '🇮🇹', '🇪🇸', '🇷🇺', '🇰🇷', '🇲🇽', '🇹🇷',
    '🇳🇬', '🇿🇦', '🇰🇪', '🇦🇷', '🇨🇱', '🇵🇪', '🇨🇴', '🇹🇭',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1B2A), // Deep navy
            Color(0xFF1B263B), // Dark blue
            Color(0xFF415A77), // Slate blue
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient orbs for visual depth
          _buildGradientOrbs(),

          // Animated floating flags
          if (widget.showFlags) ..._buildFloatingFlags(size),

          // Content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _buildGradientOrbs() {
    final primaryColor = widget.primaryOrbColor ?? AppColors.secondary;
    final secondaryColor = widget.secondaryOrbColor ?? AppColors.tertiary;

    return Stack(
      children: [
        // Top-right orb
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  primaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 4.seconds,
            ),
        // Bottom-left orb
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondaryColor.withValues(alpha: 0.15),
                  secondaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1, 1),
              duration: 5.seconds,
            ),
      ],
    );
  }

  List<Widget> _buildFloatingFlags(Size size) {
    final random = math.Random(42); // Fixed seed for consistent layout
    final shuffledFlags = List<String>.from(_worldFlags)..shuffle(random);
    final uniqueFlags = shuffledFlags.take(widget.flagCount).toList();

    return List.generate(uniqueFlags.length, (index) {
      // Distribute flags evenly across the screen
      final col = index % 3;
      final row = index ~/ 3;
      final baseX =
          (col * size.width / 3) + random.nextDouble() * (size.width / 4);
      final baseY =
          (row * size.height / 6) + random.nextDouble() * (size.height / 8);
      final opacity = 0.3 + random.nextDouble() * 0.25;
      final fontSize = 28 + random.nextDouble() * 14;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final progress =
              (_animationController.value + (index * 0.06)) % 1.0;
          final floatY = math.sin(progress * 2 * math.pi) * 15;
          final floatX = math.cos(progress * 2 * math.pi + index) * 8;

          return Positioned(
            left: baseX + floatX,
            top: baseY + floatY,
            child: child!,
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Text(
            uniqueFlags[index],
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      );
    });
  }
}

/// Animated globe widget for onboarding screens
class AnimatedGlobe extends StatefulWidget {
  const AnimatedGlobe({
    super.key,
    this.size = 140,
    this.rotationDuration = const Duration(seconds: 30),
    this.floatDuration = const Duration(seconds: 3),
  });

  /// Size of the globe
  final double size;

  /// Duration for one full rotation
  final Duration rotationDuration;

  /// Duration for one float cycle
  final Duration floatDuration;

  @override
  State<AnimatedGlobe> createState() => _AnimatedGlobeState();
}

class _AnimatedGlobeState extends State<AnimatedGlobe>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: widget.floatDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = _floatController.value * 10 - 5;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7), // Light blue
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shine effect
            Positioned(
              top: widget.size * 0.14,
              left: widget.size * 0.18,
              child: Container(
                width: widget.size * 0.28,
                height: widget.size * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Rotating globe icon
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Icon(
                    Icons.public,
                    size: widget.size * 0.5,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }
}

/// Shimmer text effect for titles
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    this.shimmerColors,
  });

  final String text;
  final TextStyle style;
  final List<Color>? shimmerColors;

  @override
  Widget build(BuildContext context) {
    final colors = shimmerColors ??
        const [Colors.white, Color(0xFF90CAF9), Colors.white];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
      ).createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
