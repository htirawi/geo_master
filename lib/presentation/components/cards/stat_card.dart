import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import 'explorer_card.dart';

/// Stat Card - Display a single statistic with icon and label
///
/// Features:
/// - Animated value display
/// - Icon support
/// - Multiple variants (standard, compact, featured)
/// - Gradient backgrounds
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.prefix,
    this.suffix,
    this.variant = StatCardVariant.standard,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.animateValue = true,
  });

  /// Compact stat card
  const StatCard.compact({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.prefix,
    this.suffix,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.animateValue = true,
  }) : variant = StatCardVariant.compact;

  /// Featured stat card with larger display
  const StatCard.featured({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.prefix,
    this.suffix,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.animateValue = true,
  }) : variant = StatCardVariant.featured;

  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final String? prefix;
  final String? suffix;
  final StatCardVariant variant;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool animateValue;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    if (widget.animateValue) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.variant) {
      case StatCardVariant.standard:
        return _buildStandardCard(isDark);
      case StatCardVariant.compact:
        return _buildCompactCard(isDark);
      case StatCardVariant.featured:
        return _buildFeaturedCard(isDark);
    }
  }

  Widget _buildStandardCard(bool isDark) {
    Widget card = ExplorerCard.elevated(
      backgroundColor: widget.backgroundColor,
      onTap: widget.onTap,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: AppDimensions.iconLG,
              color: widget.iconColor ?? AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.xs),
          ],
          _buildValue(isDark, AppTypography.statMedium),
          const SizedBox(height: AppDimensions.xxs),
          Text(
            widget.label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (widget.gradient != null) {
      card = ExplorerCard.gradient(
        gradient: widget.gradient!,
        onTap: widget.onTap,
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: AppDimensions.iconLG,
                color: Colors.white,
              ),
              const SizedBox(height: AppDimensions.xs),
            ],
            _buildValue(isDark, AppTypography.statMedium, isGradient: true),
            const SizedBox(height: AppDimensions.xxs),
            Text(
              widget.label,
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return card;
  }

  Widget _buildCompactCard(bool isDark) {
    return ExplorerCard.filled(
      backgroundColor: widget.backgroundColor,
      onTap: widget.onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: AppDimensions.iconSM,
              color: widget.iconColor ?? AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.xs),
          ],
          _buildValue(isDark, AppTypography.statSmall),
          const SizedBox(width: AppDimensions.xxs),
          Text(
            widget.label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(bool isDark) {
    Widget card = ExplorerCard.elevated(
      backgroundColor: widget.backgroundColor,
      onTap: widget.onTap,
      elevation: AppDimensions.elevation2,
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: (widget.iconColor ?? AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Icon(
                widget.icon,
                size: AppDimensions.iconXL,
                color: widget.iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
          ],
          _buildValue(isDark, AppTypography.statLarge),
          const SizedBox(height: AppDimensions.xs),
          Text(
            widget.label,
            style: AppTypography.cardTitle.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (widget.gradient != null) {
      card = ExplorerCard.gradient(
        gradient: widget.gradient!,
        onTap: widget.onTap,
        elevation: AppDimensions.elevation2,
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Icon(
                  widget.icon,
                  size: AppDimensions.iconXL,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
            _buildValue(isDark, AppTypography.statLarge, isGradient: true),
            const SizedBox(height: AppDimensions.xs),
            Text(
              widget.label,
              style: AppTypography.cardTitle.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return card;
  }

  Widget _buildValue(bool isDark, TextStyle style, {bool isGradient = false}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_animation.value * 0.5),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (widget.prefix != null)
            Text(
              widget.prefix!,
              style: style.copyWith(
                fontSize: style.fontSize! * 0.6,
                color: isGradient
                    ? Colors.white.withValues(alpha: 0.8)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          Text(
            widget.value,
            style: style.copyWith(
              color: isGradient
                  ? Colors.white
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
          if (widget.suffix != null)
            Text(
              widget.suffix!,
              style: style.copyWith(
                fontSize: style.fontSize! * 0.6,
                color: isGradient
                    ? Colors.white.withValues(alpha: 0.8)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
        ],
      ),
    );
  }
}

enum StatCardVariant {
  standard,
  compact,
  featured,
}

/// Row of stat cards with consistent spacing
class StatCardRow extends StatelessWidget {
  const StatCardRow({
    super.key,
    required this.children,
    this.spacing = AppDimensions.md,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .toList()
          .asMap()
          .entries
          .expand((entry) {
        if (entry.key == 0) return [entry.value];
        return [SizedBox(width: spacing), entry.value];
      }).toList(),
    );
  }
}
