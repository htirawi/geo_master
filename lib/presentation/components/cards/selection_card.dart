import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Selection card variants for different selection types
enum SelectionCardVariant {
  /// Large card with icon - for language selection
  language,

  /// Grid card with icon and checkmark - for multi-select interests
  interest,

  /// List card with radio indicator - for single-select options
  radio,

  /// Compact card for settings selections
  compact,
}

/// Reusable selection card for onboarding and settings screens.
///
/// Supports multiple variants:
/// - [SelectionCardVariant.language] - Large cards for language selection
/// - [SelectionCardVariant.interest] - Grid cards with checkmark for multi-select
/// - [SelectionCardVariant.radio] - List cards with radio for single-select
/// - [SelectionCardVariant.compact] - Compact cards for settings
class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.iconWidget,
    this.variant = SelectionCardVariant.radio,
    this.accentColor,
    this.isLoading = false,
    this.animationDelay = Duration.zero,
    this.showArrow = false,
  });

  /// Card title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Icon to display
  final IconData? icon;

  /// Custom icon widget (takes precedence over icon)
  final Widget? iconWidget;

  /// Whether this card is selected
  final bool isSelected;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Card variant
  final SelectionCardVariant variant;

  /// Custom accent color for selected state
  final Color? accentColor;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Animation delay for entrance animation
  final Duration animationDelay;

  /// Whether to show arrow indicator (for language cards)
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      SelectionCardVariant.language => _buildLanguageCard(context),
      SelectionCardVariant.interest => _buildInterestCard(context),
      SelectionCardVariant.radio => _buildRadioCard(context),
      SelectionCardVariant.compact => _buildCompactCard(context),
    };
  }

  Widget _buildLanguageCard(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: Stack(
            children: [
              // Glow effect when selected
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveAccent.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
              // Main container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            effectiveAccent.withValues(alpha: 0.2),
                            effectiveAccent.withValues(alpha: 0.08),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  border: Border.all(
                    color: isSelected
                        ? effectiveAccent.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [effectiveAccent, effectiveAccent.withValues(alpha: 0.7)]
                              : [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: effectiveAccent.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: iconWidget ??
                              Icon(
                                isSelected
                                    ? Icons.check_rounded
                                    : (icon ?? Icons.language_rounded),
                                key: ValueKey('$title-$isSelected'),
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                                size: isSelected ? 26 : 24,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.9),
                              fontSize: 26,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          // Progress bar
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 3,
                            width: isSelected ? 80 : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        effectiveAccent,
                                        effectiveAccent.withValues(alpha: 0.2)
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.white.withValues(alpha: 0.05),
                                      ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow or loading
                    if (showArrow)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                        child: isSelected && isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(effectiveAccent),
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_rounded,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 22,
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay, duration: 500.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          delay: animationDelay,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: animationDelay,
          duration: 500.ms,
        );
  }

  Widget _buildInterestCard(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.98,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        effectiveAccent.withValues(alpha: 0.25),
                        effectiveAccent.withValues(alpha: 0.1),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
              ),
              border: Border.all(
                color: isSelected
                    ? effectiveAccent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: effectiveAccent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? effectiveAccent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                        child: iconWidget ??
                            Icon(
                              icon ?? Icons.star,
                              size: 28,
                              color: isSelected
                                  ? effectiveAccent
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkmark badge
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: effectiveAccent,
                        boxShadow: [
                          BoxShadow(
                            color: effectiveAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 200.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay, duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: animationDelay,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildRadioCard(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      effectiveAccent.withValues(alpha: 0.2),
                      effectiveAccent.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
            ),
            border: Border.all(
              color: isSelected
                  ? effectiveAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? effectiveAccent
                        : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: effectiveAccent,
                          ),
                        ).animate().scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                              duration: 150.ms,
                            ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.md),
              // Icon (optional)
              if (icon != null || iconWidget != null) ...[
                iconWidget ??
                    Icon(
                      icon,
                      size: 24,
                      color: isSelected
                          ? effectiveAccent
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                const SizedBox(width: AppDimensions.sm),
              ],
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay, duration: 400.ms)
        .slideX(
          begin: 0.05,
          end: 0,
          delay: animationDelay,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCompactCard(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            color: isSelected
                ? effectiveAccent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: isSelected
                  ? effectiveAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null || iconWidget != null) ...[
                iconWidget ??
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? effectiveAccent
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                const SizedBox(width: AppDimensions.xs),
              ],
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppDimensions.xs),
                Icon(
                  Icons.check,
                  size: 16,
                  color: effectiveAccent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
