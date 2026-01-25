import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';

/// Atlas avatar sizes
enum AtlasAvatarSize {
  small(40),
  medium(80),
  large(120);

  const AtlasAvatarSize(this.size);
  final double size;
}

/// Static Atlas avatar widget
/// Used for compact displays where animation isn't needed
class AtlasAvatar extends StatelessWidget {
  const AtlasAvatar({
    super.key,
    this.size = AtlasAvatarSize.medium,
    this.showBorder = true,
    this.showShadow = true,
    this.isHappy = true,
  });

  final AtlasAvatarSize size;
  final bool showBorder;
  final bool showShadow;
  final bool isHappy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size.size,
      height: size.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.xpGold.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.2),
          ],
        ),
        border: showBorder
            ? Border.all(
                color: AppColors.xpGold,
                width: size.size * 0.04,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.xpGold.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.8 : 0.9),
                    AppColors.oceanMid.withValues(alpha: isDark ? 0.6 : 0.7),
                  ],
                ),
              ),
            ),

            // Globe/compass design
            Center(
              child: _buildAtlasFace(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtlasFace() {
    final faceSize = size.size * 0.7;
    final eyeSize = size.size * 0.12;
    final eyeSpacing = size.size * 0.15;

    return SizedBox(
      width: faceSize,
      height: faceSize,
      child: Stack(
        children: [
          // Explorer hat
          Positioned(
            top: -size.size * 0.05,
            left: size.size * 0.08,
            right: size.size * 0.08,
            child: Container(
              height: size.size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.xpGold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.size * 0.15),
                  topRight: Radius.circular(size.size * 0.15),
                  bottomLeft: Radius.circular(size.size * 0.05),
                  bottomRight: Radius.circular(size.size * 0.05),
                ),
              ),
            ),
          ),

          // Face
          Positioned(
            top: size.size * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Eyes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEye(eyeSize),
                    SizedBox(width: eyeSpacing),
                    _buildEye(eyeSize),
                  ],
                ),

                SizedBox(height: size.size * 0.05),

                // Mouth
                if (isHappy)
                  Container(
                    width: size.size * 0.2,
                    height: size.size * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size.size * 0.1),
                        bottomRight: Radius.circular(size.size * 0.1),
                      ),
                    ),
                  )
                else
                  Container(
                    width: size.size * 0.15,
                    height: size.size * 0.02,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),

          // Compass accent
          Positioned(
            bottom: size.size * 0.05,
            right: size.size * 0.05,
            child: Container(
              width: size.size * 0.12,
              height: size.size * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.xpGold.withValues(alpha: 0.8),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.explore,
                size: size.size * 0.08,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.5,
          height: eyeSize * 0.5,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Animated Atlas avatar with pulse/glow effect
class AtlasAvatarAnimated extends StatelessWidget {
  const AtlasAvatarAnimated({
    super.key,
    this.size = AtlasAvatarSize.medium,
    this.isHappy = true,
    this.animate = true,
  });

  final AtlasAvatarSize size;
  final bool isHappy;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final avatar = AtlasAvatar(
      size: size,
      isHappy: isHappy,
    );

    if (!animate) {
      return avatar;
    }

    return avatar
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}
