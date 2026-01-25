import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Bottom Navigation - Compass-themed navigation bar
///
/// Features:
/// - Glass morphism effect
/// - Elevated center action (Quiz)
/// - Animated tab indicators
/// - Badge support
/// - Haptic feedback
class ExplorerBottomNav extends StatelessWidget {
  const ExplorerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
    this.showLabels = true,
    this.hapticFeedback = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ExplorerNavItem> items;
  final bool showLabels;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.bottomNavRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurHeavy,
            sigmaY: AppDimensions.blurHeavy,
          ),
          child: Container(
            height: AppDimensions.bottomNavHeight,
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDark : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(AppDimensions.bottomNavRadius),
              border: Border.all(
                color: AppColors.glassStroke,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;
                final isCenter = item.isElevated;

                return Expanded(
                  child: _NavItem(
                    item: item,
                    isSelected: isSelected,
                    isCenter: isCenter,
                    showLabel: showLabels,
                    onTap: () {
                      if (hapticFeedback) {
                        HapticFeedback.selectionClick();
                      }
                      onTap(index);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.isCenter,
    required this.showLabel,
    required this.onTap,
  });

  final ExplorerNavItem item;
  final bool isSelected;
  final bool isCenter;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    if (widget.isCenter) {
      return _buildCenterItem(isDark);
    }

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.item.label,
      child: GestureDetector(
        onTapDown: (_) {
          if (!_reduceMotion) _controller.forward();
        },
        onTapUp: (_) {
          if (!_reduceMotion) _controller.reverse();
        },
        onTapCancel: () {
          if (!_reduceMotion) _controller.reverse();
        },
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _reduceMotion ? 1.0 : _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            // Ensure minimum touch target of 44x44
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: _reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: widget.isSelected
                          ? BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSM),
                            )
                          : null,
                      child: Icon(
                        widget.isSelected
                            ? widget.item.activeIcon ?? widget.item.icon
                            : widget.item.icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    if (widget.item.badge != null)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: widget.item.badge!,
                      ),
                  ],
                ),
                if (widget.showLabel) ...[
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: _reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10,
                    ),
                    child: Text(widget.item.label),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem(bool isDark) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.item.label,
      child: GestureDetector(
        onTapDown: (_) {
          if (!_reduceMotion) _controller.forward();
        },
        onTapUp: (_) {
          if (!_reduceMotion) _controller.reverse();
        },
        onTapCancel: () {
          if (!_reduceMotion) _controller.reverse();
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _reduceMotion ? 1.0 : _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            // Ensure minimum touch target of 48x48 for center item
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: widget.isSelected
                        ? AppColors.explorerGradient
                        : LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.primary,
                            ],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isSelected
                        ? widget.item.activeIcon ?? widget.item.icon
                        : widget.item.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                if (widget.showLabel) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.item.label,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      color: widget.isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item configuration
class ExplorerNavItem {
  const ExplorerNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
    this.isElevated = false,
  });

  final IconData icon;
  final String label;
  final IconData? activeIcon;
  final Widget? badge;
  final bool isElevated;
}

/// Badge widget for nav items
class NavBadge extends StatelessWidget {
  const NavBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.color,
  });

  /// Dot-only badge
  const NavBadge.dot({
    super.key,
    this.color,
  })  : count = null,
        showDot = true;

  final int? count;
  final bool showDot;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.error;

    if (showDot || count == null) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count! > 99 ? '99+' : count.toString(),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Default explorer navigation items
class ExplorerNavItems {
  static const home = ExplorerNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  );

  static const atlas = ExplorerNavItem(
    icon: Icons.public_outlined,
    activeIcon: Icons.public_rounded,
    label: 'Atlas',
  );

  static const quiz = ExplorerNavItem(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    label: 'Quiz',
    isElevated: true,
  );

  static const stats = ExplorerNavItem(
    icon: Icons.insights_outlined,
    activeIcon: Icons.insights_rounded,
    label: 'Stats',
  );

  static const profile = ExplorerNavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  );

  static const defaultItems = [home, atlas, quiz, stats, profile];
}
