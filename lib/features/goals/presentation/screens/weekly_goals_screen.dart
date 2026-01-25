import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/weekly_goal.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';
import '../../../../presentation/providers/weekly_goals_provider.dart';

/// Weekly goals screen with goal list and progress tracking
class WeeklyGoalsScreen extends ConsumerStatefulWidget {
  const WeeklyGoalsScreen({super.key});

  @override
  ConsumerState<WeeklyGoalsScreen> createState() => _WeeklyGoalsScreenState();
}

class _WeeklyGoalsScreenState extends ConsumerState<WeeklyGoalsScreen> {
  // Mock user ID for demo
  static const _userId = 'current_user';

  void _showAddGoalDialog() {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddGoalBottomSheet(
        userId: _userId,
        isArabic: isArabic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final weeklyGoals = ref.watch(weeklyGoalsNotifierProvider(_userId));
    final daysRemaining = ref.watch(weekDaysRemainingProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _WeeklyGoalsHeader(
              isArabic: isArabic,
              daysRemaining: daysRemaining,
            ),
          ),
          // Progress summary
          SliverToBoxAdapter(
            child: weeklyGoals.when(
              data: (progress) => _ProgressSummary(
                progress: progress,
                isArabic: isArabic,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ),
          // Goals list
          weeklyGoals.when(
            data: (progress) => progress.goals.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyGoalsState(
                      l10n: l10n,
                      onAddGoal: _showAddGoalDialog,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = progress.sortedGoals[index];
                          return _GoalCard(
                            goal: goal,
                            isArabic: isArabic,
                            onRemove: goal.isCustom
                                ? () {
                                    ref
                                        .read(weeklyGoalsNotifierProvider(_userId)
                                            .notifier)
                                        .removeGoal(goal.id);
                                  }
                                : null,
                          ).animate(delay: (index * 50).ms).fadeIn().slideY(
                                begin: 0.1,
                                end: 0,
                              );
                        },
                        childCount: progress.goals.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.addGoal),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Weekly goals header
class _WeeklyGoalsHeader extends StatelessWidget {
  const _WeeklyGoalsHeader({
    required this.isArabic,
    required this.daysRemaining,
  });

  final bool isArabic;
  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.explorer,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: responsive.insets(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    l10n.weeklyGoalsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$daysRemaining ${l10n.daysLeft}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                l10n.weeklyGoalsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress summary section
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.progress,
    required this.isArabic,
  });

  final WeeklyGoalsProgress progress;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Padding(
      padding: responsive.insets(AppDimensions.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                    value: '${progress.completedGoalsCount}/${progress.goals.length}',
                    label: l10n.goalsCompleted,
                  ),
                  _SummaryItem(
                    icon: Icons.stars,
                    iconColor: AppColors.xpGold,
                    value: '${progress.totalXpEarned}',
                    label: l10n.xpEarned,
                  ),
                  _SummaryItem(
                    icon: Icons.trending_up,
                    iconColor: AppColors.primary,
                    value: progress.completionRateString,
                    label: l10n.completionRate,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.overallProgress,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                progress.getOverallProgressString(isArabic),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}

/// Summary item widget
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Goal card widget
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isArabic,
    this.onRemove,
  });

  final WeeklyGoal goal;
  final bool isArabic;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: goal.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    goal.type.iconData,
                    color: goal.type.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.getTitle(isArabic),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        goal.getDescription(isArabic),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                else if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 18,
                    color: AppColors.textHintLight,
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progressPercentage,
                          backgroundColor: goal.type.color.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(goal.type.color),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.currentValue} / ${goal.targetValue}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${(goal.progressPercentage * 100).round()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: goal.type.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars,
                        color: AppColors.xpGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${goal.totalXpReward}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.xpGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(goal.difficulty).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    goal.difficulty.getName(isArabic),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getDifficultyColor(goal.difficulty),
                    ),
                  ),
                ),
                if (goal.isCustom) ...[
                  const SizedBox(width: AppDimensions.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.customGoal,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
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
        return AppColors.success;
      case GoalDifficulty.medium:
        return Colors.orange;
      case GoalDifficulty.hard:
        return AppColors.error;
      case GoalDifficulty.extreme:
        return Colors.purple;
    }
  }
}

/// Empty goals state
class _EmptyGoalsState extends StatelessWidget {
  const _EmptyGoalsState({
    required this.l10n,
    required this.onAddGoal,
  });

  final AppLocalizations l10n;
  final VoidCallback onAddGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            l10n.noGoalsYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            l10n.setWeeklyGoals,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textHintLight,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          FilledButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(Icons.add),
            label: Text(l10n.addGoal),
          ),
        ],
      ),
    );
  }
}

/// Add goal bottom sheet
class _AddGoalBottomSheet extends ConsumerStatefulWidget {
  const _AddGoalBottomSheet({
    required this.userId,
    required this.isArabic,
  });

  final String userId;
  final bool isArabic;

  @override
  ConsumerState<_AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends ConsumerState<_AddGoalBottomSheet> {
  WeeklyGoalPreset? _selectedPreset;
  GoalDifficulty _selectedDifficulty = GoalDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLG),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHintLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                l10n.addGoal,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              // Difficulty selector
              Text(
                l10n.selectDifficulty,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Wrap(
                spacing: AppDimensions.sm,
                children: GoalDifficulty.values.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return ChoiceChip(
                    label: Text(difficulty.getName(widget.isArabic)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDifficulty = difficulty);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                l10n.selectGoalType,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: WeeklyGoalPreset.allPresets.length,
                  itemBuilder: (context, index) {
                    final preset = WeeklyGoalPreset.allPresets[index];
                    final isSelected = _selectedPreset == preset;
                    final target =
                        preset.getTargetForDifficulty(_selectedDifficulty);

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                      color: isSelected
                          ? preset.type.color.withValues(alpha: 0.1)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                        side: isSelected
                            ? BorderSide(color: preset.type.color, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: preset.type.color.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSM),
                          ),
                          child: Icon(
                            preset.type.iconData,
                            color: preset.type.color,
                          ),
                        ),
                        title: Text(preset.getName(widget.isArabic)),
                        subtitle: Text(
                          '${l10n.target}: $target',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: Text(
                          '+${(preset.baseXpReward * _selectedDifficulty.xpMultiplier).round()} XP',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.xpGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          setState(() => _selectedPreset = preset);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedPreset != null
                      ? () {
                          ref
                              .read(weeklyGoalsNotifierProvider(widget.userId)
                                  .notifier)
                              .addCustomGoal(_selectedPreset!, _selectedDifficulty);
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(l10n.addGoal),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
