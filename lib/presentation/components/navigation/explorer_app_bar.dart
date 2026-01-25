import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer App Bar - Themed app bar for the Explorer's Journey
///
/// Features:
/// - Multiple variants (standard, large, transparent, gradient)
/// - Animated title transitions
/// - Custom leading/trailing actions
/// - Parallax header support
/// - Glass morphism effect
class ExplorerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExplorerAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.variant = AppBarVariant.standard,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackPressed,
    this.showBackButton = false,
  });

  /// Transparent variant for use over images
  const ExplorerAppBar.transparent({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.onBackPressed,
    this.showBackButton = true,
  })  : variant = AppBarVariant.transparent,
        elevation = 0,
        backgroundColor = null,
        foregroundColor = Colors.white;

  /// Glass morphism variant
  const ExplorerAppBar.glass({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.onBackPressed,
    this.showBackButton = false,
  })  : variant = AppBarVariant.glass,
        elevation = 0,
        backgroundColor = null,
        foregroundColor = null;

  /// Large title variant
  const ExplorerAppBar.large({
    super.key,
    required String this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.onBackPressed,
    this.showBackButton = false,
  })  : variant = AppBarVariant.large,
        centerTitle = false,
        elevation = 0,
        backgroundColor = null,
        foregroundColor = null;

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final AppBarVariant variant;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  @override
  Size get preferredSize => Size.fromHeight(
        variant == AppBarVariant.large ? kToolbarHeight + 40 : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on variant
    Color bgColor;
    Color fgColor;

    switch (variant) {
      case AppBarVariant.standard:
        bgColor = backgroundColor ??
            (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
        fgColor = foregroundColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
      case AppBarVariant.transparent:
        bgColor = Colors.transparent;
        fgColor = foregroundColor ?? Colors.white;
      case AppBarVariant.glass:
        bgColor = Colors.transparent;
        fgColor = foregroundColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
      case AppBarVariant.large:
        bgColor = backgroundColor ??
            (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
        fgColor = foregroundColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    }

    // Build leading widget
    Widget? leadingWidget = leading;
    if (showBackButton && leadingWidget == null) {
      leadingWidget = _buildBackButton(context, fgColor);
    }

    // Build title widget
    Widget? titleContent = titleWidget;
    if (titleContent == null && title != null) {
      titleContent = Text(
        title!,
        style: (variant == AppBarVariant.large
                ? AppTypography.headlineMedium
                : AppTypography.headlineSmall)
            .copyWith(color: fgColor),
      );
    }

    // Apply glass effect if needed
    if (variant == AppBarVariant.glass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurMedium,
            sigmaY: AppDimensions.blurMedium,
          ),
          child: _buildAppBar(
            context,
            bgColor: isDark ? AppColors.glassDark : AppColors.glassWhite,
            fgColor: fgColor,
            leadingWidget: leadingWidget,
            titleContent: titleContent,
          ),
        ),
      );
    }

    return _buildAppBar(
      context,
      bgColor: bgColor,
      fgColor: fgColor,
      leadingWidget: leadingWidget,
      titleContent: titleContent,
    );
  }

  Widget _buildAppBar(
    BuildContext context, {
    required Color bgColor,
    required Color fgColor,
    Widget? leadingWidget,
    Widget? titleContent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: titleContent,
      leading: leadingWidget,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: isDark || variant == AppBarVariant.transparent
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      toolbarHeight: variant == AppBarVariant.large
          ? kToolbarHeight + 40
          : kToolbarHeight,
    );
  }

  Widget _buildBackButton(BuildContext context, Color color) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_rounded,
        color: color,
      ),
      onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

enum AppBarVariant {
  standard,
  transparent,
  glass,
  large,
}

/// Sliver app bar for scrollable headers with parallax
class ExplorerSliverAppBar extends StatelessWidget {
  const ExplorerSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.background,
    this.expandedHeight = 200,
    this.actions,
    this.floating = false,
    this.pinned = true,
    this.stretch = true,
    this.onBackPressed,
  });

  final String title;
  final String? subtitle;
  final Widget? background;
  final double expandedHeight;
  final List<Widget>? actions;
  final bool floating;
  final bool pinned;
  final bool stretch;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      stretch: stretch,
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      foregroundColor:
          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
      ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(
                    blurRadius: 8,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  shadows: [
                    const Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
          ],
        ),
        titlePadding: const EdgeInsets.only(
          left: AppDimensions.lg,
          bottom: AppDimensions.md,
        ),
        background: background ??
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.explorerGradient,
              ),
            ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
    );
  }
}
