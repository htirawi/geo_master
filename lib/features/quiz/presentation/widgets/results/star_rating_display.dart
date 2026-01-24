import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

/// Animated star rating display
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.stars,
    required this.animation,
  });

  final int stars;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedStars = (stars * animation.value).clamp(0.0, 5.0).toInt();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = index < animatedStars;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxs),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: AppDimensions.iconXL,
                color: isFilled ? AppColors.xpGold : Colors.grey[400],
              ),
            );
          }),
        );
      },
    );
  }
}
