import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/backgrounds/onboarding_background.dart';
import '../../../../presentation/components/cards/selection_card.dart';
import '../../../../presentation/providers/onboarding_provider.dart';

/// Premium language selection screen with Explorer's Journey theme.
///
/// Features:
/// - Animated globe and floating flags background
/// - Large language selection cards
/// - Smooth transitions and haptic feedback
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isLoading = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: OnboardingBackground(
        showFlags: true,
        flagCount: 18,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated globe logo
                const AnimatedGlobe(size: 140),

                const SizedBox(height: AppDimensions.spacingXL),

                // App name with shimmer effect
                _buildAppTitle(theme),

                const Spacer(),

                // Language selection prompt
                _buildPrompt(theme, l10n),

                const SizedBox(height: AppDimensions.spacingXL),

                // English language option
                SelectionCard(
                  title: 'English',
                  variant: SelectionCardVariant.language,
                  isSelected: _selectedLanguage == 'en',
                  isLoading: _isLoading && _selectedLanguage == 'en',
                  accentColor: const Color(0xFF4FC3F7), // Cool blue
                  showArrow: true,
                  animationDelay: 600.ms,
                  onTap: () => _selectLanguage('en'),
                ),

                const SizedBox(height: AppDimensions.md),

                // Arabic language option
                SelectionCard(
                  title: 'العربية',
                  variant: SelectionCardVariant.language,
                  isSelected: _selectedLanguage == 'ar',
                  isLoading: _isLoading && _selectedLanguage == 'ar',
                  accentColor: const Color(0xFFFFD54F), // Warm gold
                  showArrow: true,
                  animationDelay: 700.ms,
                  onTap: () => _selectLanguage('ar'),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle(ThemeData theme) {
    return ShimmerText(
      text: 'أطلس العالم',
      style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ) ??
          const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 36,
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

  Future<void> _selectLanguage(String language) async {
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
      if (mounted) {
        context.go(Routes.onboarding);
      }
    } catch (e) {
      if (mounted) {
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
