import 'dart:math' as math;

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

/// Professional floating flags background with SVG flags
class FloatingFlagsBackground extends StatefulWidget {
  const FloatingFlagsBackground({
    super.key,
    required this.size,
    this.flagCount = 10,
    this.opacity = 0.15,
    this.seed = 42,
  });

  final Size size;
  final int flagCount;
  final double opacity;
  final int seed;

  @override
  State<FloatingFlagsBackground> createState() =>
      _FloatingFlagsBackgroundState();
}

class _FloatingFlagsBackgroundState extends State<FloatingFlagsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Curated list of visually distinct country codes (excluding Israel)
  // Arab countries prioritized: JO, PS, SA, AE, KW, EG
  static const List<String> _countryCodes = [
    'JO', 'PS', 'SA', 'AE', 'KW', 'EG', 'US', 'GB',
    'FR', 'DE', 'JP', 'CN', 'BR', 'IN', 'AU', 'CA',
    'IT', 'ES', 'KR', 'MX', 'ZA', 'NG', 'TR', 'AR',
    'NL', 'SE', 'NO', 'CH', 'BE', 'AT', 'PL', 'PT',
    'GR', 'TH', 'VN', 'MY', 'SG', 'ID', 'PH', 'NZ',
  ];

  late List<_FlagData> _flags;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _initializeFlags();
  }

  void _initializeFlags() {
    final random = math.Random(widget.seed);
    final shuffledCodes = List<String>.from(_countryCodes)..shuffle(random);

    // Take unique flags up to flagCount
    final selectedCodes = shuffledCodes.take(widget.flagCount).toList();

    _flags = List.generate(widget.flagCount, (index) {
      // Distribute flags more evenly across the screen
      final column = index % 3;
      final row = index ~/ 3;

      final xBase = (column / 3) * widget.size.width +
          (random.nextDouble() * 0.25 * widget.size.width);
      final yBase = (row / (widget.flagCount / 3)) * widget.size.height * 0.7 +
          (random.nextDouble() * 0.1 * widget.size.height);

      return _FlagData(
        countryCode: selectedCodes[index],
        x: xBase.clamp(20, widget.size.width - 60),
        y: yBase.clamp(40, widget.size.height * 0.65),
        size: 32 + random.nextDouble() * 12,
        opacity: widget.opacity + random.nextDouble() * 0.08,
        phaseOffset: random.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _flags.asMap().entries.map((entry) {
        final index = entry.key;
        final flag = entry.value;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress =
                (_controller.value + flag.phaseOffset + (index * 0.06)) % 1.0;
            final floatY = math.sin(progress * 2 * math.pi) * 12;
            final floatX = math.cos(progress * 1.5 * math.pi) * 6;
            final rotation = math.sin(progress * math.pi) * 0.06;

            return Positioned(
              left: flag.x + floatX,
              top: flag.y + floatY,
              child: Transform.rotate(
                angle: rotation,
                child: child!,
              ),
            );
          },
          child: Opacity(
            opacity: flag.opacity,
            child: _ProfessionalFlagWidget(
              countryCode: flag.countryCode,
              size: flag.size,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FlagData {
  const _FlagData({
    required this.countryCode,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phaseOffset,
  });

  final String countryCode;
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double phaseOffset;
}

/// Professional circular flag widget with border and shadow
class _ProfessionalFlagWidget extends StatelessWidget {
  const _ProfessionalFlagWidget({
    required this.countryCode,
    required this.size,
  });

  final String countryCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CountryFlag.fromCountryCode(
          countryCode,
          width: size,
          height: size,
        ),
      ),
    );
  }
}

/// Animated gradient orbs background decoration
class GradientOrbsBackground extends StatelessWidget {
  const GradientOrbsBackground({
    super.key,
    this.primaryColor,
    this.secondaryColor,
  });

  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? AppColors.primary;
    final secondary = secondaryColor ?? AppColors.secondary;

    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: 0.12),
                  primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1, end: 1.2, duration: 3.seconds),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondary.withValues(alpha: 0.08),
                  secondary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.2, end: 1, duration: 4.seconds),
      ],
    );
  }
}

