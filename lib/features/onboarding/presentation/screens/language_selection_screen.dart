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

/// Premium language selection screen with animations
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _globeController;
  late AnimationController _floatController;
  String? _selectedLanguage;
  bool _isLoading = false;

  // Flag emojis for background animation
  static const List<String> _worldFlags = [
    '🇺🇸', '🇬🇧', '🇫🇷', '🇩🇪', '🇯🇵', '🇨🇳', '🇧🇷', '🇮🇳',
    '🇦🇺', '🇨🇦', '🇮🇹', '🇪🇸', '🇷🇺', '🇰🇷', '🇲🇽', '🇸🇦',
    '🇪🇬', '🇿🇦', '🇳🇬', '🇦🇪', '🇹🇷', '🇦🇷', '🇳🇱', '🇸🇪',
  ];

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _globeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF),
              Colors.white,
              Color(0xFFFFF8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated floating flags background
              ..._buildFloatingFlags(size),

              // Main content
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Animated globe logo
                    _buildAnimatedGlobe(),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // App name with shimmer effect
                    _buildAppTitle(theme, l10n),

                    const Spacer(),

                    // Language selection prompt
                    _buildPrompt(theme, l10n),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Language options with stagger animation
                    _buildLanguageOption(
                      language: 'en',
                      title: 'English',
                      subtitle: 'Continue in English',
                      delay: 0,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildLanguageOption(
                      language: 'ar',
                      title: 'العربية',
                      subtitle: 'الاستمرار بالعربية',
                      delay: 150,
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingFlags(Size size) {
    final random = math.Random(42);
    return List.generate(15, (index) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final flagIndex = random.nextInt(_worldFlags.length);
      // Pre-calculate random values ONCE per flag (not per frame)
      final opacity = 0.15 + random.nextDouble() * 0.15;
      final fontSize = 24 + random.nextDouble() * 16;

      return AnimatedBuilder(
        animation: _globeController,
        builder: (context, child) {
          final progress = (_globeController.value + (index * 0.05)) % 1.0;
          final floatY = math.sin(progress * 2 * math.pi) * 20;

          return Positioned(
            left: x,
            top: y + floatY,
            child: child!,
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Text(
            _worldFlags[flagIndex],
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      );
    });
  }

  Widget _buildAnimatedGlobe() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = _floatController.value * 10 - 5;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7),
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Globe shine effect
            Positioned(
              top: 20,
              left: 25,
              child: Container(
                width: 40,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Globe icon
            AnimatedBuilder(
              animation: _globeController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _globeController.value * 2 * math.pi,
                  child: const Icon(
                    Icons.public,
                    size: 70,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppTitle(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ).createShader(bounds),
          child: Text(
            l10n.appName,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 8),
        Text(
          'أطلس العالم',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Cairo',
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildPrompt(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.chooseYourLanguage,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'اختر لغتك المفضلة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 500.ms);
  }

  Widget _buildLanguageOption({
    required String language,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final isArabic = language == 'ar';
    final isSelected = _selectedLanguage == language;

    final scaleValue = isSelected ? 1.02 : 1.0;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $subtitle',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..setEntry(0, 0, scaleValue)
          ..setEntry(1, 1, scaleValue),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            excludeFromSemantics: true,
            onTap: () => _selectLanguage(context, language),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 20 : 10,
                    offset: Offset(0, isSelected ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  // Language icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.translate,
                      size: 28,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: isArabic ? 'Cairo' : null,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontFamily: isArabic ? 'Cairo' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected && _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isSelected ? Icons.check : Icons.arrow_forward_ios,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: isSelected ? 20 : 18,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 800 + delay), duration: 400.ms)
        .slideX(
          begin: isArabic ? -0.2 : 0.2,
          end: 0,
          delay: Duration(milliseconds: 800 + delay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Future<void> _selectLanguage(BuildContext context, String language) async {
    if (_isLoading) return;

    setState(() {
      _selectedLanguage = language;
      _isLoading = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Small delay for visual feedback
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      await ref.read(onboardingStateProvider.notifier).setLanguage(language);
      if (context.mounted) {
        context.go(Routes.onboarding);
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
