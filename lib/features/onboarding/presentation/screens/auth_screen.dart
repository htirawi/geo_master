import 'dart:io';

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
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/decorative_background.dart';

/// Premium auth screen with social login options and Explorer's Journey theme.
///
/// Features:
/// - Social login (Google, Apple on iOS, Email)
/// - Guest mode option
/// - Terms acceptance requirement
/// - Animated floating flags background
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _loadingProvider;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Listen to auth state changes
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((state) {
        if (state is AuthAuthenticated) {
          context.go(Routes.personalization);
        } else if (state is AuthError) {
          _showErrorSnackBar(state.failure.message);
        }
      });
    });

    return Scaffold(
      body: OnboardingBackground(
        showFlags: true,
        flagCount: 10,
        child: SafeArea(
          child: Column(
            children: [
              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsivePadding,
                  ),
                  child: ResponsiveCenter(
                    maxWidth: 500,
                    child: Column(
                      children: [
                        const SizedBox(height: AppDimensions.lg - 4),

                        // Animated logo
                        const AnimatedGlobeLogo(size: 90),

                        const SizedBox(height: 12),

                        // App title
                        _buildAppTitle(theme, l10n),

                        const SizedBox(height: 4),

                        // Welcome message
                        _buildWelcomeMessage(l10n),

                        const SizedBox(height: 24),

                        // Social login buttons
                        _buildGoogleButton(l10n),
                        const SizedBox(height: 14),

                        if (Platform.isIOS) ...[
                          _buildAppleButton(l10n),
                          const SizedBox(height: 14),
                        ],

                        _buildEmailButton(l10n),

                        const SizedBox(height: 24),

                        // Divider with "or"
                        _buildDivider(l10n, theme),

                        const SizedBox(height: 24),

                        // Guest mode button
                        _buildGuestButton(l10n),

                        const SizedBox(height: AppDimensions.lg - 4),
                      ],
                    ),
                  ),
                ),
              ),

              // Terms fixed at bottom with glassmorphism effect
              _buildTermsContainer(l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle(ThemeData theme, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Column(
      children: [
        ShimmerText(
          text: l10n.appTitle,
          style: isArabic
              ? GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              : GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms);
  }

  Widget _buildWelcomeMessage(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Text(
      l10n.welcomeBack,
      style: isArabic
          ? GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            )
          : GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms);
  }

  Widget _buildGoogleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return _buildSocialButton(
      label: l10n.continueWithGoogle,
      icon: _buildGoogleIcon(),
      backgroundColor: Colors.white,
      textColor: canProceed ? Colors.black87 : Colors.grey,
      borderColor: Colors.grey.shade300,
      isLoading: _isLoading && _loadingProvider == 'google',
      onPressed: canProceed
          ? _signInWithGoogle
          : () => _showTermsWarning(l10n),
      isArabic: isArabic,
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms);
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return _buildSocialButton(
      label: l10n.continueWithApple,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.apple, size: 20, color: Colors.black),
        ),
      ),
      backgroundColor: canProceed ? Colors.black : const Color(0xFF2C2C2C),
      textColor: canProceed ? Colors.white : Colors.white.withValues(alpha: 0.6),
      isLoading: _isLoading && _loadingProvider == 'apple',
      onPressed: canProceed
          ? _signInWithApple
          : () => _showTermsWarning(l10n),
      isArabic: isArabic,
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 600.ms, duration: 400.ms);
  }

  Widget _buildEmailButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final delay = Duration(milliseconds: Platform.isIOS ? 700 : 600);

    return _buildSocialButton(
      label: l10n.continueWithEmail,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.email_outlined,
            size: 18,
            color: canProceed ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
      backgroundColor: canProceed
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.1),
      textColor: canProceed ? Colors.white : Colors.white.withValues(alpha: 0.5),
      borderColor: canProceed
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.2),
      isLoading: _isLoading && _loadingProvider == 'email',
      onPressed: canProceed
          ? () => context.push(Routes.emailAuth)
          : () => _showTermsWarning(l10n),
      isArabic: isArabic,
    )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: delay, duration: 400.ms);
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required bool isLoading,
    required VoidCallback onPressed,
    required bool isArabic,
  }) {
    return _PressableButton(
      onPressed: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(width: 32, child: icon),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMD,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              l10n.or,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }

  Widget _buildGuestButton(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final canProceed = _termsAccepted && !_isLoading;

    return _PressableButton(
      onPressed: canProceed
          ? _continueAsGuest
          : () => _showTermsWarning(l10n),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: canProceed
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: canProceed
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: canProceed ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_outlined,
                size: 20,
                color: canProceed
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.continueAsGuest,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: canProceed
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                        )
                      : GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: canProceed
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                ),
                Text(
                  l10n.guestModeDescription,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 12,
                          color: canProceed
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.4),
                        )
                      : GoogleFonts.poppins(
                          fontSize: 12,
                          color: canProceed
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 400.ms);
  }

  Widget _buildTermsContainer(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding,
        12,
        context.responsivePadding,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ResponsiveCenter(
        maxWidth: 500,
        child: _buildTerms(l10n, theme),
      ),
    );
  }

  Widget _buildTerms(AppLocalizations l10n, ThemeData theme) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _termsAccepted = !_termsAccepted);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _termsAccepted
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: _termsAccepted
                ? AppColors.success.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _termsAccepted
                    ? AppColors.success
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _termsAccepted
                      ? AppColors.success
                      : Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: _termsAccepted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            // Terms text with clickable links
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                  children: [
                    TextSpan(text: l10n.termsCheckbox),
                    const TextSpan(text: ' '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => context.push(Routes.termsOfService),
                        child: Text(
                          l10n.termsOfServiceLink,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF90CAF9),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF90CAF9),
                            fontFamily: isArabic ? 'Cairo' : null,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' ${l10n.andText} '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => context.push(Routes.privacyPolicy),
                        child: Text(
                          l10n.privacyPolicyLink,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF90CAF9),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF90CAF9),
                            fontFamily: isArabic ? 'Cairo' : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsWarning(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text(l10n.pleaseAcceptTerms)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppDimensions.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'google';
    });
    HapticFeedback.mediumImpact();
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'apple';
    });
    HapticFeedback.mediumImpact();
    try {
      await ref.read(authStateProvider.notifier).signInWithApple();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'guest';
    });
    HapticFeedback.lightImpact();
    try {
      await ref.read(authStateProvider.notifier).signInAnonymously();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
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

/// Reusable pressable button with scale animation feedback
class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
