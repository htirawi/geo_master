import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
          // Level Progress Card
          SliverToBoxAdapter(
            child: const _ExpeditionRankCard()
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          // Journey Stats
          SliverToBoxAdapter(
            child: const _JourneyStatsSection()
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
          ),
          // Achievements Section
          SliverToBoxAdapter(
            child: _AchievementsSection(isArabic: isArabic)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
          ),
          // Region Progress
          SliverToBoxAdapter(
            child: _RegionProgressSection(isArabic: isArabic)
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),
          ),
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
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
        gradient: LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF795548), Color(0xFF8D6E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            right: isArabic ? null : -20,
            left: isArabic ? -20 : null,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.leaderboard,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
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
      final angle = i * 45 * 3.14159 / 180;
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
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _RankPatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
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
                              blurRadius: 12,
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
                      const SizedBox(width: 20),
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
                            const SizedBox(height: 4),
                            Text(
                              '$currentXP / $xpForNextLevel XP',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Progress bar
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
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
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.xpGold.withValues(alpha: 0.5),
                                          blurRadius: 6,
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
                  const SizedBox(height: 16),
                  // XP needed
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: AppColors.xpGold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
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
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final point = Offset(
        center.dx + radius * (i % 2 == 0 ? 1 : 0.4) * (i == 0 ? 0 : (i < 3 ? 1 : -1)),
        center.dy + radius * (i == 0 ? -1 : (i < 3 ? 0.3 : 0.3)) * (i == 4 ? -1 : 1),
      );
      if (i == 0) {
        path.moveTo(center.dx, center.dy - radius);
      }
    }
    path.close();
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                const SizedBox(width: 16),
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
            const SizedBox(height: 16),
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
                const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
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
    final achievements = [
      _Achievement('First Steps', Icons.directions_walk, true, AppColors.success),
      _Achievement('Quiz Master', Icons.emoji_events, true, AppColors.xpGold),
      _Achievement('Explorer', Icons.explore, true, AppColors.tertiary),
      _Achievement('Globetrotter', Icons.flight, false, AppColors.primary),
      _Achievement('Geography Pro', Icons.school, false, AppColors.premium),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.achievement.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.achievement,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.achievement.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
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
      margin: const EdgeInsets.only(right: 12),
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
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? Colors.white : Colors.grey[400],
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(region.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
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
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: region.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 8),
                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: region.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: region.progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              region.color,
                              region.color.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
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
