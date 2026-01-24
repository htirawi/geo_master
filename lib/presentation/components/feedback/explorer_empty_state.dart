import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../buttons/explorer_button.dart';

/// Explorer Empty State - Placeholder for empty content
///
/// Features:
/// - Geography-themed illustrations
/// - Customizable message and actions
/// - Multiple preset variants
/// - Animated illustrations option
class ExplorerEmptyState extends StatelessWidget {
  const ExplorerEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  /// No countries found
  const ExplorerEmptyState.noCountries({
    super.key,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'No countries found',
        message = 'Try adjusting your search or filters',
        icon = Icons.public_off_rounded,
        illustration = null;

  /// No results
  const ExplorerEmptyState.noResults({
    super.key,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'No results',
        message = 'We couldn\'t find what you\'re looking for',
        icon = Icons.search_off_rounded,
        illustration = null;

  /// No quiz history
  const ExplorerEmptyState.noQuizHistory({
    super.key,
    this.actionLabel = 'Start Quiz',
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'No quiz history yet',
        message = 'Complete quizzes to see your progress here',
        icon = Icons.quiz_outlined,
        illustration = null;

  /// No achievements
  const ExplorerEmptyState.noAchievements({
    super.key,
    this.actionLabel = 'Start Exploring',
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'No achievements yet',
        message = 'Complete challenges to earn badges and rewards',
        icon = Icons.emoji_events_outlined,
        illustration = null;

  /// No bookmarks
  const ExplorerEmptyState.noBookmarks({
    super.key,
    this.actionLabel = 'Browse Countries',
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'No bookmarks yet',
        message = 'Save countries you want to explore later',
        icon = Icons.bookmark_border_rounded,
        illustration = null;

  /// Offline
  const ExplorerEmptyState.offline({
    super.key,
    this.actionLabel = 'Try Again',
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'You\'re offline',
        message = 'Connect to the internet to continue exploring',
        icon = Icons.wifi_off_rounded,
        illustration = null;

  /// Error state
  const ExplorerEmptyState.error({
    super.key,
    this.actionLabel = 'Try Again',
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.message = 'Something went wrong. Please try again.',
  })  : title = 'Oops!',
        icon = Icons.error_outline_rounded,
        illustration = null;

  /// Coming soon
  const ExplorerEmptyState.comingSoon({
    super.key,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  })  : title = 'Coming Soon',
        message = 'We\'re working on something exciting!',
        icon = Icons.construction_rounded,
        illustration = null;

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration or icon
          if (illustration != null)
            illustration!
          else if (icon != null)
            _buildIconContainer(isDark),

          const SizedBox(height: AppDimensions.lg),

          // Title
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          // Message
          if (message != null) ...[
            const SizedBox(height: AppDimensions.xs),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Actions
          if (actionLabel != null || secondaryActionLabel != null) ...[
            const SizedBox(height: AppDimensions.xl),
            if (actionLabel != null)
              ExplorerButton(
                onPressed: onAction ?? () {},
                label: actionLabel!,
                isExpanded: false,
              ),
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: AppDimensions.sm),
              ExplorerButton.ghost(
                onPressed: onSecondaryAction ?? () {},
                label: secondaryActionLabel!,
                isExpanded: false,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 56,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Animated empty state with subtle animation
class AnimatedEmptyState extends StatefulWidget {
  const AnimatedEmptyState({
    super.key,
    required this.child,
  });

  final ExplorerEmptyState child;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
