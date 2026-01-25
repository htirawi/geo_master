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
import '../../../../presentation/components/headers/explorer_hero_header.dart';

/// Stats and gamification screen - Explorer's Journal Theme
/// A beautifully designed journey progress tracker
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Journal Header
          SliverToBoxAdapter(
            child: _JournalHeader(isArabic: isArabic),
          ),
          // Main content wrapped in ResponsiveCenter
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              child: Column(
                children: [
                  // Level Progress Card
                  const _ExpeditionRankCard()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  // Journey Stats
                  const _JourneyStatsSection()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms),
                  // Achievements Section
                  _AchievementsSection(isArabic: isArabic)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),
                  // Region Progress
                  _RegionProgressSection(isArabic: isArabic)
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms),
                  // Bottom spacing
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Journal Header
class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.journal,
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _JournalPatternPainter(),
            ),
          ),
          // Compass icon
          Positioned(
            right: isArabic ? null : -AppDimensions.lg,
            left: isArabic ? -AppDimensions.lg : null,
            top: 60,
            child: Icon(
              Icons.explore,
              size: 160,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: AppDimensions.iconLG - 4,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md - 2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.explorerJournal,
                            style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.journeyProgress,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Leaderboard button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push(Routes.leaderboard);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD + 2),
                          ),
                          child: const Icon(
                            Icons.leaderboard,
                            color: Colors.white,
                            size: AppDimensions.iconMD,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: AppDimensions.durationSlow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Journal pattern painter
class _JournalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw compass rose pattern
    final center = Offset(size.width * 0.85, size.height * 0.5);
    const radius = 80.0;

    // Cardinal lines
    for (int i = 0; i < 8; i++) {
      final innerRadius = i % 2 == 0 ? radius * 0.3 : radius * 0.5;
      canvas.drawLine(
        Offset(center.dx + innerRadius * (i % 2 == 0 ? 1 : 0.7) * (i < 4 ? 1 : -1) * (i % 4 == 0 ? 0 : 1),
               center.dy + innerRadius * (i % 4 == 0 ? 1 : 0) * (i < 2 || i > 5 ? -1 : 1)),
        Offset(center.dx + radius * 0.9 * (i < 4 ? 1 : -1) * (i % 4 == 0 ? 0 : 1),
               center.dy + radius * 0.9 * (i % 4 == 0 ? 1 : 0) * (i < 2 || i > 5 ? -1 : 1)),
        paint,
      );
    }

    // Concentric circles
    for (double r = 30; r <= radius; r += 25) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Expedition Rank Card
class _ExpeditionRankCard extends StatelessWidget {
  const _ExpeditionRankCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Sample data
    const level = 12;
    const currentXP = 2450;
    const xpForNextLevel = 3000;
    const progress = currentXP / xpForNextLevel;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppDimensions.borderRadiusXL,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: AppDimensions.blurMedium,
              offset: const Offset(0, AppDimensions.xs),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusXL,
                child: CustomPaint(
                  painter: _RankPatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Level badge
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.xpGold,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.xpGold.withValues(alpha: 0.3),
                              blurRadius: AppDimensions.blurMedium - 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$level',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                l10n.level,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.lg),
                      // XP info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.geographyExplorer,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.xxs),
                            Text(
                              '$currentXP / $xpForNextLevel XP',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sm - 2),
                            // Progress bar
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.xpGold, Color(0xFFFFE082)],
                                      ),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.xpGold.withValues(alpha: 0.5),
                                          blurRadius: AppDimensions.xxs + 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  // XP needed
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm - 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: AppColors.xpGold,
                          size: 18,
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Text(
                          '${xpForNextLevel - currentXP} XP ${l10n.toNextLevel}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
}

/// Rank pattern painter
class _RankPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw star pattern
    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        _drawStar(canvas, Offset(x + 30, y + 30), 8, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw simplified star as a circle
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Journey Stats Section
class _JourneyStatsSection extends StatelessWidget {
  const _JourneyStatsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppDimensions.borderRadiusXL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppDimensions.blurLight + 2,
              offset: const Offset(0, AppDimensions.xxs),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _JourneyStatCard(
                    icon: Icons.public,
                    value: '42',
                    label: l10n.countriesLearned,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _JourneyStatCard(
                    icon: Icons.quiz,
                    value: '156',
                    label: l10n.quizzesCompleted,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: _JourneyStatCard(
                    icon: Icons.check_circle,
                    value: '78%',
                    label: l10n.accuracy,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _JourneyStatCard(
                    icon: Icons.local_fire_department,
                    value: '7',
                    label: l10n.dayStreak(7),
                    color: AppColors.streak,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStatCard extends StatelessWidget {
  const _JourneyStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm - 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconSM + 2),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievements Section
class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Sample achievements
    const achievements = [
      _Achievement('First Steps', Icons.directions_walk, true, AppColors.success),
      _Achievement('Quiz Master', Icons.emoji_events, true, AppColors.xpGold),
      _Achievement('Explorer', Icons.explore, true, AppColors.tertiary),
      _Achievement('Globetrotter', Icons.flight, false, AppColors.primary),
      _Achievement('Geography Pro', Icons.school, false, AppColors.premium),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppDimensions.xxs, bottom: AppDimensions.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: AppColors.achievement.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM + 2),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.achievement,
                    size: AppDimensions.iconSM,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  l10n.recentAchievements,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(Routes.achievements);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xxs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.achievement.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM + 2),
                    ),
                    child: Text(
                      l10n.viewAll,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.achievement,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Achievement badges
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _AchievementBadge(
                  achievement: achievement,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  const _Achievement(this.name, this.icon, this.isUnlocked, this.color);

  final String name;
  final IconData icon;
  final bool isUnlocked;
  final Color color;
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.achievement,
    required this.index,
  });

  final _Achievement achievement;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsetsDirectional.only(end: AppDimensions.sm),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: achievement.isUnlocked
                  ? LinearGradient(
                      colors: [
                        achievement.color,
                        achievement.color.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: achievement.isUnlocked ? null : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: achievement.isUnlocked
                  ? [
                      BoxShadow(
                        color: achievement.color.withValues(alpha: 0.3),
                        blurRadius: AppDimensions.blurLight + 2,
                        offset: const Offset(0, AppDimensions.xxs),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? Colors.white : Colors.grey[400],
              size: AppDimensions.iconLG,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            achievement.name,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: achievement.isUnlocked ? FontWeight.w600 : FontWeight.normal,
              color: achievement.isUnlocked
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        );
  }
}

/// Region Progress Section
class _RegionProgressSection extends StatelessWidget {
  const _RegionProgressSection({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final regions = [
      _RegionProgress(l10n.europe, 'Europe', 32, 44, AppColors.regionEurope, Icons.castle),
      _RegionProgress(l10n.asia, 'Asia', 18, 48, AppColors.regionAsia, Icons.temple_buddhist),
      _RegionProgress(l10n.africa, 'Africa', 12, 54, AppColors.regionAfrica, Icons.wb_sunny),
      _RegionProgress(l10n.americas, 'Americas', 15, 35, AppColors.regionAmericas, Icons.landscape),
      _RegionProgress(l10n.oceania, 'Oceania', 5, 14, AppColors.regionOceania, Icons.waves),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppDimensions.xxs, bottom: AppDimensions.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM + 2),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: AppColors.primary,
                    size: AppDimensions.iconSM,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  l10n.progressByRegion,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Region progress tiles
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL - 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: AppDimensions.blurLight + 2,
                  offset: const Offset(0, AppDimensions.xxs),
                ),
              ],
            ),
            child: Column(
              children: regions
                  .asMap()
                  .entries
                  .map((entry) => _RegionProgressTile(
                        region: entry.value,
                        isLast: entry.key == regions.length - 1,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionProgress {
  const _RegionProgress(
    this.name,
    this.id,
    this.learned,
    this.total,
    this.color,
    this.icon,
  );

  final String name;
  final String id;
  final int learned;
  final int total;
  final Color color;
  final IconData icon;

  double get progress => learned / total;
}

class _RegionProgressTile extends StatelessWidget {
  const _RegionProgressTile({
    required this.region,
    required this.isLast,
  });

  final _RegionProgress region;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.md),
      child: Row(
        children: [
          // Region icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [region.color, region.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD + 2),
            ),
            child: Icon(region.icon, color: Colors.white, size: AppDimensions.iconSM + 2),
          ),
          const SizedBox(width: AppDimensions.md - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      region.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm - 2,
                        vertical: AppDimensions.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: region.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM + 2),
                      ),
                      child: Text(
                        '${region.learned}/${region.total}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: region.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: AppDimensions.xs,
                      decoration: BoxDecoration(
                        color: region.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.xxs),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: region.progress,
                      child: Container(
                        height: AppDimensions.xs,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              region.color,
                              region.color.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppDimensions.xxs),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
