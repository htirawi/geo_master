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

  // Flag emojis for background animation - includes Arabic countries
  static const List<String> _worldFlags = [
    // Arabic countries
    '🇯🇴', '🇵🇸', '🇸🇦', '🇦🇪', '🇰🇼', '🇱🇧', '🇹🇳', '🇩🇿',
    '🇪🇬', '🇲🇦', '🇮🇶', '🇸🇾', '🇾🇪', '🇴🇲', '🇧🇭', '🇶🇦',
    '🇱🇾', '🇸🇩',
    // World countries
    '🇺🇸', '🇬🇧', '🇫🇷', '🇩🇪', '🇯🇵', '🇨🇳', '🇧🇷', '🇮🇳',
    '🇦🇺', '🇨🇦', '🇮🇹', '🇪🇸', '🇷🇺', '🇰🇷', '🇲🇽', '🇹🇷',
  ];

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
          // Dark gradient matching auth screen
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Gradient orbs for visual depth
              _buildGradientOrbs(),

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

                    // Language options
                    _buildLanguageButton(
                      language: 'en',
                      title: 'English',
                      delay: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageButton(
                      language: 'ar',
                      title: 'العربية',
                      delay: 100,
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
    // Shuffle and take unique flags - no duplicates
    final shuffledFlags = List<String>.from(_worldFlags)..shuffle(random);
    final uniqueFlags = shuffledFlags.take(18).toList();

    return List.generate(uniqueFlags.length, (index) {
      // Distribute flags evenly across the screen
      final col = index % 3;
      final row = index ~/ 3;
      final baseX = (col * size.width / 3) + random.nextDouble() * (size.width / 4);
      final baseY = (row * size.height / 6) + random.nextDouble() * (size.height / 8);
      final opacity = 0.3 + random.nextDouble() * 0.25;
      final fontSize = 28 + random.nextDouble() * 14;

      return AnimatedBuilder(
        animation: _globeController,
        builder: (context, child) {
          final progress = (_globeController.value + (index * 0.06)) % 1.0;
          final floatY = math.sin(progress * 2 * math.pi) * 15;
          final floatX = math.cos(progress * 2 * math.pi + index) * 8;

          return Positioned(
            left: baseX + floatX,
            top: baseY + floatY,
            child: child!,
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Text(
            uniqueFlags[index],
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      );
    });
  }

  // Gradient orbs for visual depth (matching auth screen)
  Widget _buildGradientOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.25),
                  AppColors.secondary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 4.seconds,
            ),
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tertiary.withValues(alpha: 0.15),
                  AppColors.tertiary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1, 1),
              duration: 5.seconds,
            ),
      ],
    );
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
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFF90CAF9), Colors.white],
      ).createShader(bounds),
      child: Text(
        'أطلس العالم',
        style: theme.textTheme.headlineLarge?.copyWith(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 36,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms);
  }

  Widget _buildPrompt(ThemeData theme, AppLocalizations l10n) {
    return Text(
      'Select Language  •  اختر اللغة',
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms);
  }

  Widget _buildLanguageButton({
    required String language,
    required String title,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final isArabic = language == 'ar';
    final isSelected = _selectedLanguage == language;

    // Different accent colors for each language
    final accentColor = isArabic
        ? const Color(0xFFFFD54F) // Warm gold for Arabic
        : const Color(0xFF4FC3F7); // Cool blue for English

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () => _selectLanguage(context, language),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: Stack(
            children: [
              // Animated gradient border glow
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
              // Main button container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            accentColor.withValues(alpha: 0.2),
                            accentColor.withValues(alpha: 0.08),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Animated icon on the left
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
                              ? [accentColor, accentColor.withValues(alpha: 0.7)]
                              : [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.language_rounded,
                            key: ValueKey('$language-$isSelected'),
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                            size: isSelected ? 26 : 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Language title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: isArabic ? 'Cairo' : null,
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                              fontSize: 26,
                              letterSpacing: isArabic ? 0 : 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Animated progress bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 3,
                            width: isSelected ? 80 : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [accentColor, accentColor.withValues(alpha: 0.2)]
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
                    // Arrow indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                      child: isSelected && _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
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
        .fadeIn(delay: Duration(milliseconds: 600 + delay), duration: 500.ms)
        .slideX(
          begin: isArabic ? -0.1 : 0.1,
          end: 0,
          delay: Duration(milliseconds: 600 + delay),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 600 + delay),
          duration: 500.ms,
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
