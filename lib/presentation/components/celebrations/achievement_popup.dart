import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/achievement.dart';
import '../../providers/audio_provider.dart';

/// Achievement unlock popup modal
/// Displays with slide-up animation, trophy Lottie, and sound effect
class AchievementPopup extends ConsumerStatefulWidget {
  const AchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 4),
  });

  /// The achievement that was unlocked
  final Achievement achievement;

  /// Callback when popup is dismissed
  final VoidCallback? onDismiss;

  /// Whether to auto-dismiss after duration
  final bool autoDismiss;

  /// Duration before auto-dismiss
  final Duration dismissDuration;

  /// Show achievement popup as overlay
  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
    Duration dismissDuration = const Duration(seconds: 4),
  }) async {
    // Check for reduce motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      // Show simple snackbar instead
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: _getTierColor(achievement.tier),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.getDisplayName(isArabic: Localizations.localeOf(context).languageCode == 'ar'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      achievement.getDisplayDescription(isArabic: Localizations.localeOf(context).languageCode == 'ar'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
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
      barrierLabel: 'Achievement',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AchievementPopup(
          achievement: achievement,
          onDismiss: onDismiss,
          autoDismiss: autoDismiss,
          dismissDuration: dismissDuration,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: child,
        );
      },
    );
  }

  static Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return AppColors.achievementBronze;
      case AchievementTier.silver:
        return AppColors.achievementSilver;
      case AchievementTier.gold:
        return AppColors.achievementGold;
      case AchievementTier.platinum:
        return AppColors.achievementPlatinum;
      case AchievementTier.diamond:
        return AppColors.achievementDiamond;
    }
  }

  @override
  ConsumerState<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends ConsumerState<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Play sound and haptic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCelebration();
    });

    // Auto dismiss
    if (widget.autoDismiss) {
      Future.delayed(widget.dismissDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        }
      });
    }
  }

  Future<void> _playCelebration() async {
    HapticFeedback.mediumImpact();
    try {
      final audioService = ref.read(audioServiceProvider);
      await audioService.playAchievement();
    } catch (_) {
      // Ignore audio errors
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tierColor = AchievementPopup._getTierColor(widget.achievement.tier);
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
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),

            // Popup content
            Align(
              alignment: Alignment.center,
              child: Container(
                width: size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXL,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tierColor.withValues(
                              alpha: 0.3 + (_glowController.value * 0.3),
                            ),
                            blurRadius: 20 + (_glowController.value * 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surface.withValues(alpha: 0.95),
                          ],
                        ),
                        border: Border.all(
                          color: tierColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXL,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with tier color
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  tierColor.withValues(alpha: 0.8),
                                  tierColor,
                                ],
                              ),
                            ),
                            child: Text(
                              _getTierName(widget.achievement.tier, isArabic),
                              textAlign: TextAlign.center,
                              style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Trophy icon or Lottie
                                _buildTrophyIcon(tierColor),

                                const SizedBox(height: 20),

                                // Achievement unlocked label
                                Text(
                                  isArabic
                                      ? 'تم فتح الإنجاز!'
                                      : 'Achievement Unlocked!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: tierColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).animate().fadeIn(delay: 200.ms),

                                const SizedBox(height: 12),

                                // Achievement title
                                Text(
                                  widget.achievement.getDisplayName(isArabic: isArabic),
                                  textAlign: TextAlign.center,
                                  style: (isArabic
                                          ? GoogleFonts.cairo
                                          : GoogleFonts.poppins)(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideY(
                                      begin: 0.2,
                                      end: 0,
                                    ),

                                const SizedBox(height: 8),

                                // Achievement description
                                Text(
                                  widget.achievement.getDisplayDescription(isArabic: isArabic),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),

                                // XP reward if any
                                if (widget.achievement.xpReward > 0) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.xpGold.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMD,
                                      ),
                                      border: Border.all(
                                        color: AppColors.xpGold
                                            .withValues(alpha: 0.3),
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
                                          '+${widget.achievement.xpReward} XP',
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
                                      .fadeIn(delay: 500.ms)
                                      .shimmer(
                                        delay: 800.ms,
                                        duration: 1500.ms,
                                        color:
                                            AppColors.xpGold.withValues(alpha: 0.3),
                                      ),
                                ],

                                const SizedBox(height: 20),

                                // Tap to continue hint
                                Text(
                                  isArabic
                                      ? 'اضغط للمتابعة'
                                      : 'Tap to continue',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ).animate().fadeIn(delay: 700.ms),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyIcon(Color tierColor) {
    // Try to use Lottie animation if available
    return SizedBox(
      width: 100,
      height: 100,
      child: Lottie.asset(
        'assets/animations/lottie/celebrations/trophy_shine.json',
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to animated icon
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  tierColor.withValues(alpha: 0.3),
                  tierColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.emoji_events,
              size: 50,
              color: tierColor,
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 1000.ms,
              );
        },
      ),
    );
  }

  String _getTierName(AchievementTier tier, bool isArabic) {
    if (isArabic) {
      switch (tier) {
        case AchievementTier.bronze:
          return 'برونزي';
        case AchievementTier.silver:
          return 'فضي';
        case AchievementTier.gold:
          return 'ذهبي';
        case AchievementTier.platinum:
          return 'بلاتيني';
        case AchievementTier.diamond:
          return 'ماسي';
      }
    } else {
      switch (tier) {
        case AchievementTier.bronze:
          return 'BRONZE';
        case AchievementTier.silver:
          return 'SILVER';
        case AchievementTier.gold:
          return 'GOLD';
        case AchievementTier.platinum:
          return 'PLATINUM';
        case AchievementTier.diamond:
          return 'DIAMOND';
      }
    }
  }
}
