import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/country.dart';
import '../../../../domain/entities/country_progress.dart';
import '../../../../presentation/providers/country_progress_provider.dart';
import '../../../../presentation/providers/media_provider.dart';

/// Learn tab showing progress, quiz, modules, AI, and timeline
class LearnTab extends ConsumerWidget {
  const LearnTab({
    super.key,
    required this.country,
  });

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final progressAsync = ref.watch(progressForCountryProvider(country.code));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress card
          progressAsync.when(
            data: (progress) => _ProgressCard(
              progress: progress,
              isArabic: isArabic,
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Quick quiz card
          _QuizCard(countryCode: country.code, isArabic: isArabic),
          const SizedBox(height: 16),

          // Learning modules
          _LearningModulesSection(
            countryCode: country.code,
            isArabic: isArabic,
          ),
          const SizedBox(height: 16),

          // AI Tutor launcher
          _AiTutorCard(country: country, isArabic: isArabic),
          const SizedBox(height: 16),

          // Flashcards section
          _FlashcardsSection(countryCode: country.code, isArabic: isArabic),
          const SizedBox(height: 16),

          // Media gallery
          _MediaGallerySection(
            countryName: country.name,
            isArabic: isArabic,
          ),
          const SizedBox(height: 16),

          // Bookmarks section
          progressAsync.when(
            data: (progress) => progress.bookmarkedFacts.isNotEmpty
                ? _BookmarksSection(
                    bookmarks: progress.bookmarkedFacts,
                    isArabic: isArabic,
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Progress visualization card
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.isArabic,
  });

  final CountryProgress progress;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = progress.completionPercentage.toInt();
    final progressValue = progress.completionPercentage / 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'تقدمك' : 'Your Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(progressValue),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    progress.progressLevel.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  _getProgressColor(progressValue),
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(progressValue),
                  ),
                ),
                Text(
                  isArabic ? 'مكتمل' : 'Complete',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Stats grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.star,
                  value: '${progress.xpEarned}',
                  label: 'XP',
                  color: Colors.amber,
                ),
                _StatItem(
                  icon: Icons.quiz,
                  value: '${progress.quizzesPassed}/${progress.quizzesTaken}',
                  label: isArabic ? 'اختبارات' : 'Quizzes',
                  color: const Color(0xFF4CAF50),
                ),
                _StatItem(
                  icon: Icons.style,
                  value: '${progress.flashcardsMastered}',
                  label: isArabic ? 'بطاقات' : 'Cards',
                  color: const Color(0xFF2196F3),
                ),
                _StatItem(
                  icon: Icons.timer,
                  value: _formatTime(progress.timeSpentSeconds),
                  label: isArabic ? 'الوقت' : 'Time',
                  color: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF4CAF50);
    if (progress >= 0.5) return const Color(0xFFFFC107);
    if (progress > 0) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).round()}m';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Quick quiz card
class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.countryCode,
    required this.isArabic,
  });

  final String countryCode;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/quiz', arguments: {
            'countryCode': countryCode,
            'questionCount': 3,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'اختبار سريع' : 'Quick Quiz',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      isArabic
                          ? '3 أسئلة لاختبار معلوماتك'
                          : '3 questions to test your knowledge',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Learning modules section
class _LearningModulesSection extends StatelessWidget {
  const _LearningModulesSection({
    required this.countryCode,
    required this.isArabic,
  });

  final String countryCode;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final modules = [
      _ModuleData(
        id: 'basics',
        icon: Icons.school,
        title: isArabic ? 'الأساسيات' : 'Basics',
        description: isArabic
            ? 'حقائق أساسية عن الدولة'
            : 'Basic facts about the country',
        isLocked: false,
      ),
      _ModuleData(
        id: 'geography',
        icon: Icons.terrain,
        title: isArabic ? 'الجغرافيا' : 'Geography',
        description: isArabic
            ? 'تعلم عن التضاريس والمناخ'
            : 'Learn about terrain and climate',
        isLocked: false,
      ),
      _ModuleData(
        id: 'culture',
        icon: Icons.theater_comedy,
        title: isArabic ? 'الثقافة' : 'Culture',
        description: isArabic
            ? 'اكتشف التقاليد والعادات'
            : 'Discover traditions and customs',
        isLocked: true,
      ),
      _ModuleData(
        id: 'history',
        icon: Icons.history_edu,
        title: isArabic ? 'التاريخ' : 'History',
        description: isArabic
            ? 'تعرف على تاريخ الدولة'
            : 'Learn about the country\'s history',
        isLocked: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.library_books,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'وحدات التعلم' : 'Learning Modules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...modules.map((module) => _ModuleCard(module: module)),
      ],
    );
  }
}

class _ModuleData {
  const _ModuleData({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.isLocked,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
  final bool isLocked;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _ModuleData module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: module.isLocked
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          child: Icon(
            module.icon,
            color: module.isLocked
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          module.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: module.isLocked
                ? theme.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: Text(
          module.description,
          style: TextStyle(
            color: module.isLocked
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                : null,
          ),
        ),
        trailing: module.isLocked
            ? const Icon(Icons.lock, color: Colors.amber)
            : const Icon(Icons.chevron_right),
        onTap: module.isLocked
            ? null
            : () {
                // Navigate to module
              },
      ),
    );
  }
}

/// AI Tutor launcher card
class _AiTutorCard extends StatelessWidget {
  const _AiTutorCard({
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFF1A237E),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/ai-tutor',
            arguments: {'country': country},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'مساعد الذكاء الاصطناعي' : 'AI Tutor',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isArabic
                          ? 'اسأل أي شيء عن ${country.getDisplayName(isArabic: true)}'
                          : 'Ask anything about ${country.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flashcards section
class _FlashcardsSection extends StatelessWidget {
  const _FlashcardsSection({
    required this.countryCode,
    required this.isArabic,
  });

  final String countryCode;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to flashcards
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.style,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'بطاقات تعليمية' : 'Flashcards',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isArabic
                          ? 'راجع الحقائق المهمة'
                          : 'Review key facts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Media gallery section
class _MediaGallerySection extends ConsumerWidget {
  const _MediaGallerySection({
    required this.countryName,
    required this.isArabic,
  });

  final String countryName;
  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final photosAsync = ref.watch(countryPhotosProvider(countryName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'معرض الصور' : 'Photo Gallery',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        photosAsync.when(
          data: (photos) => photos.isNotEmpty
              ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        child: CachedNetworkImage(
                          imageUrl: photo.urls.thumb,
                          width: 160,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 160,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.photo),
                          ),
                          placeholder: (_, __) => Container(
                            width: 160,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('No photos available'),
                    ),
                  ),
                ),
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Bookmarks section
class _BookmarksSection extends StatelessWidget {
  const _BookmarksSection({
    required this.bookmarks,
    required this.isArabic,
  });

  final List<String> bookmarks;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'المحفوظات' : 'Bookmarks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bookmarks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...bookmarks.take(3).map((bookmark) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_border, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookmark,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
            if (bookmarks.length > 3)
              TextButton(
                onPressed: () {
                  // View all bookmarks
                },
                child: Text(
                  isArabic
                      ? 'عرض الكل (${bookmarks.length})'
                      : 'View all (${bookmarks.length})',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
