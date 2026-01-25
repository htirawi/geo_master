import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import 'atlas_avatar.dart';
import 'atlas_provider.dart';

/// Animated Atlas widget using Lottie animations
/// Falls back to static avatar if animation not available
class AtlasAnimated extends ConsumerWidget {
  const AtlasAnimated({
    super.key,
    this.state,
    this.size = 120,
    this.autoPlay = true,
    this.onComplete,
  });

  /// The animation state to display
  /// If null, uses the provider state
  final AtlasState? state;

  /// Size of the animation
  final double size;

  /// Whether to auto-play the animation
  final bool autoPlay;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AtlasState atlasState = state ?? ref.watch(atlasStateProvider);

    // Check for reduce motion
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return _buildStaticFallback(atlasState);
    }

    return _buildAnimated(atlasState);
  }

  Widget _buildAnimated(AtlasState atlasState) {
    final assetPath = _getAssetPath(atlasState);

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        assetPath,
        width: size,
        height: size,
        repeat: _shouldRepeat(atlasState),
        animate: autoPlay,
        onLoaded: (composition) {
          if (!_shouldRepeat(atlasState) && onComplete != null) {
            Future.delayed(composition.duration, onComplete);
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildStaticFallback(atlasState);
        },
      ),
    );
  }

  Widget _buildStaticFallback(AtlasState atlasState) {
    final isHappy = atlasState == AtlasState.celebrate ||
        atlasState == AtlasState.wave ||
        atlasState == AtlasState.idle;

    final AtlasAvatarSize avatarSize;
    if (size <= 50) {
      avatarSize = AtlasAvatarSize.small;
    } else if (size <= 100) {
      avatarSize = AtlasAvatarSize.medium;
    } else {
      avatarSize = AtlasAvatarSize.large;
    }

    final Widget avatar = AtlasAvatarAnimated(
      size: avatarSize,
      isHappy: isHappy,
      animate: atlasState != AtlasState.sleeping,
    );

    // Add state-specific animations
    switch (atlasState) {
      case AtlasState.wave:
        return avatar.animate().shake(
              hz: 2,
              offset: const Offset(5, 0),
              duration: 800.ms,
            );
      case AtlasState.celebrate:
        return avatar
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.1, 1.1),
              duration: 500.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
            );
      case AtlasState.thinking:
        return Stack(
          children: [
            avatar,
            Positioned(
              top: -5,
              right: 0,
              child: Icon(
                Icons.psychology,
                size: size * 0.3,
                color: AppColors.info,
              )
                  .animate(
                    onPlay: (c) => c.repeat(),
                  )
                  .fadeIn()
                  .then()
                  .fade(
                    begin: 1,
                    end: 0.5,
                    duration: 1000.ms,
                  )
                  .then()
                  .fade(
                    begin: 0.5,
                    end: 1,
                    duration: 1000.ms,
                  ),
            ),
          ],
        );
      case AtlasState.encourage:
        return Stack(
          children: [
            avatar,
            Positioned(
              top: -5,
              right: 0,
              child: Icon(
                Icons.favorite,
                size: size * 0.25,
                color: AppColors.streak,
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
            ),
          ],
        );
      case AtlasState.sleeping:
        return Stack(
          children: [
            Opacity(opacity: 0.7, child: avatar),
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                'z z z',
                style: TextStyle(
                  fontSize: size * 0.15,
                  color: AppColors.textSecondaryLight,
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(),
                  )
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0, end: -0.5, duration: 2000.ms)
                  .fadeOut(delay: 1500.ms),
            ),
          ],
        );
      case AtlasState.idle:
        return avatar;
    }
  }

  String _getAssetPath(AtlasState atlasState) {
    switch (atlasState) {
      case AtlasState.idle:
        return 'assets/animations/lottie/mascot/atlas_idle.json';
      case AtlasState.wave:
        return 'assets/animations/lottie/mascot/atlas_wave.json';
      case AtlasState.celebrate:
        return 'assets/animations/lottie/mascot/atlas_celebrate.json';
      case AtlasState.thinking:
        return 'assets/animations/lottie/mascot/atlas_thinking.json';
      case AtlasState.encourage:
        return 'assets/animations/lottie/mascot/atlas_wave.json'; // Reuse wave
      case AtlasState.sleeping:
        return 'assets/animations/lottie/mascot/atlas_idle.json'; // Reuse idle
    }
  }

  bool _shouldRepeat(AtlasState atlasState) {
    switch (atlasState) {
      case AtlasState.idle:
      case AtlasState.thinking:
      case AtlasState.sleeping:
        return true;
      case AtlasState.wave:
      case AtlasState.celebrate:
      case AtlasState.encourage:
        return false;
    }
  }
}

/// Atlas with glow effect for special occasions
class AtlasWithGlow extends StatelessWidget {
  const AtlasWithGlow({
    super.key,
    required this.state,
    this.size = 120,
    this.glowColor,
  });

  final AtlasState state;
  final double size;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? _getGlowColor(state);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: size * 1.3,
          height: size * 1.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: effectiveGlowColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
            )
            .fade(
              begin: 0.5,
              end: 1,
              duration: 1500.ms,
            ),

        // Atlas
        AtlasAnimated(
          state: state,
          size: size,
        ),
      ],
    );
  }

  Color _getGlowColor(AtlasState state) {
    switch (state) {
      case AtlasState.celebrate:
        return AppColors.xpGold;
      case AtlasState.wave:
        return AppColors.primary;
      case AtlasState.thinking:
        return AppColors.info;
      case AtlasState.encourage:
        return AppColors.streak;
      default:
        return AppColors.primary;
    }
  }
}
