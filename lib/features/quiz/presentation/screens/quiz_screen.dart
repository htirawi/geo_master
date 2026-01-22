import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/quiz.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/quiz_provider.dart';
import '../../../../presentation/providers/subscription_provider.dart';

/// Selected difficulty provider for the quiz screen
final _selectedDifficultyProvider =
    StateProvider<QuizDifficulty>((ref) => QuizDifficulty.medium);

/// Selected continent provider for continent challenge
final _selectedContinentProvider = StateProvider<String?>((ref) => null);

/// Quiz mode selection screen - Challenge Arena Theme
/// An adventure-styled quiz selection experience with all game modes
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedDifficulty = ref.watch(_selectedDifficultyProvider);
    final quizStats = ref.watch(quizStatisticsProvider);
    final isDailyChallengeCompleted = ref.watch(isDailyChallengeCompletedProvider);
    final currentStreak = ref.watch(currentStreakProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Challenge Arena Header
          SliverToBoxAdapter(
            child: _ChallengeHeader(isArabic: isArabic, streak: currentStreak),
          ),
          // Stats Overview
          SliverToBoxAdapter(
            child: _StatsOverview(stats: quizStats)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          // Game Modes Section (Session Types)
          SliverToBoxAdapter(
            child: _GameModesSection(
              selectedDifficulty: selectedDifficulty,
              isDailyChallengeCompleted: isDailyChallengeCompleted.valueOrNull ?? false,
              isArabic: isArabic,
              onSelectContinent: (continent) {
                ref.read(_selectedContinentProvider.notifier).state = continent;
              },
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
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
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
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
                      Icons.category,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'اختر نوع السؤال' : 'Choose Topic',
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
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
                ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
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
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.flag_outlined,
                  title: isArabic ? 'الأعلام المعكوسة' : 'Reverse Flags',
                  description: isArabic
                      ? 'اختر العلم الصحيح للدولة'
                      : 'Select the flag for the country',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 195,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.reverseFlags, selectedDifficulty),
                ).animate().fadeIn(delay: 650.ms, duration: 400.ms),
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
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
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
                ).animate().fadeIn(delay: 750.ms, duration: 400.ms),
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
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.translate,
                  title: isArabic ? 'اللغات' : 'Languages',
                  description: isArabic
                      ? 'حدد اللغات الرسمية'
                      : 'Identify official languages',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF9FA8DA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 150,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.languages, selectedDifficulty),
                ).animate().fadeIn(delay: 850.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.share_location,
                  title: isArabic ? 'الدول المجاورة' : 'Neighbors',
                  description: isArabic
                      ? 'اختر الدول المجاورة'
                      : 'Select neighboring countries',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 150,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.borders, selectedDifficulty),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _QuizModeCard(
                  icon: Icons.shuffle,
                  title: isArabic ? 'مختلط' : 'Mixed',
                  description: isArabic
                      ? 'خليط عشوائي من جميع المواضيع'
                      : 'Random mix of all topics',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF37474F), Color(0xFF78909C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  questionsCount: 195,
                  onTap: () =>
                      _startQuiz(context, ref, QuizMode.mixed, selectedDifficulty),
                ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
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
    if (mode == QuizMode.maps || mode == QuizMode.landmarks) {
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

/// Challenge Arena Header with streak display
class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({required this.isArabic, required this.streak});

  final bool isArabic;
  final int streak;

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
                      Expanded(
                        child: Column(
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
                      ),
                      // Streak badge
                      if (streak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
                icon: Icons.local_fire_department,
                value: '${statistics.bestStreak}',
                label: l10n.bestStreak,
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

/// Game Modes Section - Session Types (Quick Quiz, Timed Blitz, etc.)
class _GameModesSection extends ConsumerWidget {
  const _GameModesSection({
    required this.selectedDifficulty,
    required this.isDailyChallengeCompleted,
    required this.isArabic,
    required this.onSelectContinent,
  });

  final QuizDifficulty selectedDifficulty;
  final bool isDailyChallengeCompleted;
  final bool isArabic;
  final ValueChanged<String> onSelectContinent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_esports,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isArabic ? 'أوضاع اللعب' : 'Game Modes',
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Game mode cards in a grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Daily Challenge
              _GameModeChip(
                icon: Icons.today,
                label: isArabic ? 'التحدي اليومي' : 'Daily',
                color: const Color(0xFFFF6D00),
                isCompleted: isDailyChallengeCompleted,
                onTap: isDailyChallengeCompleted
                    ? null
                    : () => _startDailyChallenge(context, ref),
              ),
              // Quick Quiz
              _GameModeChip(
                icon: Icons.bolt,
                label: isArabic ? 'سريع' : 'Quick',
                color: const Color(0xFF2196F3),
                subtitle: isArabic ? '5 أسئلة' : '5 Qs',
                onTap: () => _startQuickQuiz(context, ref),
              ),
              // Timed Blitz
              _GameModeChip(
                icon: Icons.timer,
                label: isArabic ? 'البرق' : 'Blitz',
                color: const Color(0xFFF44336),
                subtitle: isArabic ? '2× نقاط' : '2× XP',
                onTap: () => _startTimedBlitz(context, ref),
              ),
              // Continent Challenge
              _GameModeChip(
                icon: Icons.public,
                label: isArabic ? 'القارة' : 'Continent',
                color: const Color(0xFF4CAF50),
                onTap: () => _showContinentPicker(context, ref),
              ),
              // Marathon (Premium)
              _GameModeChip(
                icon: Icons.sports_score,
                label: isArabic ? 'ماراثون' : 'Marathon',
                color: const Color(0xFF9C27B0),
                subtitle: isArabic ? '50 سؤال' : '50 Qs',
                isPremium: !isPremium,
                onTap: () => _startMarathon(context, ref, isPremium),
              ),
              // Study Mode
              _GameModeChip(
                icon: Icons.school,
                label: isArabic ? 'دراسة' : 'Study',
                color: const Color(0xFF607D8B),
                subtitle: isArabic ? 'بدون نقاط' : 'No XP',
                onTap: () => _startStudyMode(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startDailyChallenge(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(quizStateProvider.notifier).startDailyChallenge();
    context.push('${Routes.quizGame}?sessionType=dailyChallenge');
  }

  void _startQuickQuiz(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(quizStateProvider.notifier).startQuickQuiz(
          difficulty: selectedDifficulty,
        );
    context.push('${Routes.quizGame}?sessionType=quickQuiz&difficulty=${selectedDifficulty.name}');
  }

  void _startTimedBlitz(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(quizStateProvider.notifier).startTimedBlitz(
          difficulty: selectedDifficulty,
        );
    context.push('${Routes.quizGame}?sessionType=timedBlitz&difficulty=${selectedDifficulty.name}');
  }

  void _startMarathon(BuildContext context, WidgetRef ref, bool isPremium) {
    HapticFeedback.mediumImpact();
    if (!isPremium) {
      context.push(Routes.paywall);
      return;
    }
    ref.read(quizStateProvider.notifier).startMarathon(
          difficulty: selectedDifficulty,
        );
    context.push('${Routes.quizGame}?sessionType=marathon&difficulty=${selectedDifficulty.name}');
  }

  void _startStudyMode(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(quizStateProvider.notifier).startStudyMode(
          mode: QuizMode.mixed,
        );
    context.push('${Routes.quizGame}?sessionType=studyMode');
  }

  void _showContinentPicker(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    final continents = [
      ('Africa', isArabic ? 'أفريقيا' : 'Africa'),
      ('Asia', isArabic ? 'آسيا' : 'Asia'),
      ('Europe', isArabic ? 'أوروبا' : 'Europe'),
      ('North America', isArabic ? 'أمريكا الشمالية' : 'North America'),
      ('South America', isArabic ? 'أمريكا الجنوبية' : 'South America'),
      ('Oceania', isArabic ? 'أوقيانوسيا' : 'Oceania'),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'اختر القارة' : 'Select Continent',
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...continents.map((continent) => ListTile(
                  leading: const Icon(Icons.public),
                  title: Text(continent.$2),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(quizStateProvider.notifier).startContinentChallenge(
                          continent: continent.$1,
                          difficulty: selectedDifficulty,
                        );
                    context.push(
                      '${Routes.quizGame}?sessionType=continentChallenge&continent=${continent.$1}&difficulty=${selectedDifficulty.name}',
                    );
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Game mode chip widget
class _GameModeChip extends StatelessWidget {
  const _GameModeChip({
    required this.icon,
    required this.label,
    required this.color,
    this.subtitle,
    this.isPremium = false,
    this.isCompleted = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String? subtitle;
  final bool isPremium;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.grey.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.grey : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : icon,
              color: isCompleted ? Colors.grey : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey : color,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.xpGold,
                      ),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isCompleted
                          ? Colors.grey
                          : color.withValues(alpha: 0.7),
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
