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
import '../../../../presentation/components/mascot/mascot.dart';
import '../../../../presentation/providers/onboarding_provider.dart';
import '../../../../presentation/widgets/premium_button.dart';

/// Premium animated onboarding carousel screen with Explorer's Journey theme.
///
/// Features:
/// - 4-page carousel introducing app features
/// - Animated illustrations with pulse effect
/// - Dynamic page indicators
/// - Smooth navigation with haptic feedback
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Set status bar style for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<_OnboardingPageData> _buildPages(AppLocalizations l10n) {
    return [
      _OnboardingPageData(
        icon: Icons.public_rounded,
        title: l10n.onboardingExploreTitle,
        description: l10n.onboardingExploreDescription,
        color: const Color(0xFF4FC3F7), // Globe blue
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
        ),
        atlasState: AtlasState.wave,
        atlasMessage: l10n.atlasWelcome,
      ),
      _OnboardingPageData(
        icon: Icons.explore_rounded,
        title: l10n.onboardingQuizTitle,
        description: l10n.onboardingQuizDescription,
        color: const Color(0xFFFFB74D), // Warm amber
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
        ),
        atlasState: AtlasState.thinking,
        atlasMessage: l10n.atlasQuiz,
      ),
      _OnboardingPageData(
        icon: Icons.travel_explore_rounded,
        title: l10n.onboardingAiTitle,
        description: l10n.onboardingAiDescription,
        color: const Color(0xFF4DB6AC), // Teal
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
        ),
        atlasState: AtlasState.idle,
        atlasMessage: l10n.atlasAskMe,
      ),
      _OnboardingPageData(
        icon: Icons.emoji_events_rounded,
        title: l10n.onboardingAchievementsTitle,
        description: l10n.onboardingAchievementsDescription,
        color: const Color(0xFFFFD54F), // Gold
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
        ),
        atlasState: AtlasState.celebrate,
        atlasMessage: l10n.atlasAchievements,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final pages = _buildPages(l10n);

    return Scaffold(
      body: OnboardingBackground(
        showFlags: true,
        flagCount: 12,
        primaryOrbColor: pages[_currentPage].color,
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(l10n, isArabic),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentPage = page);
                  },
                  itemCount: pages.length,
                  reverse: isArabic,
                  itemBuilder: (context, index) => _OnboardingPage(
                    data: pages[index],
                    isActive: index == _currentPage,
                    pulseController: _pulseController,
                  ),
                ),
              ),
              _buildPageIndicators(pages),
              _buildNavigationButtons(l10n, isArabic, pages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(AppLocalizations l10n, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Align(
        alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
        child: TextButton(
          onPressed: () => _completeOnboarding(context),
          child: Text(
            l10n.skip,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: isArabic ? -0.2 : 0.2, end: 0),
      ),
    );
  }

  Widget _buildPageIndicators(List<_OnboardingPageData> pages) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLG,
        vertical: AppDimensions.paddingMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pages.length,
          (index) => _AnimatedPageIndicator(
            isActive: index == _currentPage,
            color: pages[index].color,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    AppLocalizations l10n,
    bool isArabic,
    List<_OnboardingPageData> pages,
  ) {
    final isLastPage = _currentPage >= pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0) ...[
            PremiumButton(
              text: l10n.back,
              isOutlined: true,
              icon: isArabic ? Icons.arrow_forward : Icons.arrow_back,
              width: 120,
              onPressed: () {
                HapticFeedback.lightImpact();
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
            const SizedBox(width: AppDimensions.spacingMD),
          ],
          // Next/Get Started button
          Expanded(
            child: PremiumButton(
              text: isLastPage ? l10n.getStarted : l10n.next,
              icon: isLastPage
                  ? Icons.rocket_launch
                  : (isArabic ? Icons.arrow_back : Icons.arrow_forward),
              gradient: pages[_currentPage].gradient,
              isLoading: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      if (!isLastPage) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding(context);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(onboardingStateProvider.notifier).completeOnboarding();
      if (context.mounted) {
        context.go(Routes.auth);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(AppLocalizations.of(context).errorUnknown);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppDimensions.md),
      ),
    );
  }
}

/// Data model for onboarding page content
class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
    this.atlasState = AtlasState.idle,
    this.atlasMessage,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Gradient gradient;
  final AtlasState atlasState;
  final String? atlasMessage;
}

/// Individual onboarding page with animated content
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.isActive,
    required this.pulseController,
  });

  final _OnboardingPageData data;
  final bool isActive;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: AppDimensions.spacingLG),
          // Atlas mascot with speech bubble
          if (data.atlasMessage != null)
            _buildAtlasSection(context, isArabic)
          else
            const SizedBox(height: AppDimensions.spacingXL),
          const SizedBox(height: AppDimensions.spacingLG),
          _buildTitle(theme),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildDescription(theme),
        ],
      ),
    );
  }

  Widget _buildAtlasSection(BuildContext context, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        // Atlas mascot
        AtlasAnimated(
          state: data.atlasState,
          size: 60,
        ).animate(target: isActive ? 1 : 0).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(width: 12),
        // Speech bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: data.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              data.atlasMessage!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(
                begin: isArabic ? 0.2 : -0.2,
                end: 0,
                delay: 200.ms,
                duration: 400.ms,
              ),
        ),
      ],
    )
        .animate(target: isActive ? 1 : 0)
        .fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildIllustration() {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + (pulseController.value * 0.05);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              data.color.withValues(alpha: 0.25),
              data.color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.5, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: data.color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            // Inner circle with icon
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color.withValues(alpha: 0.3),
                    data.color.withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: data.color.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      data.color.withValues(alpha: 0.9),
                    ],
                  ).createShader(bounds),
                  child: Icon(
                    data.icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Shine effect
            Positioned(
              top: 30,
              left: 35,
              child: Container(
                width: 30,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      data.title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    )
        .animate(target: isActive ? 1 : 0)
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      data.description,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    )
        .animate(target: isActive ? 1 : 0)
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms);
  }
}

/// Animated page indicator dot
class _AnimatedPageIndicator extends StatelessWidget {
  const _AnimatedPageIndicator({
    required this.isActive,
    required this.color,
  });

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
