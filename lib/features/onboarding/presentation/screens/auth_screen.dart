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
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/decorative_background.dart';
import '../../../../presentation/widgets/premium_button.dart';

/// Premium auth screen with social login options and animations
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
    final size = MediaQuery.of(context).size;

    // Listen to auth state changes
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((state) {
        if (state is AuthAuthenticated) {
          context.go(Routes.personalization);
        } else if (state is AuthError) {
          _showErrorSnackBar(context, state.failure.message);
        }
      });
    });

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
              // Floating flags background (behind everything, non-interactive)
              IgnorePointer(
                child: FloatingFlagsBackground(
                  size: size,
                  opacity: 0.12, // Subtle so content stays prominent
                ),
              ),

              // Gradient orbs (decorative, non-interactive)
              const IgnorePointer(
                child: GradientOrbsBackground(),
              ),

              // Main content
              SingleChildScrollView(
                padding: EdgeInsets.all(context.responsivePadding),
                child: ResponsiveCenter(
                  maxWidth: 500,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          context.responsivePadding * 2,
                    ),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Animated logo
                      const AnimatedGlobeLogo(),

                      const SizedBox(height: AppDimensions.spacingLG),

                      // App title
                      _buildAppTitle(theme, l10n),

                      const SizedBox(height: AppDimensions.spacingSM),

                      // Welcome message
                      Builder(
                        builder: (context) {
                          final locale = Localizations.localeOf(context);
                          final isArabic = locale.languageCode == 'ar';
                          return Text(
                            l10n.welcomeBack,
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: AppColors.textSecondaryLight,
                                  )
                                : GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AppColors.textSecondaryLight,
                                  ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .slideY(
                              begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms),

                      const SizedBox(height: 50),

                      // Social login buttons
                      _buildGoogleButton(l10n),
                      const SizedBox(height: AppDimensions.spacingMD),

                      if (Platform.isIOS) ...[
                        _buildAppleButton(l10n),
                        const SizedBox(height: AppDimensions.spacingMD),
                      ],

                      _buildEmailButton(context, l10n),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // Divider with "or"
                      _buildDivider(l10n, theme),

                      const SizedBox(height: AppDimensions.spacingLG),

                      // Guest mode button
                      _buildGuestButton(l10n),

                      const SizedBox(height: 40),

                      // Terms and privacy
                      _buildTerms(l10n, theme),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                ),
              ),
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
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ).createShader(bounds),
          child: Text(
            l10n.appTitle,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  )
                : GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms);
  }

  Widget _buildGoogleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    return SocialLoginButton(
      label: l10n.continueWithGoogle,
      icon: _buildGoogleIcon(),
      backgroundColor: Colors.white,
      foregroundColor: canProceed ? Colors.black87 : Colors.grey,
      borderColor: Colors.grey.shade300,
      isLoading: _isLoading && _loadingProvider == 'google',
      onPressed: canProceed ? () => _signInWithGoogle(context) : () => _showTermsWarning(context, l10n),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms);
  }

  Widget _buildAppleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    return SocialLoginButton(
      label: l10n.continueWithApple,
      icon: Icon(Icons.apple, size: 26, color: canProceed ? Colors.white : Colors.grey),
      backgroundColor: canProceed ? Colors.black : Colors.grey.shade300,
      foregroundColor: canProceed ? Colors.white : Colors.grey,
      isLoading: _isLoading && _loadingProvider == 'apple',
      onPressed: canProceed ? () => _signInWithApple(context) : () => _showTermsWarning(context, l10n),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 600.ms, duration: 400.ms);
  }

  Widget _buildEmailButton(BuildContext context, AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    return SocialLoginButton(
      label: l10n.continueWithEmail,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: canProceed ? AppColors.primaryGradient : null,
          color: canProceed ? null : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.email_outlined, size: 18, color: canProceed ? Colors.white : Colors.grey),
      ),
      backgroundColor: canProceed ? AppColors.primaryLight.withValues(alpha: 0.25) : Colors.grey.shade100,
      foregroundColor: canProceed ? AppColors.primaryDark : Colors.grey,
      borderColor: canProceed ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade300,
      isLoading: _isLoading && _loadingProvider == 'email',
      onPressed: canProceed ? () => context.push(Routes.emailAuth) : () => _showTermsWarning(context, l10n),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: Platform.isIOS ? 700 : 600),
            duration: 400.ms)
        .slideX(
            begin: 0.1,
            end: 0,
            delay: Duration(milliseconds: Platform.isIOS ? 700 : 600),
            duration: 400.ms);
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 26,
      height: 26,
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
                  Colors.grey.withValues(alpha: 0.3),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              l10n.or,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
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
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 400.ms);
  }

  Widget _buildGuestButton(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final canProceed = _termsAccepted && !_isLoading;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: canProceed ? () => _continueAsGuest(context) : () => _showTermsWarning(context, l10n),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(
            color: canProceed ? AppColors.tertiary : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: canProceed
              ? AppColors.tertiary.withValues(alpha: 0.08)
              : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 22,
              color: canProceed ? AppColors.tertiary : Colors.grey,
            ),
            const SizedBox(width: 10),
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
                          color: canProceed ? AppColors.tertiary : Colors.grey,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: canProceed ? AppColors.tertiary : Colors.grey,
                        ),
                ),
                Text(
                  l10n.guestModeDescription,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 12,
                          color: canProceed ? AppColors.textTertiaryLight : Colors.grey.shade400,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 12,
                          color: canProceed ? AppColors.textTertiaryLight : Colors.grey.shade400,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms);
  }

  Widget _buildTerms(AppLocalizations l10n, ThemeData theme) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _termsAccepted
            ? AppColors.success.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _termsAccepted
              ? AppColors.success.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _termsAccepted = !_termsAccepted);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: _termsAccepted ? AppColors.success : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _termsAccepted ? AppColors.success : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: _termsAccepted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Terms text with clickable links
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.termsCheckbox,
                    style: isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.6,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.6,
                          ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.push(Routes.termsOfService),
                    child: Text(
                      l10n.termsOfServiceLink,
                      style: isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                              height: 1.6,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                              height: 1.6,
                            ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.andText,
                    style: isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.6,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.6,
                          ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.push(Routes.privacyPolicy),
                    child: Text(
                      l10n.privacyPolicyLink,
                      style: isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                              height: 1.6,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                              height: 1.6,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 400.ms);
  }

  void _showTermsWarning(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.pleaseAcceptTerms)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
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

  Future<void> _signInWithApple(BuildContext context) async {
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

  Future<void> _continueAsGuest(BuildContext context) async {
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
