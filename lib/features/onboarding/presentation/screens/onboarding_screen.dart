import 'dart:math' as math;

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

/// Premium animated onboarding carousel screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<_OnboardingPageData> _buildPages(AppLocalizations l10n) {
    return [
      _OnboardingPageData(
        illustration: '🌍',
        title: l10n.onboardingExploreTitle,
        description: l10n.onboardingExploreDescription,
        color: AppColors.primary,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        ),
      ),
      _OnboardingPageData(
        illustration: '🧠',
        title: l10n.onboardingQuizTitle,
        description: l10n.onboardingQuizDescription,
        color: AppColors.secondary,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFEF6C00)],
        ),
      ),
      _OnboardingPageData(
        illustration: '🤖',
        title: l10n.onboardingAiTitle,
        description: l10n.onboardingAiDescription,
        color: AppColors.tertiary,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26A69A), Color(0xFF00796B)],
        ),
      ),
      _OnboardingPageData(
        illustration: '🏆',
        title: l10n.onboardingAchievementsTitle,
        description: l10n.onboardingAchievementsDescription,
        color: AppColors.xpGold,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(isArabicProvider);
    final size = MediaQuery.of(context).size;
    final pages = _buildPages(l10n);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              pages[_currentPage].color.withValues(alpha: 0.05),
              Colors.white,
              pages[_currentPage].color.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildParticles(size, pages[_currentPage].color),
              Column(
                children: [
                  _buildSkipButton(l10n, isArabic, pages[_currentPage].color),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(AppLocalizations l10n, bool isArabic, Color color) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Align(
        alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
        child: TextButton(
          onPressed: () => _completeOnboarding(context),
          child: Text(
            l10n.skip,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: isArabic ? -0.2 : 0.2, end: 0),
      ),
    );
  }

  Widget _buildParticles(Size size, Color color) {
    final random = math.Random(123);
    return Stack(
      children: List.generate(20, (index) {
        final x = random.nextDouble();
        final y = random.nextDouble();
        final particleSize = 4.0 + random.nextDouble() * 6;

        return AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            final progress =
                (_particleController.value + (index * 0.05)) % 1.0;
            return Positioned(
              left: x * size.width,
              top: ((y + progress) % 1.0) * size.height,
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1 + random.nextDouble() * 0.1),
                ),
              ),
            );
          },
        );
      }),
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

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });

  final String illustration;
  final String title;
  final String description;
  final Color color;
  final Gradient gradient;
}

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

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: AppDimensions.spacingXXL),
          _buildTitle(theme),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildDescription(theme),
        ],
      ),
    );
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
              data.color.withValues(alpha: 0.15),
              data.color.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.5, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: data.color.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color.withValues(alpha: 0.1),
                    data.color.withValues(alpha: 0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  data.illustration,
                  style: const TextStyle(fontSize: 60),
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
        color: data.color,
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
        color: AppColors.textSecondaryLight,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    )
        .animate(target: isActive ? 1 : 0)
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms);
  }
}

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
        color: isActive ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
