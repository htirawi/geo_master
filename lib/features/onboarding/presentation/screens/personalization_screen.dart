import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/backgrounds/onboarding_background.dart';
import '../../../../presentation/providers/onboarding_provider.dart';
import '../../../../presentation/providers/user_preferences_provider.dart'
    show localLearningPreferencesProvider;
import '../../../../presentation/widgets/premium_button.dart';

// Unique accent colors for each interest category
class _InterestColors {
  static const flags = Color(0xFFE53935); // Red
  static const capitals = Color(0xFF1E88E5); // Blue
  static const geography = Color(0xFF43A047); // Green
  static const culture = Color(0xFF8E24AA); // Purple
  static const history = Color(0xFFFFB300); // Amber
  static const languages = Color(0xFF00ACC1); // Teal
}

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.personalizeExperience,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            child: Text(
              l10n.skip,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
      body: OnboardingBackground(
        showFlags: false,
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / pages.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  text:
                      _currentPage < pages.length - 1 ? l10n.next : l10n.letsGo,
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
        ),
      ),
    );
  }

  Future<void> _completePersonalization(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Save user preferences locally
      await ref.read(localLearningPreferencesProvider.notifier).savePreferences(
            interests: _selectedInterests,
            difficulty: _selectedDifficulty,
            dailyGoal: _selectedGoal,
          );

      // Mark personalization as complete
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
    final l10n = AppLocalizations.of(context);

    final interests = [
      _Interest(
        'flags',
        Icons.flag_rounded,
        l10n.interestFlags,
        _InterestColors.flags,
      ),
      _Interest(
        'capitals',
        Icons.location_city_rounded,
        l10n.interestCapitals,
        _InterestColors.capitals,
      ),
      _Interest(
        'culture',
        Icons.museum_rounded,
        l10n.interestCulture,
        _InterestColors.culture,
      ),
      _Interest(
        'geography',
        Icons.terrain_rounded,
        l10n.interestGeography,
        _InterestColors.geography,
      ),
      _Interest(
        'languages',
        Icons.translate_rounded,
        l10n.interestLanguages,
        _InterestColors.languages,
      ),
      _Interest(
        'history',
        Icons.history_edu_rounded,
        l10n.interestHistory,
        _InterestColors.history,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatInterestsYou,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            l10n.selectAtLeastOne,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                final isSelected = selectedInterests.contains(interest.id);
                return _InterestCard(
                  interest: interest,
                  isSelected: isSelected,
                  onTap: () => onInterestToggled(interest.id),
                  index: index,
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
  const _Interest(this.id, this.icon, this.label, this.color);

  final String id;
  final IconData icon;
  final String label;
  final Color color;
}

class _InterestCard extends StatefulWidget {
  const _InterestCard({
    required this.interest,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  final _Interest interest;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  @override
  State<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends State<_InterestCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.interest.color;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : (isSelected ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 2.5 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.1),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Subtle glow effect when selected
              if (isSelected)
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        widget.interest.icon,
                        size: 26,
                        color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Label
                    Text(
                      widget.interest.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Checkmark badge when selected
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(
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
    )
        .animate()
        .fadeIn(delay: (100 + widget.index * 50).ms, duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: (100 + widget.index * 50).ms,
          duration: 400.ms,
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
    final l10n = AppLocalizations.of(context);

    final difficulties = [
      _Difficulty(
        'easy',
        Icons.sentiment_satisfied_rounded,
        l10n.difficultyEasy,
        l10n.difficultyEasyDescription,
        const Color(0xFF4CAF50),
      ),
      _Difficulty(
        'medium',
        Icons.sentiment_neutral_rounded,
        l10n.difficultyMedium,
        l10n.difficultyMediumDescription,
        const Color(0xFFFF9800),
      ),
      _Difficulty(
        'hard',
        Icons.local_fire_department_rounded,
        l10n.difficultyHard,
        l10n.difficultyHardDescription,
        const Color(0xFFF44336),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseDifficulty,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            l10n.canChangeAnytime,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingXL),
          ...difficulties.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _DifficultyCard(
                  difficulty: entry.value,
                  isSelected: selectedDifficulty == entry.value.id,
                  onTap: () => onDifficultySelected(entry.value.id),
                  index: entry.key,
                ),
              )),
        ],
      ),
    );
  }
}

class _Difficulty {
  const _Difficulty(
    this.id,
    this.icon,
    this.label,
    this.description,
    this.color,
  );

  final String id;
  final IconData icon;
  final String label;
  final String description;
  final Color color;
}

class _DifficultyCard extends StatefulWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  final _Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.difficulty.color;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  widget.difficulty.icon,
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.difficulty.label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.difficulty.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 + widget.index * 80).ms, duration: 400.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          delay: (100 + widget.index * 80).ms,
          duration: 400.ms,
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
    final l10n = AppLocalizations.of(context);

    final goals = [
      _Goal(
        'casual',
        Icons.coffee_rounded,
        l10n.goalCasual,
        l10n.goalCasualDescription,
        const Color(0xFF78909C), // Blue Grey
      ),
      _Goal(
        'regular',
        Icons.calendar_today_rounded,
        l10n.goalRegular,
        l10n.goalRegularDescription,
        const Color(0xFF42A5F5), // Blue
      ),
      _Goal(
        'serious',
        Icons.school_rounded,
        l10n.goalSerious,
        l10n.goalSeriousDescription,
        const Color(0xFF7E57C2), // Purple
      ),
      _Goal(
        'intense',
        Icons.rocket_launch_rounded,
        l10n.goalIntense,
        l10n.goalIntenseDescription,
        const Color(0xFFEF5350), // Red
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setYourGoal,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            l10n.howMuchTimePerDay,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingXL),
          ...goals.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  goal: entry.value,
                  isSelected: selectedGoal == entry.value.id,
                  onTap: () => onGoalSelected(entry.value.id),
                  index: entry.key,
                ),
              )),
        ],
      ),
    );
  }
}

class _Goal {
  const _Goal(this.id, this.icon, this.label, this.description, this.color);

  final String id;
  final IconData icon;
  final String label;
  final String description;
  final Color color;
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  final _Goal goal;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.goal.color;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  widget.goal.icon,
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    Text(
                      widget.goal.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 + widget.index * 70).ms, duration: 400.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          delay: (100 + widget.index * 70).ms,
          duration: 400.ms,
        );
  }
}
