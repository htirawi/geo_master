import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/onboarding_provider.dart';
import '../../../../presentation/widgets/premium_button.dart';

/// Personalization screen for user preferences
class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Selected preferences
  final Set<String> _selectedInterests = {};
  String _selectedDifficulty = 'medium';
  String _selectedGoal = 'casual';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final pages = [
      _InterestsPage(
        selectedInterests: _selectedInterests,
        onInterestToggled: (interest) {
          setState(() {
            if (_selectedInterests.contains(interest)) {
              _selectedInterests.remove(interest);
            } else {
              _selectedInterests.add(interest);
            }
          });
        },
      ),
      _DifficultyPage(
        selectedDifficulty: _selectedDifficulty,
        onDifficultySelected: (difficulty) {
          setState(() => _selectedDifficulty = difficulty);
        },
      ),
      _GoalPage(
        selectedGoal: _selectedGoal,
        onGoalSelected: (goal) {
          setState(() => _selectedGoal = goal);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalizeExperience),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              _completePersonalization(context);
            },
            child: Text(l10n.skip),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / pages.length,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          // Page view
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pages.length,
              itemBuilder: (context, index) => pages[index],
            ),
          ),
          // Navigation
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: PremiumButton.primary(
              text: _currentPage < pages.length - 1 ? l10n.next : l10n.letsGo,
              icon: _currentPage < pages.length - 1
                  ? Icons.arrow_forward
                  : Icons.rocket_launch,
              isLoading: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completePersonalization(context);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completePersonalization(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // TODO: Save preferences to user profile (interests, difficulty, goal)
      await ref.read(onboardingStateProvider.notifier).completePersonalization();
      if (context.mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          AppLocalizations.of(context).errorUnknown,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _InterestsPage extends StatelessWidget {
  const _InterestsPage({
    required this.selectedInterests,
    required this.onInterestToggled,
  });

  final Set<String> selectedInterests;
  final ValueChanged<String> onInterestToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final interests = [
      _Interest('capitals', Icons.location_city, l10n.interestCapitals),
      _Interest('flags', Icons.flag, l10n.interestFlags),
      _Interest('geography', Icons.terrain, l10n.interestGeography),
      _Interest('culture', Icons.museum, l10n.interestCulture),
      _Interest('history', Icons.history_edu, l10n.interestHistory),
      _Interest('languages', Icons.translate, l10n.interestLanguages),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatInterestsYou,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            l10n.selectAtLeastOne,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingXL),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.spacingMD,
                mainAxisSpacing: AppDimensions.spacingMD,
                childAspectRatio: 1.2,
              ),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                final isSelected = selectedInterests.contains(interest.id);
                return _InterestCard(
                  interest: interest,
                  isSelected: isSelected,
                  onTap: () => onInterestToggled(interest.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Interest {
  const _Interest(this.id, this.icon, this.label);

  final String id;
  final IconData icon;
  final String label;
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  final _Interest interest;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                interest.icon,
                size: 40,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
              Text(
                interest.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyPage extends StatelessWidget {
  const _DifficultyPage({
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  final String selectedDifficulty;
  final ValueChanged<String> onDifficultySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final difficulties = [
      _Difficulty('easy', l10n.difficultyEasy, l10n.difficultyEasyDescription,
          AppColors.success),
      _Difficulty('medium', l10n.difficultyMedium,
          l10n.difficultyMediumDescription, AppColors.warning),
      _Difficulty('hard', l10n.difficultyHard, l10n.difficultyHardDescription,
          AppColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseDifficulty,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            l10n.canChangeAnytime,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingXL),
          ...difficulties.map((difficulty) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
                child: _DifficultyCard(
                  difficulty: difficulty,
                  isSelected: selectedDifficulty == difficulty.id,
                  onTap: () => onDifficultySelected(difficulty.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _Difficulty {
  const _Difficulty(this.id, this.label, this.description, this.color);

  final String id;
  final String label;
  final String description;
  final Color color;
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  final _Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? difficulty.color.withValues(alpha: 0.1)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: difficulty.color, width: 2),
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: difficulty.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: difficulty.color,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? difficulty.color
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      difficulty.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  const _GoalPage({
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final goals = [
      _Goal('casual', Icons.coffee, l10n.goalCasual, l10n.goalCasualDescription),
      _Goal('regular', Icons.calendar_today, l10n.goalRegular,
          l10n.goalRegularDescription),
      _Goal(
          'serious', Icons.school, l10n.goalSerious, l10n.goalSeriousDescription),
      _Goal('intense', Icons.local_fire_department, l10n.goalIntense,
          l10n.goalIntenseDescription),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setYourGoal,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            l10n.howMuchTimePerDay,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingXL),
          ...goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
                child: _GoalCard(
                  goal: goal,
                  isSelected: selectedGoal == goal.id,
                  onTap: () => onGoalSelected(goal.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _Goal {
  const _Goal(this.id, this.icon, this.label, this.description);

  final String id;
  final IconData icon;
  final String label;
  final String description;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final _Goal goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                )
              : null,
          child: Row(
            children: [
              Icon(
                goal.icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      goal.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
