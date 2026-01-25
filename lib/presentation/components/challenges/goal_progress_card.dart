import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/weekly_goal.dart';
import '../../providers/weekly_goals_provider.dart';

/// Weekly Goals Progress Card
///
/// Features:
/// - Shows current week's goals
/// - Progress indicators for each goal
/// - Days remaining countdown
/// - Overall completion summary
class WeeklyGoalsCard extends ConsumerWidget {
  const WeeklyGoalsCard({
    super.key,
    required this.userId,
    this.onTap,
    this.compact = false,
    this.maxGoalsShown = 3,
  });

  final String userId;
  final VoidCallback? onTap;
  final bool compact;
  final int maxGoalsShown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(weeklyGoalsProvider(userId));
    final daysRemaining = ref.watch(weekDaysRemainingProvider);

    return goalsAsync.when(
      data: (progress) =>
          _buildCard(context, ref, progress, daysRemaining),
      loading: () => _buildLoadingCard(context),
      error: (_, __) => _buildErrorCard(context),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    WeeklyGoalsProgress progress,
    int daysRemaining,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (progress.goals.isEmpty) {
      return _buildEmptyState(context, isArabic);
    }

    final goalsToShow = progress.sortedGoals.take(maxGoalsShown).toList();
    final hasMoreGoals = progress.goals.length > maxGoalsShown;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, progress, daysRemaining, isArabic),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),

            // Goals list
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: [
                  ...goalsToShow.map(
                    (goal) => _buildGoalItem(context, goal, isArabic),
                  ),
                  if (hasMoreGoals)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.sm),
                      child: Text(
                        isArabic
                            ? '+${progress.goals.length - maxGoalsShown} أهداف أخرى'
                            : '+${progress.goals.length - maxGoalsShown} more goals',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WeeklyGoalsProgress progress,
    int daysRemaining,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: const Icon(
              Icons.flag,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Title and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'أهداف الأسبوع' : 'Weekly Goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress.getOverallProgressString(isArabic),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Days remaining badge
          _buildDaysRemainingBadge(context, daysRemaining, isArabic),
        ],
      ),
    );
  }

  Widget _buildDaysRemainingBadge(
    BuildContext context,
    int daysRemaining,
    bool isArabic,
  ) {
    final theme = Theme.of(context);
    final isUrgent = daysRemaining <= 2;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: isUrgent ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            isArabic ? '$daysRemaining يوم' : '$daysRemaining days',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isUrgent ? AppColors.warning : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(
    BuildContext context,
    WeeklyGoal goal,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          // Goal type icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: goal.isCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : goal.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              goal.isCompleted ? Icons.check_circle : goal.type.iconData,
              size: 18,
              color: goal.isCompleted ? AppColors.success : goal.type.color,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Goal title and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.getTitle(isArabic),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration:
                        goal.isCompleted ? TextDecoration.lineThrough : null,
                    color: goal.isCompleted
                        ? theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: goal.progressPercentage,
                    backgroundColor: goal.type.color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? AppColors.success : goal.type.color,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.sm),

          // Progress text
          Text(
            '${goal.currentValue}/${goal.targetValue}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: goal.isCompleted
                  ? AppColors.success
                  : theme.textTheme.labelSmall?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isArabic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            isArabic ? 'لا توجد أهداف محددة' : 'No goals set',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.textTheme.titleSmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            isArabic
                ? 'حدد أهدافك الأسبوعية للبدء'
                : 'Set your weekly goals to get started',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      height: 160,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppDimensions.sm),
          Text(
            isArabic ? 'تعذر تحميل الأهداف' : 'Failed to load goals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual goal progress tile
class GoalProgressTile extends StatelessWidget {
  const GoalProgressTile({
    super.key,
    required this.goal,
    this.onTap,
    this.showDescription = false,
  });

  final WeeklyGoal goal;
  final VoidCallback? onTap;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: goal.isCompleted
              ? Border.all(color: AppColors.success.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: goal.isCompleted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : goal.type.color.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    goal.isCompleted ? Icons.check_circle : goal.type.iconData,
                    color: goal.isCompleted ? AppColors.success : goal.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),

                // Title
                Expanded(
                  child: Text(
                    goal.getTitle(isArabic),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          goal.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),

                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  child: Text(
                    '+${goal.totalXpReward} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (showDescription) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                goal.getDescription(isArabic),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.sm),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progressPercentage,
                      backgroundColor: goal.type.color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.isCompleted ? AppColors.success : goal.type.color,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  '${goal.currentValue}/${goal.targetValue}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Difficulty badge
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(goal.difficulty)
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  child: Text(
                    goal.difficulty.getName(isArabic),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getDifficultyColor(goal.difficulty),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (goal.daysRemaining > 0)
                  Text(
                    isArabic
                        ? '${goal.daysRemaining} يوم متبقي'
                        : '${goal.daysRemaining} days left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.labelSmall?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return const Color(0xFF4CAF50);
      case GoalDifficulty.medium:
        return const Color(0xFFFF9800);
      case GoalDifficulty.hard:
        return const Color(0xFFF44336);
      case GoalDifficulty.extreme:
        return const Color(0xFF9C27B0);
    }
  }
}
