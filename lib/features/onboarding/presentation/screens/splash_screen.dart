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
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/onboarding_provider.dart';
import '../../../../presentation/widgets/decorative_background.dart';

/// Premium animated splash screen with rotating globe and flying flags
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _globeController;
  late AnimationController _flagsController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  bool _animationComplete = false;
  bool _isDisposed = false;

  // Country codes for professional SVG flag rendering
  // Arab countries prioritized: JO, PS, SA, AE, KW, EG
  static const List<String> _flagCodes = [
    'JO', 'PS', 'SA', 'AE', 'KW', 'EG', 'US', 'GB',
    'FR', 'DE', 'JP', 'CN', 'BR', 'IN', 'AU', 'CA',
    'IT', 'ES', 'KR', 'MX', 'ZA', 'NG', 'TR', 'AR',
  ];

  @override
  void initState() {
    super.initState();
    _configureSystemUI();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _flagsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));
    if (!mounted || _isDisposed) return;

    setState(() => _animationComplete = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || _isDisposed) return;

    _stopAllAnimations();
    _navigateToNextScreen();
  }

  void _stopAllAnimations() {
    _globeController.stop();
    _flagsController.stop();
    _pulseController.stop();
    _particleController.stop();
  }

  void _navigateToNextScreen() {
    final authState = ref.read(authStateProvider);
    final onboardingState = ref.read(onboardingStateProvider);

    final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
    final hasCompletedOnboarding =
        onboardingState.valueOrNull?.hasCompletedOnboarding ?? false;
    final hasSelectedLanguage =
        onboardingState.valueOrNull?.hasSelectedLanguage ?? false;

    if (!hasSelectedLanguage) {
      context.go(Routes.languageSelection);
    } else if (!hasCompletedOnboarding) {
      context.go(Routes.onboarding);
    } else if (!isLoggedIn) {
      context.go(Routes.auth);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopAllAnimations();
    _globeController.dispose();
    _flagsController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _animationComplete
                ? [
                    AppColors.primary.withValues(alpha: 0),
                    AppColors.primaryDark.withValues(alpha: 0),
                  ]
                : const [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                    Color(0xFF415A77),
                  ],
            stops: _animationComplete ? null : const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            ParticlesBackground(animation: _particleController),
            _buildGradientOrbs(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OrbitingGlobe(
                    globeAnimation: _globeController,
                    flagsAnimation: _flagsController,
                    pulseAnimation: _pulseController,
                    flagCodes: _flagCodes.sublist(0, 6),
                  ),
                  const SizedBox(height: 40),
                  _buildAppName(l10n),
                  const SizedBox(height: 16),
                  _buildTagline(l10n),
                  const SizedBox(height: 60),
                  _buildLoadingIndicator(l10n),
                ],
              ),
            ),
            ..._buildFlyingFlags(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 3.seconds,
            ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tertiary.withValues(alpha: 0.2),
                  AppColors.tertiary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(1, 1),
              duration: 4.seconds,
            ),
      ],
    );
  }

  List<Widget> _buildFlyingFlags() {
    final random = math.Random(42);
    return List.generate(12, (index) {
      final startX = random.nextDouble();
      final startY = random.nextDouble();
      // Pre-calculate random values ONCE per flag (not per frame)
      final flagSize = 24 + random.nextDouble() * 12;
      final flagCode = _flagCodes[(index + 8) % _flagCodes.length];

      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final size = MediaQuery.of(context).size;
          final progress = (_particleController.value + (index * 0.08)) % 1.0;
          final x = startX * size.width + math.sin(progress * 2 * math.pi) * 50;
          final y = (startY + progress) * size.height;

          if (y > size.height) return const SizedBox.shrink();

          return Positioned(
            left: x,
            top: y % size.height,
            child: child!,
          );
        },
        child: Opacity(
          opacity: 0.6,
          child: Container(
            width: flagSize,
            height: flagSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
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

  Widget _buildAppName(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFF90CAF9), Colors.white],
      ).createShader(bounds),
      child: Text(
        l10n.appName,
        style: isArabic
            ? GoogleFonts.cairo(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              )
            : GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms);
  }

  Widget _buildTagline(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Text(
      l10n.appTagline,
      style: isArabic
          ? GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 2,
              fontWeight: FontWeight.w400,
            )
          : GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 3,
              fontWeight: FontWeight.w300,
            ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 600.ms);
  }

  Widget _buildLoadingIndicator(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.3 + (_pulseController.value * 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.secondary],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingJourney,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  )
                : GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms);
  }
}
