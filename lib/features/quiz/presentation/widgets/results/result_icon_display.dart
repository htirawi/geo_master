import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

/// Result icon based on accuracy or game over
class ResultIconDisplay extends StatelessWidget {
  const ResultIconDisplay({
    super.key,
    required this.accuracy,
    this.isGameOver = false,
  });

  final double accuracy;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return _buildGameOverIcon();
    }
    return _buildResultIcon();
  }

  Widget _buildGameOverIcon() {
    return Container(
      width: AppDimensions.resultIconContainerSize,
      height: AppDimensions.resultIconContainerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.error.withValues(alpha: 0.1),
      ),
      child: const Icon(
        Icons.sentiment_dissatisfied,
        size: AppDimensions.resultIconSize,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildResultIcon() {
    IconData icon;
    Color color;

    if (accuracy >= 100) {
      icon = Icons.emoji_events;
      color = AppColors.xpGold;
    } else if (accuracy >= 80) {
      icon = Icons.military_tech;
      color = AppColors.success;
    } else if (accuracy >= 60) {
      icon = Icons.thumb_up;
      color = AppColors.primary;
    } else if (accuracy >= 40) {
      icon = Icons.sentiment_neutral;
      color = AppColors.warning;
    } else {
      icon = Icons.sentiment_dissatisfied;
      color = AppColors.error;
    }

    return Container(
      width: AppDimensions.resultIconContainerSize,
      height: AppDimensions.resultIconContainerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: AppDimensions.resultIconSize, color: color),
    );
  }
}
