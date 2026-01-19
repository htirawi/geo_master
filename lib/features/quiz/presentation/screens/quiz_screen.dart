import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../domain/repositories/i_quiz_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';

/// Selected difficulty provider for the quiz screen
final _selectedDifficultyProvider =
    StateProvider<QuizDifficulty>((ref) => QuizDifficulty.medium);

/// Quiz mode selection screen - Challenge Arena Theme
/// An adventure-styled quiz selection experience
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedDifficulty = ref.watch(_selectedDifficultyProvider);
    final quizStats = ref.watch(quizStatisticsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Challenge Arena Header
          SliverToBoxAdapter(
            child: _ChallengeHeader(isArabic: isArabic),
          ),
          // Stats Overview
          SliverToBoxAdapter(
            child: _StatsOverview(stats: quizStats)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          // Difficulty Selector
          SliverToBoxAdapter(
            child: _DifficultySection(
              selectedDifficulty: selectedDifficulty,
              onDifficultyChanged: (difficulty) {
                HapticFeedback.selectionClick();
                ref.read(_selectedDifficultyProvider.notifier).state = difficulty;
              },
              isArabic: isArabic,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),
          // Quiz Modes Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.selectChallenge,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),
          // Quiz Mode Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuizModeCard(
                  icon: Icons.location_city,
                  title: l10n.quizModeCapitals,
                  description: l10n.quizModeCapitalsDescription,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 195,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.capitals, selectedDifficulty),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.flag,
                  title: l10n.quizModeFlags,
                  description: l10n.quizModeFlagsDescription,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 195,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.flags, selectedDifficulty),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.map,
                  title: l10n.quizModeMap,
                  description: l10n.quizModeMapDescription,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 195,
                  isPremium: true,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.maps, selectedDifficulty),
                ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.people,
                  title: l10n.quizModePopulation,
                  description: l10n.quizModePopulationDescription,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFCA28), Color(0xFFFFE082)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 100,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.population, selectedDifficulty),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.attach_money,
                  title: l10n.quizModeCurrency,
                  description: l10n.quizModeCurrencyDescription,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 150,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.currencies, selectedDifficulty),
                ).animate().fadeIn(delay: 650.ms, duration: 400.ms),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _startQuiz(
    BuildContext context,
    WidgetRef ref,
    QuizMode mode,
    QuizDifficulty difficulty,
  ) {
    HapticFeedback.mediumImpact();

    // Check premium access for map mode
    if (mode == QuizMode.maps) {
      final isPremium = ref.read(isPremiumProvider);
      if (!isPremium) {
        context.push(Routes.paywall);
        return;
      }
    }

    context.push(
      '${Routes.quizGame}?mode=${mode.name}&difficulty=${difficulty.name}',
    );
  }
}

/// Challenge Arena Header
class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6D00), Color(0xFFFF8F00), Color(0xFFFFAB00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _ChallengePatternPainter(),
            ),
          ),
          // Trophy icon
          Positioned(
            right: isArabic ? null : -30,
            left: isArabic ? -30 : null,
            top: 50,
            child: Icon(
              Icons.emoji_events,
              size: 180,
              color: Colors.white.withValues(alpha: 0.1),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.challengeArena,
                            style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.selectChallenge,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
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

/// Challenge pattern painter
class _ChallengePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw hexagonal pattern
    const hexSize = 40.0;
    for (double y = -hexSize; y < size.height + hexSize; y += hexSize * 1.5) {
      for (double x = -hexSize; x < size.width + hexSize; x += hexSize * 1.73) {
        final offsetY = ((x / (hexSize * 1.73)).floor() % 2 == 0) ? 0.0 : hexSize * 0.75;
        _drawHexagon(canvas, Offset(x, y + offsetY), hexSize * 0.3, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    // Draw simplified hexagon
    path.addPolygon([
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius * 0.866, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.866, center.dy + radius * 0.5),
      Offset(center.dx, center.dy + radius),
      Offset(center.dx - radius * 0.866, center.dy + radius * 0.5),
      Offset(center.dx - radius * 0.866, center.dy - radius * 0.5),
    ], true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stats overview card
class _StatsOverview extends StatelessWidget {
  const _StatsOverview({required this.stats});

  final AsyncValue<QuizStatistics> stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return stats.when(
      data: (statistics) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
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
          child: Row(
            children: [
              _StatItem(
                icon: Icons.check_circle,
                value: '${statistics.totalQuizzes}',
                label: l10n.quizzesCompleted,
                color: AppColors.success,
              ),
              _buildDivider(context),
              _StatItem(
                icon: Icons.gps_fixed,
                value: '${statistics.averageAccuracy.toStringAsFixed(0)}%',
                label: l10n.accuracy,
                color: AppColors.primary,
              ),
              _buildDivider(context),
              _StatItem(
                icon: Icons.star,
                value: '${statistics.correctAnswers}',
                label: l10n.correctAnswers,
                color: AppColors.xpGold,
              ),
            ],
          ),
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Difficulty selection section
class _DifficultySection extends StatelessWidget {
  const _DifficultySection({
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.isArabic,
  });

  final QuizDifficulty selectedDifficulty;
  final ValueChanged<QuizDifficulty> onDifficultyChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.speed, color: AppColors.secondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.difficultyLevel,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _DifficultyCard(
                  title: l10n.difficultyEasy,
                  description: l10n.easyDescription,
                  icon: Icons.spa,
                  color: AppColors.difficultyEasy,
                  isSelected: selectedDifficulty == QuizDifficulty.easy,
                  onTap: () => onDifficultyChanged(QuizDifficulty.easy),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DifficultyCard(
                  title: l10n.difficultyMedium,
                  description: l10n.mediumDescription,
                  icon: Icons.hiking,
                  color: AppColors.difficultyMedium,
                  isSelected: selectedDifficulty == QuizDifficulty.medium,
                  onTap: () => onDifficultyChanged(QuizDifficulty.medium),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DifficultyCard(
                  title: l10n.difficultyHard,
                  description: l10n.hardDescription,
                  icon: Icons.terrain,
                  color: AppColors.difficultyHard,
                  isSelected: selectedDifficulty == QuizDifficulty.hard,
                  onTap: () => onDifficultyChanged(QuizDifficulty.hard),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: isSelected ? Colors.white70 : Colors.grey[500],
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

/// Quiz mode card
class _QuizModeCard extends StatelessWidget {
  const _QuizModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.questionsCount,
    this.isPremium = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  final int questionsCount;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _CardPatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PRO',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$questionsCount ${l10n.questions}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Play button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
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

/// Card pattern painter
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle circular patterns
    for (double i = 0; i < 3; i++) {
      final radius = size.width * 0.2 + i * 30;
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.5),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
