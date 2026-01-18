import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/providers/user_provider.dart';

/// Home screen - Explorer's Dashboard
/// An immersive geography-themed home screen that makes users feel like world explorers
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Immersive Hero Header
          SliverToBoxAdapter(
            child: _ExplorerHeader(
              userName: user?.displayName,
              isArabic: isArabic,
            ),
          ),
          // Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // Today's Destination (Country of the Day) - Most prominent
                _TodaysDestinationCard(isArabic: isArabic)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                // Quick Actions - Compass Style
                const _CompassActions()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                // Daily Challenge Card
                const _DailyChallengeCard()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                // Expedition Progress (Streak + Stats)
                const _ExpeditionProgressCard()
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                // World Progress Map Preview
                const _WorldProgressPreview()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Immersive explorer header with greeting and world visual
class _ExplorerHeader extends StatelessWidget {
  const _ExplorerHeader({this.userName, required this.isArabic});

  final String? userName;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;

    String greeting;
    IconData timeIcon;
    if (hour < 12) {
      greeting = l10n.goodMorning;
      timeIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
      timeIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = l10n.goodEvening;
      timeIcon = Icons.nightlight_round;
    }

    return Container(
      height: 270,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF002171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative world pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _WorldPatternPainter(),
            ),
          ),
          // Decorative floating elements
          ..._buildFloatingElements(),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(timeIcon, color: AppColors.sunrise, size: 24),
                      ),
                      const Spacer(),
                      // Notification bell
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    greeting,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    userName ?? l10n.explorer,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sunrise.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sunrise.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore, color: AppColors.sunrise, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.readyToExplore,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.sunrise,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return [
      Positioned(
        right: -30,
        top: 60,
        child: Icon(
          Icons.public,
          size: 150,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      Positioned(
        left: 20,
        bottom: 20,
        child: Icon(
          Icons.flight_takeoff,
          size: 30,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    ];
  }
}

/// Custom painter for world pattern background
class _WorldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw latitude lines
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw longitude curves
    for (int i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      final path = Path()
        ..moveTo(x - 20, 0)
        ..quadraticBezierTo(x, size.height / 2, x + 20, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Today's Destination - Featured Country Card
class _TodaysDestinationCard extends ConsumerWidget {
  const _TodaysDestinationCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryAsync = ref.watch(countryOfTheDayProvider);

    return countryAsync.when(
      data: (country) {
        if (country == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('${Routes.countryDetail}/${country.code}');
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Flag background with gradient overlay
                  CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.primary),
                    errorWidget: (_, __, ___) => Container(color: AppColors.primary),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.sunrise,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pin_drop, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                l10n.countryOfTheDay,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Country name and info
                        Text(
                          country.getDisplayName(isArabic: isArabic),
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                              color: Colors.white.withValues(alpha: 0.8), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              country.region,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.people,
                              color: Colors.white.withValues(alpha: 0.8), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              country.formattedPopulation,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Explore arrow
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_forward,
                        color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Compass-style Quick Actions
class _CompassActions extends StatelessWidget {
  const _CompassActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _CompassActionItem(
            icon: Icons.quiz_rounded,
            label: l10n.quickQuiz,
            color: AppColors.secondary,
            gradient: AppColors.sunsetGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(Routes.quiz);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CompassActionItem(
            icon: Icons.explore_rounded,
            label: l10n.explore,
            color: AppColors.tertiary,
            gradient: AppColors.forestGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(Routes.explore);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CompassActionItem(
            icon: Icons.smart_toy_rounded,
            label: l10n.aiTutor,
            color: AppColors.primary,
            gradient: AppColors.oceanGradient,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(Routes.aiTutor);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CompassActionItem(
            icon: Icons.emoji_events_rounded,
            label: l10n.achievements,
            color: AppColors.xpGold,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8F00), Color(0xFFFFD54F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(Routes.achievements);
            },
          ),
        ),
      ],
    );
  }
}

class _CompassActionItem extends StatelessWidget {
  const _CompassActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily Challenge Card with adventure theme
class _DailyChallengeCard extends ConsumerWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Challenge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.xpGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.dailyChallenge,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.dailyChallengeDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+100 XP',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Start button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('${Routes.quizGame}?mode=capitals&difficulty=medium');
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF6A1B9A),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expedition Progress Card - Streak + Stats
class _ExpeditionProgressCard extends ConsumerWidget {
  const _ExpeditionProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(userProgressProvider);
    final streak = progress.currentStreak;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department,
                  color: AppColors.streak, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expeditionStreak,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      streak > 0 ? l10n.keepItUp : l10n.startStreak,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.streak, Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.days,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Week progress visualization
          _WeekProgressBar(streak: streak),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _MiniStatItem(
                icon: Icons.public,
                value: '${progress.countriesLearned}',
                label: l10n.countriesLabel,
                color: AppColors.primary,
              ),
              _MiniStatItem(
                icon: Icons.quiz,
                value: '${progress.quizzesCompleted}',
                label: l10n.quizzesLabel,
                color: AppColors.tertiary,
              ),
              _MiniStatItem(
                icon: Icons.star,
                value: _formatXp(progress.totalXp),
                label: l10n.xpLabel,
                color: AppColors.xpGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }
}

class _WeekProgressBar extends StatelessWidget {
  const _WeekProgressBar({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun];
    final today = DateTime.now().weekday - 1;
    final daysCompleted = streak.clamp(0, 7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isCompleted = index < daysCompleted;
        final isToday = index == today;

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.streak
                    : isToday
                        ? AppColors.streak.withValues(alpha: 0.2)
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isCompleted
                    ? Border.all(color: AppColors.streak, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              days[index],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? AppColors.streak
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  const _MiniStatItem({
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// World Progress Preview - Mini world map with region progress
class _WorldProgressPreview extends ConsumerWidget {
  const _WorldProgressPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final regions = [
      _RegionData(l10n.europe, 32, 44, AppColors.regionEurope, Icons.castle),
      _RegionData(l10n.asia, 18, 48, AppColors.regionAsia, Icons.temple_buddhist),
      _RegionData(l10n.africa, 12, 54, AppColors.regionAfrica, Icons.wb_sunny),
      _RegionData(l10n.americas, 15, 35, AppColors.regionAmericas, Icons.landscape),
      _RegionData(l10n.oceania, 5, 14, AppColors.regionOceania, Icons.waves),
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.public, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.worldProgress,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(Routes.stats),
                child: Text(
                  l10n.viewAll,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Region progress bars
          ...regions.map((region) => _RegionProgressItem(region: region)),
        ],
      ),
    );
  }
}

class _RegionData {
  const _RegionData(this.name, this.learned, this.total, this.color, this.icon);

  final String name;
  final int learned;
  final int total;
  final Color color;
  final IconData icon;

  double get progress => learned / total;
}

class _RegionProgressItem extends StatelessWidget {
  const _RegionProgressItem({required this.region});

  final _RegionData region;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: region.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(region.icon, color: region.color, size: 16),
          ),
          const SizedBox(width: 12),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      '${region.learned}/${region.total}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: region.progress,
                    backgroundColor: region.color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(region.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
