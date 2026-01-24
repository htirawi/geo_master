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

/// Quiz mode selection screen - Redesigned Professional Challenge Arena
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        cacheExtent: 500,
        slivers: [
          // Modern Compact Header
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _ModernHeader(
                isArabic: isArabic,
                streak: currentStreak,
              ),
            ),
          ),
          // Stats Cards
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _StatsCards(stats: quizStats)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),
            ),
          ),
          // Game Modes Grid
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _GameModesGrid(
                selectedDifficulty: selectedDifficulty,
                isDailyChallengeCompleted: isDailyChallengeCompleted.valueOrNull ?? false,
                isArabic: isArabic,
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            ),
          ),
          // Difficulty Selector
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _ModernDifficultySelector(
                selectedDifficulty: selectedDifficulty,
                onDifficultyChanged: (difficulty) {
                  HapticFeedback.selectionClick();
                  ref.read(_selectedDifficultyProvider.notifier).state = difficulty;
                },
                isArabic: isArabic,
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            ),
          ),
          // Topic Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? 'اختر نوع السؤال' : 'Choose Topic',
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
          ),
          // Topic Cards Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _TopicCard(
                  icon: Icons.location_city_rounded,
                  title: l10n.quizModeCapitals,
                  subtitle: '195 ${l10n.questions}',
                  gradient: AppColors.oceanGradient,
                  accentColor: const Color(0xFF1565C0),
                  onTap: () => _startQuiz(context, ref, QuizMode.capitals, selectedDifficulty),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.flag_rounded,
                  title: l10n.quizModeFlags,
                  subtitle: '195 ${l10n.questions}',
                  gradient: AppColors.sunsetGradient,
                  accentColor: const Color(0xFFFF6D00),
                  onTap: () => _startQuiz(context, ref, QuizMode.flags, selectedDifficulty),
                ).animate().fadeIn(delay: 550.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.public_rounded,
                  title: l10n.quizModeMap,
                  subtitle: '195 ${l10n.questions}',
                  gradient: AppColors.forestGradient,
                  accentColor: const Color(0xFF00897B),
                  isPremium: true,
                  onTap: () => _startQuiz(context, ref, QuizMode.maps, selectedDifficulty),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.people_rounded,
                  title: l10n.quizModePopulation,
                  subtitle: '100 ${l10n.questions}',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  accentColor: const Color(0xFFFF8F00),
                  onTap: () => _startQuiz(context, ref, QuizMode.population, selectedDifficulty),
                ).animate().fadeIn(delay: 650.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.attach_money_rounded,
                  title: l10n.quizModeCurrency,
                  subtitle: '150 ${l10n.questions}',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  accentColor: const Color(0xFF7E57C2),
                  onTap: () => _startQuiz(context, ref, QuizMode.currencies, selectedDifficulty),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.translate_rounded,
                  title: isArabic ? 'اللغات' : 'Languages',
                  subtitle: '150 ${l10n.questions}',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  accentColor: const Color(0xFF5C6BC0),
                  onTap: () => _startQuiz(context, ref, QuizMode.languages, selectedDifficulty),
                ).animate().fadeIn(delay: 750.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.share_location_rounded,
                  title: isArabic ? 'الحدود' : 'Borders',
                  subtitle: '150 ${l10n.questions}',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  accentColor: const Color(0xFF26A69A),
                  onTap: () => _startQuiz(context, ref, QuizMode.borders, selectedDifficulty),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                _TopicCard(
                  icon: Icons.shuffle_rounded,
                  title: isArabic ? 'مختلط' : 'Mixed',
                  subtitle: '195 ${l10n.questions}',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF546E7A), Color(0xFF607D8B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  accentColor: const Color(0xFF546E7A),
                  onTap: () => _startQuiz(context, ref, QuizMode.mixed, selectedDifficulty),
                ).animate().fadeIn(delay: 850.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

/// Modern Compact Header
class _ModernHeader extends StatelessWidget {
  const _ModernHeader({
    required this.isArabic,
    required this.streak,
  });

  final bool isArabic;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6D00), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6D00).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.challengeArena,
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.selectChallenge,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Streak badge
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streak',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}

/// Modern Stats Cards
class _StatsCards extends StatelessWidget {
  const _StatsCards({required this.stats});

  final AsyncValue<QuizStatistics> stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return stats.when(
      data: (statistics) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_rounded,
                value: '${statistics.totalQuizzes}',
                label: l10n.quizzesCompleted,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.gps_fixed_rounded,
                value: '${statistics.averageAccuracy.toStringAsFixed(0)}%',
                label: l10n.accuracy,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${statistics.bestStreak}',
                label: l10n.bestStreak,
                color: AppColors.streak,
              ),
            ),
          ],
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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

