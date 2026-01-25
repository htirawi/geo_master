import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/audio_provider.dart';

/// Streak milestone thresholds
class StreakMilestone {
  const StreakMilestone({
    required this.days,
    required this.icon,
    required this.titleEn,
    required this.titleAr,
    required this.color,
    required this.xpBonus,
  });

  final int days;
  final IconData icon;
  final String titleEn;
  final String titleAr;
  final Color color;
  final int xpBonus;

  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  static const List<StreakMilestone> milestones = [
    StreakMilestone(
      days: 3,
      icon: Icons.local_fire_department,
      titleEn: 'Getting Started!',
      titleAr: 'بداية موفقة!',
      color: Colors.orange,
      xpBonus: 25,
    ),
    StreakMilestone(
      days: 7,
      icon: Icons.whatshot,
      titleEn: 'Week Warrior!',
      titleAr: 'محارب الأسبوع!',
      color: Colors.deepOrange,
      xpBonus: 50,
    ),
    StreakMilestone(
      days: 14,
      icon: Icons.local_fire_department,
      titleEn: 'Two Week Champion!',
      titleAr: 'بطل الأسبوعين!',
      color: Colors.red,
      xpBonus: 100,
    ),
    StreakMilestone(
      days: 30,
      icon: Icons.military_tech,
      titleEn: 'Monthly Master!',
      titleAr: 'سيد الشهر!',
      color: AppColors.xpGold,
      xpBonus: 250,
    ),
    StreakMilestone(
      days: 100,
      icon: Icons.emoji_events,
      titleEn: 'Century Legend!',
      titleAr: 'أسطورة المئة!',
      color: AppColors.achievementDiamond,
      xpBonus: 1000,
    ),
  ];

  /// Get milestone for a given streak count
  static StreakMilestone? getMilestone(int days) {
    for (final milestone in milestones) {
      if (days == milestone.days) {
        return milestone;
      }
    }
    return null;
  }

  /// Check if a day count is a milestone
  static bool isMilestone(int days) => getMilestone(days) != null;
}

/// Streak celebration widget for milestone displays
class StreakCelebration extends ConsumerStatefulWidget {
  const StreakCelebration({
    super.key,
    required this.streakDays,
    this.onDismiss,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 4),
  });

  /// Current streak day count
  final int streakDays;

  /// Callback when dismissed
  final VoidCallback? onDismiss;

  /// Whether to auto-dismiss
  final bool autoDismiss;

  /// Duration before auto-dismiss
  final Duration dismissDuration;

  /// Show streak celebration overlay
  static Future<void> show(
    BuildContext context, {
    required int streakDays,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 4),
  }) async {
    final milestone = StreakMilestone.getMilestone(streakDays);
    if (milestone == null) return;

    // Check for reduce motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (reduceMotion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(milestone.icon, color: milestone.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${milestone.getTitle(isArabic)} $streakDays ${isArabic ? "يوم" : "days"}',
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      onDismiss?.call();
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Streak Celebration',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StreakCelebration(
          streakDays: streakDays,
          onDismiss: onDismiss,
          autoDismiss: autoDismiss,
          dismissDuration: dismissDuration,
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

  @override
  ConsumerState<StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends ConsumerState<StreakCelebration>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _flameController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

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

    try {
      final audioService = ref.read(audioServiceProvider);
      await audioService.playStreak();
    } catch (_) {
      // Ignore audio errors
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final milestone = StreakMilestone.getMilestone(widget.streakDays);
    final size = MediaQuery.of(context).size;

    if (milestone == null) {
      return const SizedBox.shrink();
    }

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        },
        child: Stack(
          children: [
            // Content
            Center(
              child: Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: milestone.color.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: milestone.color,
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated flame icon
                    _buildFlameIcon(milestone),

                    const SizedBox(height: 24),

                    // Streak count
                    Text(
                      '${widget.streakDays}',
                      style: (isArabic
                              ? GoogleFonts.cairo
                              : GoogleFonts.poppins)(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: milestone.color,
                        height: 1,
                      ),
                    )
                        .animate()
                        .fadeIn()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                          duration: 800.ms,
                        ),

                    Text(
                      isArabic ? 'يوم متتالي' : 'Day Streak',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 20),

                    // Milestone title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            milestone.color.withValues(alpha: 0.8),
                            milestone.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                      child: Text(
                        milestone.getTitle(isArabic),
                        style: (isArabic
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(
                          begin: 0.2,
                          end: 0,
                        ),

                    // XP bonus
                    if (milestone.xpBonus > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                          border: Border.all(
                            color: AppColors.xpGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.xpGold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${milestone.xpBonus} XP ${isArabic ? "مكافأة" : "Bonus"}',
                              style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                color: AppColors.xpGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .shimmer(
                            delay: 600.ms,
                            duration: 1500.ms,
                            color: AppColors.xpGold.withValues(alpha: 0.3),
                          ),
                    ],

                    const SizedBox(height: 20),

                    // Tap to continue
                    Text(
                      isArabic ? 'اضغط للمتابعة' : 'Tap to continue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
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
                  milestone.color,
                  milestone.color.withValues(alpha: 0.8),
                  Colors.orange,
                  Colors.yellow,
                  Colors.red,
                ],
                numberOfParticles: 40,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlameIcon(StreakMilestone milestone) {
    // Try Lottie first
    return SizedBox(
      width: 80,
      height: 80,
      child: Lottie.asset(
        'assets/animations/lottie/celebrations/streak_fire.json',
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to animated icon
          return AnimatedBuilder(
            animation: _flameController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_flameController.value * 0.15),
                child: Icon(
                  milestone.icon,
                  size: 70,
                  color: Color.lerp(
                    Colors.orange,
                    milestone.color,
                    _flameController.value,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Small streak indicator widget for home screen
class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.streakDays,
    this.size = 40,
    this.showLabel = true,
  });

  final int streakDays;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Determine color based on streak length
    Color streakColor;
    if (streakDays >= 30) {
      streakColor = AppColors.xpGold;
    } else if (streakDays >= 14) {
      streakColor = Colors.red;
    } else if (streakDays >= 7) {
      streakColor = Colors.deepOrange;
    } else if (streakDays >= 3) {
      streakColor = Colors.orange;
    } else {
      streakColor = theme.colorScheme.onSurfaceVariant;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: streakDays > 0
                ? RadialGradient(
                    colors: [
                      streakColor.withValues(alpha: 0.3),
                      streakColor.withValues(alpha: 0.1),
                    ],
                  )
                : null,
          ),
          child: Icon(
            Icons.local_fire_department,
            size: size * 0.6,
            color: streakColor,
          ),
        )
            .animate(
              onPlay: streakDays >= 7
                  ? (controller) => controller.repeat(reverse: true)
                  : null,
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              duration: 800.ms,
            ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streakDays',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
              Text(
                isArabic ? 'يوم' : 'days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
