import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/explorer_level.dart';
import '../../providers/audio_provider.dart';

/// Level up celebration overlay
/// Shows when user advances to a new explorer level
class LevelUpOverlay extends ConsumerStatefulWidget {
  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.previousLevel,
    this.onDismiss,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 5),
  });

  /// The new level achieved
  final ExplorerLevel newLevel;

  /// The previous level
  final ExplorerLevel previousLevel;

  /// Callback when dismissed
  final VoidCallback? onDismiss;

  /// Whether to auto-dismiss
  final bool autoDismiss;

  /// Duration before auto-dismiss
  final Duration dismissDuration;

  /// Show level up overlay
  static Future<void> show(
    BuildContext context, {
    required ExplorerLevel newLevel,
    required ExplorerLevel previousLevel,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 5),
  }) async {
    // Check for reduce motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (reduceMotion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.trending_up, color: newLevel.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${isArabic ? "مستوى جديد:" : "Level Up:"} ${newLevel.getTitle(isArabic)}',
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: newLevel.color,
        ),
      );
      onDismiss?.call();
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LevelUpOverlay(
          newLevel: newLevel,
          previousLevel: previousLevel,
          onDismiss: onDismiss,
          autoDismiss: autoDismiss,
          dismissDuration: dismissDuration,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends ConsumerState<LevelUpOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCelebration();
    });

    if (widget.autoDismiss) {
      Future.delayed(widget.dismissDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        }
      });
    }
  }

  Future<void> _startCelebration() async {
    _confettiController.play();
    HapticFeedback.heavyImpact();

    // Short delay then another impact for emphasis
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      HapticFeedback.mediumImpact();
    }

    try {
      final audioService = ref.read(audioServiceProvider);
      await audioService.playLevelUp();
    } catch (_) {
      // Ignore audio errors
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        },
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5 + (_glowController.value * 0.3),
                      colors: [
                        widget.newLevel.color.withValues(alpha: 0.2),
                        Colors.black87,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Level up text
                  Text(
                    isArabic ? 'مستوى جديد!' : 'LEVEL UP!',
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 800.ms,
                      )
                      .shimmer(
                        delay: 500.ms,
                        duration: 2000.ms,
                        color: widget.newLevel.color.withValues(alpha: 0.5),
                      ),

                  const SizedBox(height: 40),

                  // Badge animation
                  _buildBadge(),

                  const SizedBox(height: 32),

                  // New level title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.newLevel.color.withValues(alpha: 0.9),
                          widget.newLevel.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLG,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.newLevel.color.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.newLevel.getTitle(isArabic),
                      style: (isArabic
                              ? GoogleFonts.cairo
                              : GoogleFonts.poppins)(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, end: 0)
                      .then()
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),

                  const SizedBox(height: 24),

                  // XP info
                  Container(
                    width: size.width * 0.7,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.xpGold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.newLevel.xpRequired} XP',
                              style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.xpGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? 'المستوى التالي: ${_getNextLevelXp()} XP'
                              : 'Next level: ${_getNextLevelXp()} XP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 32),

                  // Tap to continue
                  Text(
                    isArabic ? 'اضغط للمتابعة' : 'Tap to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  widget.newLevel.color,
                  widget.newLevel.color.withValues(alpha: 0.8),
                  AppColors.xpGold,
                  Colors.white,
                ],
                numberOfParticles: 60,
                gravity: 0.05,
                emissionFrequency: 0.03,
                maxBlastForce: 30,
                minBlastForce: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    // Try Lottie first
    return SizedBox(
      width: 150,
      height: 150,
      child: Lottie.asset(
        'assets/animations/lottie/celebrations/level_up_glow.json',
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to animated badge
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.newLevel.color,
                        widget.newLevel.color.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.newLevel.color.withValues(
                          alpha: 0.4 + (_pulseController.value * 0.3),
                        ),
                        blurRadius: 30 + (_pulseController.value * 20),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.newLevel.icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .then(delay: 200.ms)
        .shake(
          hz: 2,
          rotation: 0.02,
        );
  }

  String _getNextLevelXp() {
    final nextLevel = widget.newLevel.nextLevel;
    if (nextLevel != null) {
      return '${nextLevel.xpRequired}';
    }
    return 'MAX';
  }
}

/// Progress bar showing XP progress to next level
class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({
    super.key,
    required this.currentXp,
    required this.currentLevel,
    this.height = 8,
    this.showLabel = true,
    this.animated = true,
  });

  final int currentXp;
  final ExplorerLevel currentLevel;
  final double height;
  final bool showLabel;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final nextLevel = currentLevel.nextLevel;
    final progress = nextLevel != null
        ? (currentXp - currentLevel.xpRequired) /
            (nextLevel.xpRequired - currentLevel.xpRequired)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentLevel.getTitle(isArabic),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: currentLevel.color,
                ),
              ),
              Text(
                nextLevel != null
                    ? '$currentXp / ${nextLevel.xpRequired} XP'
                    : 'MAX',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final progressWidth = constraints.maxWidth * progress.clamp(0, 1);
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: animated
                          ? const Duration(milliseconds: 500)
                          : Duration.zero,
                      width: progressWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentLevel.color,
                            currentLevel.color.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