/// Animated floating globe logo widget
class AnimatedGlobeLogo extends StatefulWidget {
  const AnimatedGlobeLogo({
    super.key,
    this.size = 120,
    this.borderRadius = 32,
  });

  final double size;
  final double borderRadius;

  @override
  State<AnimatedGlobeLogo> createState() => _AnimatedGlobeLogoState();
}

class _AnimatedGlobeLogoState extends State<AnimatedGlobeLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = _floatController.value * 8 - 4;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7),
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
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
              top: 12,
              left: 16,
              child: Container(
                width: 35,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Icon(
              Icons.public,
              size: widget.size * 0.53,
              color: Colors.white,
            ),
          ],
        ),
      ),
    )
        .animate()
        .scaleXY(
          begin: 0.5,
          end: 1,
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }
}

/// Animated particles background for splash screens
class ParticlesBackground extends StatelessWidget {
  const ParticlesBackground({
    super.key,
    required this.animation,
    this.particleCount = 30,
    this.seed = 123,
  });

  final Animation<double> animation;
  final int particleCount;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(seed);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: List.generate(particleCount, (index) {
        final x = random.nextDouble();
        final y = random.nextDouble();
        final size = 2.0 + random.nextDouble() * 3;
        final opacity = 0.3 + random.nextDouble() * 0.3;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final progress = (animation.value + (index * 0.033)) % 1.0;
            return Positioned(
              left: x * screenSize.width,
              top: ((y + progress) % 1.0) * screenSize.height,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: opacity),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Professional orbiting globe with SVG flags for splash screen
class OrbitingGlobe extends StatelessWidget {
  const OrbitingGlobe({
    super.key,
    required this.globeAnimation,
    required this.flagsAnimation,
    required this.pulseAnimation,
    this.flagCodes = const ['US', 'GB', 'FR', 'DE', 'JP', 'CN'],
  });

  final Animation<double> globeAnimation;
  final Animation<double> flagsAnimation;
  final Animation<double> pulseAnimation;
  final List<String> flagCodes;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globeAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, _) {
            final pulseScale = 1.0 + (pulseAnimation.value * 0.05);
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow rings
                    const _GlowRing(size: 160, opacity: 0.2),
                    const _GlowRing(size: 140, opacity: 0.3),
                    // Globe container
                    _GlobeCore(globeAnimation: globeAnimation),
                    // Orbiting flags
                    ..._buildOrbitingFlags(),
                  ],
                ),
              ),
            );
          },
        );
      },
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 600.ms);
  }

  List<Widget> _buildOrbitingFlags() {
    return List.generate(flagCodes.length, (index) {
      final angle = (index / flagCodes.length) * 2 * math.pi;
      return AnimatedBuilder(
        animation: flagsAnimation,
        builder: (context, _) {
          final rotatedAngle = angle + (flagsAnimation.value * 2 * math.pi);
          final x = math.cos(rotatedAngle) * 75;
          final y = math.sin(rotatedAngle) * 75;
          final scale = 0.8 + (math.sin(rotatedAngle) * 0.2);

          return Transform.translate(
            offset: Offset(x, y),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CountryFlag.fromCountryCode(
                    flagCodes[index],
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _GlobeCore extends StatelessWidget {
  const _GlobeCore({required this.globeAnimation});

  final Animation<double> globeAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4FC3F7),
            Color(0xFF1E88E5),
            Color(0xFF0D47A1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Continents simulation
            ..._buildContinentLines(),
            // Globe shine effect
            Positioned(
              top: 15,
              left: 20,
              child: Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContinentLines() {
    return List.generate(5, (index) {
      final offset = index * 24.0;
      return AnimatedBuilder(
        animation: globeAnimation,
        builder: (context, _) {
          final progress = (globeAnimation.value + (index * 0.2)) % 1.0;
          return Positioned(
            left: 10 + (progress * 100) - 50,
            top: 20 + offset,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                width: 40 + (index * 5),
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