/// Game Modes Grid
class _GameModesGrid extends ConsumerWidget {
  const _GameModesGrid({
    required this.selectedDifficulty,
    required this.isDailyChallengeCompleted,
    required this.isArabic,
  });

  final QuizDifficulty selectedDifficulty;
  final bool isDailyChallengeCompleted;
  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_esports_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'أوضاع اللعب' : 'Game Modes',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Game modes in clean grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _GameModeCard(
                icon: Icons.today_rounded,
                label: isArabic ? 'البرق' : 'Quick',
                subtitle: isArabic ? '5 أسئلة' : '5 Qs',
                color: const Color(0xFF2196F3),
                onTap: () => _startQuickQuiz(context, ref),
              ),
              _GameModeCard(
                icon: Icons.timer_rounded,
                label: isArabic ? 'سريع' : 'Blitz',
                subtitle: isArabic ? '2× نقاط' : '2× XP',
                color: const Color(0xFFF44336),
                onTap: () => _startTimedBlitz(context, ref),
              ),
              _GameModeCard(
                icon: Icons.public_rounded,
                label: isArabic ? 'القارة' : 'Region',
                subtitle: '',
                color: const Color(0xFF4CAF50),
                onTap: () => _showContinentPicker(context, ref),
              ),
              _GameModeCard(
                icon: Icons.calendar_today_rounded,
                label: isArabic ? 'التحدي اليومي' : 'Daily',
                subtitle: '',
                color: const Color(0xFFFF6D00),
                isCompleted: isDailyChallengeCompleted,
                onTap: isDailyChallengeCompleted
                    ? null
                    : () => _startDailyChallenge(context, ref),
              ),
              _GameModeCard(
                icon: Icons.sports_score_rounded,
                label: isArabic ? 'ماراثون' : 'Marathon',
                subtitle: isArabic ? '50 سؤال' : '50 Qs',
                color: const Color(0xFF9C27B0),
                isPremium: !isPremium,
                onTap: () => _startMarathon(context, ref, isPremium),
              ),
              _GameModeCard(
                icon: Icons.school_rounded,
                label: isArabic ? 'دراسة' : 'Study',
                subtitle: '',
                color: const Color(0xFF607D8B),
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

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.isPremium = false,
    this.isCompleted = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isPremium;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.grey.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? Colors.grey.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.grey.withValues(alpha: 0.2)
                          : color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : icon,
                      color: isCompleted ? Colors.grey : color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Colors.grey
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: isCompleted
                              ? Colors.grey
                              : color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPremium)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.xpGold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Modern Difficulty Selector
class _ModernDifficultySelector extends StatelessWidget {
  const _ModernDifficultySelector({
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.difficultyLevel,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DifficultyOption(
                  title: l10n.difficultyEasy,
                  icon: Icons.spa_rounded,
                  color: AppColors.difficultyEasy,
                  isSelected: selectedDifficulty == QuizDifficulty.easy,
                  onTap: () => onDifficultyChanged(QuizDifficulty.easy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DifficultyOption(
                  title: l10n.difficultyMedium,
                  icon: Icons.hiking_rounded,
                  color: AppColors.difficultyMedium,
                  isSelected: selectedDifficulty == QuizDifficulty.medium,
                  onTap: () => onDifficultyChanged(QuizDifficulty.medium),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DifficultyOption(
                  title: l10n.difficultyHard,
                  icon: Icons.terrain_rounded,
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

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Topic Card
class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    this.isPremium = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color accentColor;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
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
                borderRadius: BorderRadius.circular(22),
                child: CustomPaint(
                  painter: _TopicCardPatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Premium badge
            if (isPremium)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Topic Card Pattern Painter
class _TopicCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Draw subtle dots pattern
    const dotSize = 2.0;
    const spacing = 16.0;
    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
