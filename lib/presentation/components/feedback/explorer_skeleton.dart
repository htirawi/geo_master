import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Explorer Skeleton - Shimmer loading placeholders
///
/// Features:
/// - Animated shimmer effect
/// - Geography-themed skeleton shapes
/// - Country card skeleton
/// - Quiz card skeleton
/// - Profile skeleton
class ExplorerSkeleton extends StatefulWidget {
  const ExplorerSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<ExplorerSkeleton> createState() => _ExplorerSkeletonState();
}

class _ExplorerSkeletonState extends State<ExplorerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                0.0,
                0.5 + (_animation.value * 0.25),
                1.0,
              ],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Skeleton box - basic rectangular skeleton element
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.dividerLight,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusSM),
      ),
    );
  }
}

/// Skeleton circle - for avatars and icons
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.dividerLight,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Country card skeleton
class CountryCardSkeleton extends StatelessWidget {
  const CountryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExplorerSkeleton(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          children: [
            // Flag placeholder
            SkeletonBox(
              width: 60,
              height: 40,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            const SizedBox(width: AppDimensions.md),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 18),
                  const SizedBox(height: AppDimensions.xs),
                  const SkeletonBox(width: 80, height: 14),
                ],
              ),
            ),
            // Progress placeholder
            const SkeletonCircle(size: 36),
          ],
        ),
      ),
    );
  }
}

/// Quiz card skeleton
class QuizCardSkeleton extends StatelessWidget {
  const QuizCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExplorerSkeleton(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonCircle(size: 48),
                const SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 100, height: 18),
                    const SizedBox(height: AppDimensions.xs),
                    const SkeletonBox(width: 60, height: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            const SkeletonBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Stat card skeleton
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExplorerSkeleton(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonCircle(size: 32),
            const SizedBox(height: AppDimensions.sm),
            const SkeletonBox(width: 60, height: 24),
            const SizedBox(height: AppDimensions.xs),
            const SkeletonBox(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}

/// List skeleton - multiple items
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.separatorHeight = AppDimensions.sm,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double separatorHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < itemCount - 1 ? separatorHeight : 0,
          ),
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}

/// Grid skeleton - multiple items in grid
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.spacing = AppDimensions.md,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int crossAxisCount;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(
        itemCount,
        (index) => SizedBox(
          width: (MediaQuery.of(context).size.width -
                  (crossAxisCount + 1) * spacing) /
              crossAxisCount,
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}

/// Profile header skeleton
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExplorerSkeleton(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            const SkeletonCircle(size: 80),
            const SizedBox(height: AppDimensions.md),
            const SkeletonBox(width: 120, height: 20),
            const SizedBox(height: AppDimensions.xs),
            const SkeletonBox(width: 80, height: 14),
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(),
                _buildStatColumn(),
                _buildStatColumn(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn() {
    return Column(
      children: [
        const SkeletonBox(width: 40, height: 24),
        const SizedBox(height: AppDimensions.xxs),
        const SkeletonBox(width: 60, height: 12),
      ],
    );
  }
}
