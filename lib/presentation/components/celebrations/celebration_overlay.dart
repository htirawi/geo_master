import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';

/// Types of celebrations available
enum CelebrationType {
  perfect, // 100% score
  excellent, // 90%+ score
  good, // 80%+ score
  achievement, // Achievement unlocked
  levelUp, // Level progression
  streak, // Streak milestone
  firstQuiz, // First quiz completed
}

/// Full-screen celebration overlay with confetti and animations
class CelebrationOverlay extends ConsumerStatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.type,
    this.child,
    this.onComplete,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 3),
    this.message,
    this.subMessage,
    this.showConfetti = true,
    this.lottieAsset,
  });

  /// Type of celebration to display
  final CelebrationType type;

  /// Optional child widget to display in the center
  final Widget? child;

  /// Callback when celebration completes
  final VoidCallback? onComplete;

  /// Whether to automatically dismiss after duration
  final bool autoDismiss;

  /// Duration before auto-dismiss
  final Duration dismissDuration;

  /// Optional custom message
  final String? message;

  /// Optional sub-message
  final String? subMessage;

  /// Whether to show confetti
  final bool showConfetti;

  /// Optional custom Lottie animation asset path
  final String? lottieAsset;

  /// Show celebration overlay
  static Future<void> show(
    BuildContext context, {
    required CelebrationType type,
    Widget? child,
    VoidCallback? onComplete,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 3),
    String? message,
    String? subMessage,
    bool showConfetti = true,
    String? lottieAsset,
  }) async {
    // Check for reduce motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      // Show simple dialog instead of full animation
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForType(type),
                size: 48,
                color: _getColorForType(type),
              ),
              const SizedBox(height: 16),
              if (message != null)
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              if (subMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  subMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 16),
                child,
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onComplete?.call();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebration',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CelebrationOverlay(
          type: type,
          onComplete: onComplete,
          autoDismiss: autoDismiss,
          dismissDuration: dismissDuration,
          message: message,
          subMessage: subMessage,
          showConfetti: showConfetti,
          lottieAsset: lottieAsset,
          child: child,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static IconData _getIconForType(CelebrationType type) {
    switch (type) {
      case CelebrationType.perfect:
        return Icons.stars;
      case CelebrationType.excellent:
        return Icons.emoji_events;
      case CelebrationType.good:
        return Icons.thumb_up;
      case CelebrationType.achievement:
        return Icons.military_tech;
      case CelebrationType.levelUp:
        return Icons.trending_up;
      case CelebrationType.streak:
        return Icons.local_fire_department;
      case CelebrationType.firstQuiz:
        return Icons.celebration;
    }
  }

  static Color _getColorForType(CelebrationType type) {
    switch (type) {
      case CelebrationType.perfect:
        return AppColors.xpGold;
      case CelebrationType.excellent:
        return AppColors.success;
      case CelebrationType.good:
        return AppColors.primary;
      case CelebrationType.achievement:
        return AppColors.achievement;
      case CelebrationType.levelUp:
        return AppColors.levelUp;
      case CelebrationType.streak:
        return AppColors.streak;
      case CelebrationType.firstQuiz:
        return AppColors.primary;
    }
  }

  @override
  ConsumerState<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCelebration();
    });
  }

  void _startCelebration() {
    // Play sound based on type
    _playSound();

    // Trigger haptic
    _triggerHaptic();

    // Show confetti
    if (widget.showConfetti) {
      _confettiController.play();
    }

    // Auto dismiss
    if (widget.autoDismiss) {
      Future.delayed(widget.dismissDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onComplete?.call();
        }
      });
    }
  }

  Future<void> _playSound() async {
    try {
      final audioService = ref.read(audioServiceProvider);
      switch (widget.type) {
        case CelebrationType.perfect:
        case CelebrationType.excellent:
          await audioService.playLevelUp();
        case CelebrationType.achievement:
          await audioService.playAchievement();
        case CelebrationType.levelUp:
          await audioService.playLevelUp();
        case CelebrationType.streak:
          await audioService.playStreak();
        case CelebrationType.good:
        case CelebrationType.firstQuiz:
          await audioService.playConfetti();
      }
    } catch (_) {
      // Ignore audio errors
    }
  }

  void _triggerHaptic() {
    switch (widget.type) {
      case CelebrationType.perfect:
      case CelebrationType.levelUp:
        HapticFeedback.heavyImpact();
      case CelebrationType.excellent:
      case CelebrationType.achievement:
        HapticFeedback.mediumImpact();
      case CelebrationType.good:
      case CelebrationType.streak:
      case CelebrationType.firstQuiz:
        HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CelebrationOverlay._getColorForType(widget.type);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Tap to dismiss
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              widget.onComplete?.call();
            },
            child: Container(color: Colors.transparent),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animation or icon
                _buildCelebrationIcon(color),

                const SizedBox(height: 24),

                // Message
                if (widget.message != null)
                  Text(
                    widget.message!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),

                if (widget.subMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subMessage!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                ],

                // Child widget
                if (widget.child != null) ...[
                  const SizedBox(height: 24),
                  widget.child!.animate().fadeIn(delay: 600.ms),
                ],
              ],
            ),
          ),

          // Confetti
          if (widget.showConfetti) ...[
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: _getConfettiColors(),
                numberOfParticles: _getParticleCount(),
                gravity: 0.1,
                emissionFrequency: 0.05,
                maxBlastForce: 20,
                minBlastForce: 10,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -0.5,
                shouldLoop: false,
                colors: _getConfettiColors(),
                numberOfParticles: (_getParticleCount() / 2).round(),
                gravity: 0.15,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 + 0.5,
                shouldLoop: false,
                colors: _getConfettiColors(),
                numberOfParticles: (_getParticleCount() / 2).round(),
                gravity: 0.15,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCelebrationIcon(Color color) {
    // Try to load Lottie animation if available
    if (widget.lottieAsset != null) {
      return SizedBox(
        width: 150,
        height: 150,
        child: Lottie.asset(
          widget.lottieAsset!,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(color);
          },
        ),
      );
    }

    // Fallback to animated icon
    return _buildFallbackIcon(color);
  }

  Widget _buildFallbackIcon(Color color) {
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
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              CelebrationOverlay._getIconForType(widget.type),
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  List<Color> _getConfettiColors() {
    switch (widget.type) {
      case CelebrationType.perfect:
        return [
          AppColors.xpGold,
          AppColors.xpGold.withValues(alpha: 0.8),
          Colors.amber,
          Colors.orange,
          Colors.white,
        ];
      case CelebrationType.excellent:
        return [
          AppColors.success,
          Colors.greenAccent,
          Colors.lightGreen,
          Colors.white,
        ];
      case CelebrationType.achievement:
        return [
          AppColors.achievement,
          Colors.purple,
          Colors.purpleAccent,
          Colors.white,
        ];
      case CelebrationType.levelUp:
        return [
          AppColors.levelUp,
          Colors.blue,
          Colors.lightBlue,
          Colors.white,
        ];
      case CelebrationType.streak:
        return [
          AppColors.streak,
          Colors.orange,
          Colors.deepOrange,
          Colors.yellow,
        ];
      default:
        return [
          AppColors.primary,
          AppColors.secondary,
          AppColors.success,
          AppColors.xpGold,
          Colors.white,
        ];
    }
  }

  int _getParticleCount() {
    switch (widget.type) {
      case CelebrationType.perfect:
        return 50;
      case CelebrationType.excellent:
      case CelebrationType.levelUp:
        return 40;
      case CelebrationType.achievement:
        return 35;
      case CelebrationType.good:
      case CelebrationType.streak:
        return 25;
      case CelebrationType.firstQuiz:
        return 30;
    }
  }
}
