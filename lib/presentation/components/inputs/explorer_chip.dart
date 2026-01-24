import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Chip - Selection chips for filtering and tags
///
/// Features:
/// - Multiple variants (filled, outlined, filter)
/// - Single and multi-select support
/// - Icon support
/// - Animated selection state
/// - Continent-colored variants
class ExplorerChip extends StatefulWidget {
  const ExplorerChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.avatar,
    this.variant = ChipVariant.filled,
    this.selectedColor,
    this.enabled = true,
    this.hapticFeedback = true,
  });

  /// Outlined chip variant
  const ExplorerChip.outlined({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.avatar,
    this.selectedColor,
    this.enabled = true,
    this.hapticFeedback = true,
  }) : variant = ChipVariant.outlined;

  /// Filter chip variant (for filtering content)
  const ExplorerChip.filter({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.avatar,
    this.selectedColor,
    this.enabled = true,
    this.hapticFeedback = true,
  }) : variant = ChipVariant.filter;

  /// Continent-themed chip
  factory ExplorerChip.continent({
    Key? key,
    required String continent,
    bool isSelected = false,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return ExplorerChip(
      key: key,
      label: continent,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.getContinentColor(continent),
      enabled: enabled,
      variant: ChipVariant.filled,
    );
  }

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? avatar;
  final ChipVariant variant;
  final Color? selectedColor;
  final bool enabled;
  final bool hapticFeedback;

  @override
  State<ExplorerChip> createState() => _ExplorerChipState();
}

class _ExplorerChipState extends State<ExplorerChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enabled && widget.onTap != null) {
      if (widget.hapticFeedback) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = widget.selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.variant == ChipVariant.filter
                ? AppDimensions.sm
                : AppDimensions.md,
            vertical: AppDimensions.xs,
          ),
          decoration: _buildDecoration(isDark, chipColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.avatar != null) ...[
                widget.avatar!,
                const SizedBox(width: AppDimensions.xs),
              ],
              if (widget.variant == ChipVariant.filter && widget.isSelected) ...[
                Icon(
                  Icons.check_rounded,
                  size: AppDimensions.iconXS,
                  color: Colors.white,
                ),
                const SizedBox(width: AppDimensions.xxs),
              ],
              if (widget.icon != null && widget.variant != ChipVariant.filter) ...[
                Icon(
                  widget.icon,
                  size: AppDimensions.iconSM,
                  color: _getTextColor(isDark, chipColor),
                ),
                const SizedBox(width: AppDimensions.xxs),
              ],
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: _getTextColor(isDark, chipColor),
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark, Color chipColor) {
    switch (widget.variant) {
      case ChipVariant.filled:
        return BoxDecoration(
          color: widget.isSelected
              ? chipColor
              : (isDark ? AppColors.surfaceDark : AppColors.mountainSnow),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: widget.isSelected
              ? null
              : Border.all(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  width: 1,
                ),
        );
      case ChipVariant.outlined:
        return BoxDecoration(
          color: widget.isSelected
              ? chipColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: widget.isSelected
                ? chipColor
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: widget.isSelected ? 2 : 1,
          ),
        );
      case ChipVariant.filter:
        return BoxDecoration(
          color: widget.isSelected
              ? chipColor
              : (isDark ? AppColors.surfaceDark : AppColors.mountainSnow),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        );
    }
  }

  Color _getTextColor(bool isDark, Color chipColor) {
    if (widget.isSelected) {
      if (widget.variant == ChipVariant.outlined) {
        return chipColor;
      }
      return Colors.white;
    }
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }
}

enum ChipVariant {
  filled,
  outlined,
  filter,
}

/// Chip group for single selection
class ExplorerChipGroup extends StatelessWidget {
  const ExplorerChipGroup({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.variant = ChipVariant.filled,
    this.spacing = AppDimensions.xs,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ChipVariant variant;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: options.asMap().entries.map((entry) {
        return ExplorerChip(
          label: entry.value,
          isSelected: entry.key == selectedIndex,
          onTap: () => onSelected(entry.key),
          variant: variant,
        );
      }).toList(),
    );
  }
}

/// Chip group for multi selection
class ExplorerMultiChipGroup extends StatelessWidget {
  const ExplorerMultiChipGroup({
    super.key,
    required this.options,
    required this.selectedIndices,
    required this.onToggled,
    this.variant = ChipVariant.filter,
    this.spacing = AppDimensions.xs,
  });

  final List<String> options;
  final Set<int> selectedIndices;
  final ValueChanged<int> onToggled;
  final ChipVariant variant;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: options.asMap().entries.map((entry) {
        return ExplorerChip(
          label: entry.value,
          isSelected: selectedIndices.contains(entry.key),
          onTap: () => onToggled(entry.key),
          variant: variant,
        );
      }).toList(),
    );
  }
}
