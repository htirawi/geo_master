import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Tab Bar - Themed tab navigation
///
/// Features:
/// - Multiple variants (underline, pill, segment)
/// - Animated indicator
/// - Scrollable for many tabs
/// - Badge support
/// - Custom indicator styling
class ExplorerTabBar extends StatelessWidget {
  const ExplorerTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.variant = TabBarVariant.underline,
    this.isScrollable = false,
    this.hapticFeedback = true,
  });

  /// Pill-style tabs
  const ExplorerTabBar.pill({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.isScrollable = false,
    this.hapticFeedback = true,
  }) : variant = TabBarVariant.pill;

  /// Segmented control style
  const ExplorerTabBar.segment({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.isScrollable = false,
    this.hapticFeedback = true,
  }) : variant = TabBarVariant.segment;

  final List<ExplorerTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final TabBarVariant variant;
  final bool isScrollable;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case TabBarVariant.underline:
        return _UnderlineTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTap: onTap,
          isScrollable: isScrollable,
          hapticFeedback: hapticFeedback,
        );
      case TabBarVariant.pill:
        return _PillTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTap: onTap,
          isScrollable: isScrollable,
          hapticFeedback: hapticFeedback,
        );
      case TabBarVariant.segment:
        return _SegmentTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTap: onTap,
          hapticFeedback: hapticFeedback,
        );
    }
  }
}

/// Underline style tab bar
class _UnderlineTabBar extends StatelessWidget {
  const _UnderlineTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    required this.isScrollable,
    required this.hapticFeedback,
  });

  final List<ExplorerTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isScrollable;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildTabs() {
      return Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: _TabItem(
              tab: tab,
              isSelected: isSelected,
              onTap: () {
                if (hapticFeedback) {
                  HapticFeedback.selectionClick();
                }
                onTap(index);
              },
              indicator: _UnderlineIndicator(isSelected: isSelected),
            ),
          );
        }).toList(),
      );
    }

    if (isScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = index == selectedIndex;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < tabs.length - 1 ? AppDimensions.md : 0,
                    ),
                    child: _TabItem(
                      tab: tab,
                      isSelected: isSelected,
                      onTap: () {
                        if (hapticFeedback) {
                          HapticFeedback.selectionClick();
                        }
                        onTap(index);
                      },
                      indicator: _UnderlineIndicator(isSelected: isSelected),
                    ),
                  );
                }).toList(),
              ),
              Container(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTabs(),
        Container(
          height: 1,
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ],
    );
  }
}

/// Pill style tab bar
class _PillTabBar extends StatelessWidget {
  const _PillTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    required this.isScrollable,
    required this.hapticFeedback,
  });

  final List<ExplorerTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isScrollable;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    Widget buildTabs() {
      return Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(
              right: index < tabs.length - 1 ? AppDimensions.xs : 0,
            ),
            child: _PillTabItem(
              tab: tab,
              isSelected: isSelected,
              onTap: () {
                if (hapticFeedback) {
                  HapticFeedback.selectionClick();
                }
                onTap(index);
              },
            ),
          );
        }).toList(),
      );
    }

    if (isScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        child: buildTabs(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: buildTabs(),
    );
  }
}

/// Segment style tab bar
class _SegmentTabBar extends StatelessWidget {
  const _SegmentTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    required this.hapticFeedback,
  });

  final List<ExplorerTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.mountainSnow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (hapticFeedback) {
                  HapticFeedback.selectionClick();
                }
                onTap(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.cardDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: AppDimensions.iconSM,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: AppDimensions.xxs),
                    ],
                    Text(
                      tab.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Individual tab item
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.indicator,
  });

  final ExplorerTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget indicator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.sm,
              horizontal: AppDimensions.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tab.icon != null) ...[
                  Icon(
                    tab.icon,
                    size: AppDimensions.iconSM,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: AppDimensions.xxs),
                ],
                Text(
                  tab.label,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (tab.badge != null) ...[
                  const SizedBox(width: AppDimensions.xxs),
                  tab.badge!,
                ],
              ],
            ),
          ),
          indicator,
        ],
      ),
    );
  }
}

/// Pill tab item
class _PillTabItem extends StatelessWidget {
  const _PillTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final ExplorerTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.mountainSnow),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: isSelected
              ? null
              : Border.all(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: AppDimensions.iconSM,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: AppDimensions.xxs),
            ],
            Text(
              tab.label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: AppDimensions.xxs),
              tab.badge!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Underline indicator
class _UnderlineIndicator extends StatelessWidget {
  const _UnderlineIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 3,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

/// Tab configuration
class ExplorerTab {
  const ExplorerTab({
    required this.label,
    this.icon,
    this.badge,
  });

  final String label;
  final IconData? icon;
  final Widget? badge;
}

enum TabBarVariant {
  underline,
  pill,
  segment,
}

/// Tab badge
class TabBadge extends StatelessWidget {
  const TabBadge({
    super.key,
    required this.count,
    this.color,
  });

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
