import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final horizontalPadding = responsive.sp(24);
    final progressRadius = responsive.sp(4);
    final progressHeight = responsive.sp(6);
    final spacingSM = responsive.sp(8);
    final paddingLG = responsive.sp(AppDimensions.paddingLG);

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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(progressRadius),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / pages.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: progressHeight,
                  ),
                ),
              ),
              SizedBox(height: spacingSM),
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
                padding: EdgeInsets.all(paddingLG),
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
    final responsive = ResponsiveUtils.of(context);
    final sm = responsive.sp(AppDimensions.sm);
    final md = responsive.sp(AppDimensions.md);
    final radius = responsive.sp(12);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        margin: EdgeInsets.all(md),
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final paddingLG = responsive.sp(AppDimensions.paddingLG);
    final titleFontSize = responsive.sp(22);
    final subtitleFontSize = responsive.sp(13);
    final gridSpacing = responsive.sp(14);

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
      padding: EdgeInsets.all(paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatInterestsYou,
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          SizedBox(height: responsive.sp(4)),
          Text(
            l10n.selectAtLeastOne,
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          SizedBox(height: responsive.sp(12)),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final radiusXL = responsive.sp(AppDimensions.radiusXL);
    final iconContainerSize = responsive.sp(52);
    final iconSize = responsive.sp(26);
    final labelFontSize = responsive.sp(14);
    final checkSize = responsive.sp(24);
    final checkIconSize = responsive.sp(16);
    final glowSize = responsive.sp(60);

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
            borderRadius: BorderRadius.circular(radiusXL),
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
                      blurRadius: responsive.sp(12),
                      spreadRadius: 0,
                      offset: Offset(0, responsive.sp(4)),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Subtle glow effect when selected
              if (isSelected)
                Positioned(
                  top: responsive.sp(-20),
                  right: responsive.sp(-20),
                  child: Container(
                    width: glowSize,
                    height: glowSize,
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
                      width: iconContainerSize,
                      height: iconContainerSize,
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
                        size: iconSize,
                        color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: responsive.sp(10)),
                    // Label
                    Text(
                      widget.interest.label,
                      style: GoogleFonts.poppins(
                        fontSize: labelFontSize,
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
                  top: responsive.sp(8),
                  right: responsive.sp(8),
                  child: Container(
                    width: checkSize,
                    height: checkSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: responsive.sp(4),
                          offset: Offset(0, responsive.sp(2)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: checkIconSize,
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final paddingLG = responsive.sp(AppDimensions.paddingLG);
    final titleFontSize = responsive.sp(24);
    final subtitleFontSize = responsive.sp(14);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final spacingXL = responsive.sp(AppDimensions.spacingXL);
    final cardSpacing = responsive.sp(14);

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
      padding: EdgeInsets.all(paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseDifficulty,
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          SizedBox(height: spacingSM),
          Text(
            l10n.canChangeAnytime,
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          SizedBox(height: spacingXL),
          ...difficulties.asMap().entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: cardSpacing),
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final paddingMD = responsive.sp(AppDimensions.md);
    final radiusLG = responsive.sp(AppDimensions.radiusLG);
    final iconContainerSize = responsive.sp(52);
    final iconContainerRadius = responsive.sp(14);
    final iconSize = responsive.sp(26);
    final spacingMD = responsive.sp(AppDimensions.md);
    final labelFontSize = responsive.sp(16);
    final descFontSize = responsive.sp(13);
    final radioSize = responsive.sp(24);
    final checkIconSize = responsive.sp(16);
    final blurRadius = responsive.sp(10);
    final shadowOffset = responsive.sp(4);

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
          padding: EdgeInsets.all(paddingMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLG),
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
                      blurRadius: blurRadius,
                      offset: Offset(0, shadowOffset),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(iconContainerRadius),
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
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacingMD),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.difficulty.label,
                      style: GoogleFonts.poppins(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    SizedBox(height: responsive.sp(2)),
                    Text(
                      widget.difficulty.description,
                      style: GoogleFonts.poppins(
                        fontSize: descFontSize,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: radioSize,
                height: radioSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: checkIconSize,
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final paddingLG = responsive.sp(AppDimensions.paddingLG);
    final titleFontSize = responsive.sp(24);
    final subtitleFontSize = responsive.sp(14);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final spacingXL = responsive.sp(AppDimensions.spacingXL);
    final cardSpacing = responsive.sp(12);

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
      padding: EdgeInsets.all(paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setYourGoal,
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          SizedBox(height: spacingSM),
          Text(
            l10n.howMuchTimePerDay,
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
          SizedBox(height: spacingXL),
          ...goals.asMap().entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: cardSpacing),
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

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final radiusLG = responsive.sp(AppDimensions.radiusLG);
    final radiusMD = responsive.sp(AppDimensions.radiusMD);
    final horizontalPadding = responsive.sp(16);
    final verticalPadding = responsive.sp(14);
    final iconContainerSize = responsive.sp(44);
    final iconSize = responsive.sp(22);
    final spacing = responsive.sp(14);
    final labelFontSize = responsive.sp(15);
    final descFontSize = responsive.sp(12);
    final radioSize = responsive.sp(22);
    final checkIconSize = responsive.sp(14);
    final blurRadius = responsive.sp(10);
    final shadowOffset = responsive.sp(4);

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
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLG),
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
                      blurRadius: blurRadius,
                      offset: Offset(0, shadowOffset),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radiusMD),
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
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.label,
                      style: GoogleFonts.poppins(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    Text(
                      widget.goal.description,
                      style: GoogleFonts.poppins(
                        fontSize: descFontSize,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: radioSize,
                height: radioSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: checkIconSize,
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
