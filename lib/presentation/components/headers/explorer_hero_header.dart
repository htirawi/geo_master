import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Hero header component for main app screens.
///
/// Features:
/// - Consistent gradient backgrounds
/// - Decorative patterns
/// - Optional search field
/// - Action buttons
/// - Time-based greeting support
class ExplorerHeroHeader extends StatelessWidget {
  const ExplorerHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.gradient,
    this.height = 180,
    this.icon,
    this.leadingAction,
    this.trailingActions = const [],
    this.backgroundWidget,
    this.showPattern = true,
    this.patternColor,
    this.patternIcon,
    this.searchController,
    this.onSearchChanged,
    this.searchHint,
    this.onClearSearch,
  });

  /// Header with search functionality
  factory ExplorerHeroHeader.withSearch({
    Key? key,
    required String title,
    String? subtitle,
    Gradient? gradient,
    double height = 220,
    Widget? icon,
    Widget? leadingAction,
    List<Widget> trailingActions = const [],
    Widget? backgroundWidget,
    bool showPattern = true,
    Color? patternColor,
    IconData? patternIcon,
    required TextEditingController searchController,
    required ValueChanged<String> onSearchChanged,
    String? searchHint,
    VoidCallback? onClearSearch,
  }) {
    return ExplorerHeroHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      gradient: gradient,
      height: height,
      icon: icon,
      leadingAction: leadingAction,
      trailingActions: trailingActions,
      backgroundWidget: backgroundWidget,
      showPattern: showPattern,
      patternColor: patternColor,
      patternIcon: patternIcon,
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      searchHint: searchHint,
      onClearSearch: onClearSearch,
    );
  }

  final String title;
  final String? subtitle;
  final Gradient? gradient;
  final double height;
  final Widget? icon;
  final Widget? leadingAction;
  final List<Widget> trailingActions;
  final Widget? backgroundWidget;
  final bool showPattern;
  final Color? patternColor;
  final IconData? patternIcon;

  // Search fields
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final VoidCallback? onClearSearch;

  bool get _hasSearch => searchController != null && onSearchChanged != null;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryGradient;

    return Container(
      height: height,
      decoration: BoxDecoration(gradient: effectiveGradient),
      child: Stack(
        children: [
          // Pattern background
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroPatternPainter(
                  color: patternColor ?? Colors.white.withValues(alpha: 0.05),
                  icon: patternIcon,
                ),
              ),
            ),
          // Custom background widget
          if (backgroundWidget != null) backgroundWidget!,
          // Decorative icon
          if (patternIcon != null)
            Positioned(
              right: -30,
              top: 60,
              child: Icon(
                patternIcon,
                size: 160,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with actions
                  Row(
                    children: [
                      if (leadingAction != null) ...[
                        leadingAction!,
                        const SizedBox(width: AppDimensions.spacingMD),
                      ],
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: AppDimensions.spacingMD),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).animate().fadeIn(duration: 400.ms),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                            ],
                          ],
                        ),
                      ),
                      ...trailingActions,
                    ],
                  ),
                  // Search field
                  if (_hasSearch) ...[
                    const Spacer(),
                    _buildSearchField(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final hasQuery = searchController?.text.isNotEmpty ?? false;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: searchHint ?? 'Search...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: onClearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMD,
            vertical: AppDimensions.paddingSM,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

/// Header action button
class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Stack(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header icon container
class HeaderIconContainer extends StatelessWidget {
  const HeaderIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.size = 28,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Icon(icon, color: color ?? Colors.white, size: size),
    );
  }
}

/// Pattern painter for hero headers
class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter({
    required this.color,
    this.icon,
  });

  final Color color;
  final IconData? icon;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle grid pattern
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Predefined header gradient themes
class HeaderGradients {
  HeaderGradients._();

  /// Explorer blue gradient (Home/Dashboard)
  static const explorer = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF002171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Atlas teal gradient (Country Explorer)
  static const atlas = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF00695C), Color(0xFF004D40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Journal brown gradient (Stats)
  static const journal = LinearGradient(
    colors: [Color(0xFF5D4037), Color(0xFF795548), Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Passport ocean gradient (Profile)
  static const passport = LinearGradient(
    colors: [Color(0xFF0277BD), Color(0xFF0288D1), Color(0xFF039BE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Quiz purple gradient
  static const quiz = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Achievement gold gradient
  static const achievement = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFFA000), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
