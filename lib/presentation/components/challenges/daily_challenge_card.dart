import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/daily_challenge.dart';
import '../../providers/daily_challenge_provider.dart';

/// Daily Challenge Card - Displays today's challenge with progress
///
/// Features:
/// - Shows current challenge details
/// - Progress indicator
/// - Countdown timer
/// - Streak display
/// - Completion celebration
class DailyChallengeCard extends ConsumerStatefulWidget {
  const DailyChallengeCard({
    super.key,
    required this.userId,
    this.onTap,
    this.onComplete,
    this.compact = false,
  });

  final String userId;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool compact;

  @override
  ConsumerState<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends ConsumerState<DailyChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(dailyChallengeProvider);
    final streakAsync = ref.watch(challengeStreakProvider(widget.userId));
    final timeRemaining = ref.watch(challengeTimeRemainingProvider);

    return challengeAsync.when(
      data: (challenge) {
        final streak = streakAsync.valueOrNull ?? ChallengeStreak.initial(widget.userId);
        return _buildCard(context, challenge, streak, timeRemaining.valueOrNull);
      },
      loading: () => _buildLoadingCard(context),
      error: (_, __) => _buildErrorCard(context),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DailyChallenge challenge,
    ChallengeStreak streak,
    Duration? timeRemaining,
  ) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Get progress (mock for now)
    const progress = 0.0; // Would come from provider
    final isCompleted = streak.completedToday;

    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isCompleted
          ? [
              AppColors.success.withValues(alpha: 0.9),
              AppColors.success.withValues(alpha: 0.7),
            ]
          : [
              challenge.difficulty.color.withValues(alpha: 0.9),
              challenge.difficulty.color.withValues(alpha: 0.6),
            ],
    );

    Widget card = GestureDetector(
      onTap: () {
        if (!isCompleted) {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? AppColors.success : challenge.difficulty.color)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _ChallengeBgPainter(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(
                  widget.compact ? AppDimensions.sm : AppDimensions.md,
                ),
                child: widget.compact
                    ? _buildCompactContent(
                        context, challenge, streak, progress, isCompleted, isArabic)
                    : _buildFullContent(
                        context, challenge, streak, progress, timeRemaining, isCompleted, isArabic),
              ),

              // Completed overlay
              if (isCompleted)
                Positioned(
                  top: AppDimensions.sm,
                  right: AppDimensions.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'مكتمل' : 'Completed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Animate if not completed
    if (!isCompleted && !reduceMotion) {
      card = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildFullContent(
    BuildContext context,
    DailyChallenge challenge,
    ChallengeStreak streak,
    double progress,
    Duration? timeRemaining,
    bool isCompleted,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                challenge.type.iconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'التحدي اليومي' : 'Daily Challenge',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    challenge.getTitle(isArabic),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Streak badge
            if (streak.currentStreak > 0)
              _buildStreakBadge(context, streak.currentStreak, isArabic),
          ],
        ),

        const SizedBox(height: AppDimensions.md),

        // Description
        Text(
          challenge.getDescription(isArabic),
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppDimensions.md),

        // Progress bar
        _buildProgressBar(context, progress, challenge.targetValue, isArabic),

        const SizedBox(height: AppDimensions.md),

        // Bottom row: XP reward and timer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // XP reward
            Row(
              children: [
                const Icon(
                  Icons.stars,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${challenge.getTotalXpReward(streak.currentStreak)} XP',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Timer
            if (timeRemaining != null && !isCompleted)
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeRemaining.toFormattedString(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    DailyChallenge challenge,
    ChallengeStreak streak,
    double progress,
    bool isCompleted,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(AppDimensions.xs),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(
            challenge.type.iconData,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                challenge.getTitle(isArabic),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppDimensions.sm),

        // XP
        Text(
          '+${challenge.xpReward}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak, bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.streak.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 2),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    int target,
    bool isArabic,
  ) {
    final current = (progress * target).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'التقدم' : 'Progress',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              '$current / $target',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      height: 160,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppDimensions.sm),
          Text(
            isArabic
                ? 'تعذر تحميل التحدي'
                : 'Failed to load challenge',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Background painter for the challenge card
class _ChallengeBgPainter extends CustomPainter {
  _ChallengeBgPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw decorative circles
    for (var i = 0; i < 3; i++) {
      final radius = 30.0 + (i * 20);
      canvas.drawCircle(
        Offset(size.width - 20, 20),
        radius,
        paint,
      );
    }

    // Draw decorative lines
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final y = size.height * 0.2 + (i * 15);
      path.moveTo(0, y);
      path.lineTo(30 + (i * 10), y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple daily challenge summary widget for dashboard
class DailyChallengeSummary extends ConsumerWidget {
  const DailyChallengeSummary({
    super.key,
    required this.userId,
    this.onTap,
  });

  final String userId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(dailyChallengeProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return challengeAsync.when(
      data: (challenge) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: challenge.difficulty.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: challenge.difficulty.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                challenge.type.iconData,
                color: challenge.difficulty.color,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  challenge.getTitle(isArabic),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '+${challenge.xpReward}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: challenge.difficulty.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
