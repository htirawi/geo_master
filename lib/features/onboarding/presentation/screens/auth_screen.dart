import 'dart:io';
import 'dart:math' as math;

import 'package:country_flags/country_flags.dart';
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

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _loadingProvider;
  bool _termsAccepted = false;
  late AnimationController _flagsController;

  // Country codes for floating flags - matching splash screen
  static const List<String> _flagCodes = [
    'JO', 'PS', 'SA', 'AE', 'KW', 'EG', 'US', 'GB',
    'FR', 'DE', 'JP', 'CN', 'BR', 'IN', 'AU', 'CA',
  ];

  @override
  void initState() {
    super.initState();
    _flagsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _flagsController.dispose();
    super.dispose();
  }

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
          // Dark gradient matching splash screen
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
        child: Stack(
          children: [
            // Subtle floating flags in background
            ..._buildFloatingFlags(),

            // Gradient orbs for depth
            _buildGradientOrbs(),

            // Main content
            SafeArea(
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
                            const SizedBox(height: 20),

                            // Animated logo
                            const AnimatedGlobeLogo(size: 90),

                            const SizedBox(height: 12),

                            // App title
                            _buildAppTitle(theme, l10n),

                            const SizedBox(height: 4),

                            // Welcome message
                            Builder(
                              builder: (context) {
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
                                );
                              },
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 500.ms)
                                .slideY(
                                    begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms),

                            const SizedBox(height: 24),

                            // Social login buttons
                            _buildGoogleButton(l10n),
                            const SizedBox(height: 14),

                            if (Platform.isIOS) ...[
                              _buildAppleButton(l10n),
                              const SizedBox(height: 14),
                            ],

                            _buildEmailButton(context, l10n),

                            const SizedBox(height: 24),

                            // Divider with "or"
                            _buildDivider(l10n, theme),

                            const SizedBox(height: 24),

                            // Guest mode button
                            _buildGuestButton(l10n),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Terms fixed at bottom with glassmorphism effect
                  Container(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating flags positioned around edges
  List<Widget> _buildFloatingFlags() {
    final random = math.Random(42);
    return List.generate(10, (index) {
      // Position flags around edges, avoiding center content area
      final isLeftSide = index % 2 == 0;
      final verticalPosition = 0.1 + (index / 10) * 0.8;
      final flagSize = 20 + random.nextDouble() * 10;
      final flagCode = _flagCodes[index % _flagCodes.length];

      return AnimatedBuilder(
        animation: _flagsController,
        builder: (context, child) {
          final size = MediaQuery.of(context).size;
          final progress = (_flagsController.value + (index * 0.1)) % 1.0;

          // Gentle floating motion
          final baseX = isLeftSide ? 10.0 : size.width - flagSize - 10;
          final x = baseX + math.sin(progress * 2 * math.pi) * 15;
          final y = verticalPosition * size.height +
              math.cos(progress * 2 * math.pi + index) * 10;

          return Positioned(
            left: isLeftSide ? x : null,
            right: isLeftSide ? null : size.width - x - flagSize,
            top: y,
            child: child!,
          );
        },
        child: Opacity(
          opacity: 0.4,
          child: Container(
            width: flagSize,
            height: flagSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CountryFlag.fromCountryCode(
                flagCode,
                width: flagSize,
                height: flagSize,
              ),
            ),
          ),
        ),
      );
    });
  }

  // Gradient orbs for visual depth (matching splash screen)
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

  Widget _buildAppTitle(ThemeData theme, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF90CAF9), Colors.white],
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

  // Consistent icon size for all social buttons
  static const double _iconContainerSize = 32.0;
  static const double _iconSize = 18.0;

  Widget _buildGoogleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return _buildSocialButton(
      label: l10n.continueWithGoogle,
      icon: _buildIconContainer(
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
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      textColor: canProceed ? Colors.black87 : Colors.grey,
      borderColor: Colors.grey.shade300,
      isLoading: _isLoading && _loadingProvider == 'google',
      onPressed: canProceed
          ? () => _signInWithGoogle(context)
          : () => _showTermsWarning(context, l10n),
      isArabic: isArabic,
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms);
  }

  Widget _buildAppleButton(AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return _buildSocialButton(
      label: l10n.continueWithApple,
      icon: _buildIconContainer(
        child: Icon(
          Icons.apple,
          size: _iconSize + 2,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      // Fix: Solid black when active, dark gray when inactive
      backgroundColor: canProceed ? Colors.black : const Color(0xFF2C2C2C),
      textColor: canProceed ? Colors.white : Colors.white.withValues(alpha: 0.6),
      isLoading: _isLoading && _loadingProvider == 'apple',
      onPressed: canProceed
          ? () => _signInWithApple(context)
          : () => _showTermsWarning(context, l10n),
      isArabic: isArabic,
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: 600.ms, duration: 400.ms);
  }

  Widget _buildEmailButton(BuildContext context, AppLocalizations l10n) {
    final canProceed = _termsAccepted && !_isLoading;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return _buildSocialButton(
      label: l10n.continueWithEmail,
      // Fix: White icon container for consistency
      icon: _buildIconContainer(
        child: Icon(
          Icons.email_outlined,
          size: _iconSize,
          color: canProceed ? AppColors.primary : Colors.grey,
        ),
        backgroundColor: Colors.white,
      ),
      // Fix: Higher contrast background
      backgroundColor: canProceed
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.1),
      textColor: canProceed ? Colors.white : Colors.white.withValues(alpha: 0.5),
      // Fix: More visible border
      borderColor: canProceed
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.2),
      isLoading: _isLoading && _loadingProvider == 'email',
      onPressed: canProceed
          ? () => context.push(Routes.emailAuth)
          : () => _showTermsWarning(context, l10n),
      isArabic: isArabic,
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

  /// Professional social button with perfectly aligned icons and press feedback
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
          borderRadius: BorderRadius.circular(16),
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
                    // Fixed width for icon area - ensures alignment
                    SizedBox(
                      width: _iconContainerSize,
                      child: icon,
                    ),
                    const SizedBox(width: 14),
                    // Text takes remaining space
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

  /// Consistent icon container for all social buttons
  Widget _buildIconContainer({
    required Widget child,
    required Color backgroundColor,
  }) {
    return Container(
      width: _iconContainerSize,
      height: _iconContainerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: child),
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
              borderRadius: BorderRadius.circular(20),
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
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 400.ms);
  }

  Widget _buildGuestButton(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final canProceed = _termsAccepted && !_isLoading;

    return _PressableButton(
      onPressed: canProceed
          ? () => _continueAsGuest(context)
          : () => _showTermsWarning(context, l10n),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          // Fix: Higher contrast background
          color: canProceed
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Fix: More visible border
            color: canProceed
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon in a subtle circle for consistency
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
                // Fix: Higher contrast icon
                color: canProceed
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
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
                          // Fix: Higher contrast text
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
                          // Fix: Higher contrast subtitle
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
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms);
  }

  Widget _buildTerms(AppLocalizations l10n, ThemeData theme) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _termsAccepted = !_termsAccepted);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _termsAccepted
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
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
