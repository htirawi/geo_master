import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/entities/country_progress.dart';
import '../../../../presentation/providers/country_progress_provider.dart';
import '../utils/map_style.dart';

/// Popup shown when tapping on a country marker
class CountryInfoPopup extends ConsumerWidget {
  const CountryInfoPopup({
    super.key,
    required this.country,
    this.onTap,
    this.onClose,
  });

  final Country country;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final progressAsync = ref.watch(progressForCountryProvider(country.code));

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: AppDimensions.lg - 4,
              offset: const Offset(0, AppDimensions.xs),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with flag
            _buildHeader(context, theme, isArabic),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats
                  _buildQuickStats(context, theme, isArabic),
                  const SizedBox(height: AppDimensions.sm),

                  // Progress indicator
                  progressAsync.when(
                    data: (progress) => _buildProgressSection(
                      context,
                      theme,
                      progress,
                      isArabic,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.explore, size: AppDimensions.iconSM - 2),
                      label: Text(isArabic ? 'استكشف' : 'Explore'),
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

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isArabic) {
    return Stack(
      children: [
        // Flag background
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
          child: SizedBox(
            height: AppDimensions.flagWidthLG / AppDimensions.flagAspectRatio,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: country.flagUrl,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withValues(alpha: 0.2),
              errorWidget: (_, __, ___) => Container(
                color: theme.colorScheme.primaryContainer,
              ),
            ),
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),

        // Close button
        Positioned(
          top: AppDimensions.xs,
          right: AppDimensions.xs,
          child: IconButton.filled(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: AppDimensions.iconSM - 2),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(AppDimensions.xxs),
              minimumSize: const Size(28, 28),
            ),
          ),
        ),

        // Country name
        Positioned(
          bottom: AppDimensions.sm,
          left: AppDimensions.sm,
          right: AppDimensions.sm,
          child: Text(
            country.getDisplayName(isArabic: isArabic),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: AppDimensions.xxs,
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
  ) {
    return Row(
      children: [
        // Capital
        if (country.capital != null) ...[
          Icon(
            Icons.location_city,
            size: AppDimensions.iconXS - 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.xxs),
          Expanded(
            child: Text(
              country.getDisplayCapital(isArabic: isArabic) ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        // Continent
        if (country.continents.isNotEmpty) ...[
          const SizedBox(width: AppDimensions.sm),
          Icon(
            Icons.public,
            size: AppDimensions.iconXS - 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.xxs),
          Text(
            country.getDisplayContinents(isArabic: isArabic).first,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    ThemeData theme,
    CountryProgress progress,
    bool isArabic,
  ) {
    final progressValue = progress.completionPercentage / 100;
    final progressColor = Color(ProgressColors.getColorForProgress(progressValue));
    final progressLabel = ProgressColors.getColorName(progressValue, isArabic: isArabic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'التقدم' : 'Progress',
              style: theme.textTheme.labelMedium,
            ),
            Row(
              children: [
                Container(
                  width: AppDimensions.xs,
                  height: AppDimensions.xs,
                  decoration: BoxDecoration(
                    color: progressColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.xxs),
                Text(
                  progressLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(progressColor),
            minHeight: AppDimensions.xxs + 2,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatChip(
              icon: Icons.quiz,
              value: '${progress.quizzesPassed}',
              label: isArabic ? 'اختبارات' : 'Quizzes',
            ),
            _StatChip(
              icon: Icons.star,
              value: '${progress.xpEarned}',
              label: 'XP',
            ),
            if (progress.isFavorite)
              const Icon(
                Icons.favorite,
                size: AppDimensions.iconSM - 2,
                color: Color(ProgressColors.favorite),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXS - 2,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppDimensions.xxs),
        Text(
          '$value $label',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// Bottom sheet version for mobile
class CountryInfoBottomSheet extends ConsumerWidget {
  const CountryInfoBottomSheet({
    super.key,
    required this.country,
    this.onExplore,
  });

  final Country country;
  final VoidCallback? onExplore;

  static Future<void> show(
    BuildContext context, {
    required Country country,
    VoidCallback? onExplore,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountryInfoBottomSheet(
        country: country,
        onExplore: onExplore,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final progressAsync = ref.watch(progressForCountryProvider(country.code));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg - 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: AppDimensions.avatarSM + 8,
                height: AppDimensions.xxs,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS - 2),
                ),
              ),
              const SizedBox(height: AppDimensions.lg - 4),

              // Country header
              Row(
                children: [
                  // Flag
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    child: SizedBox(
                      width: AppDimensions.flagWidthMD,
                      height: AppDimensions.flagWidthMD / AppDimensions.flagAspectRatio,
                      child: CachedNetworkImage(
                        imageUrl: country.flagUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.primaryContainer,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.flag,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),

                  // Name and capital
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.getDisplayName(isArabic: isArabic),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (country.capital != null)
                          Text(
                            country.getDisplayCapital(isArabic: isArabic) ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress
              progressAsync.when(
                data: (progress) => _buildProgressCard(
                  context,
                  theme,
                  progress,
                  isArabic,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              // Explore button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onExplore?.call();
                  },
                  icon: const Icon(Icons.explore),
                  label: Text(isArabic ? 'استكشف هذه الدولة' : 'Explore This Country'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    ThemeData theme,
    CountryProgress progress,
    bool isArabic,
  ) {
    final progressValue = progress.completionPercentage / 100;
    final progressColor = Color(ProgressColors.getColorForProgress(progressValue));

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تقدمك' : 'Your Progress',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '${(progressValue * 100).toInt()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: AppDimensions.xs,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomSheetStat(
                icon: Icons.quiz,
                value: '${progress.quizzesPassed}/${progress.quizzesTaken}',
                label: isArabic ? 'اختبارات' : 'Quizzes',
              ),
              _BottomSheetStat(
                icon: Icons.star,
                value: '${progress.xpEarned}',
                label: 'XP',
              ),
              _BottomSheetStat(
                icon: Icons.style,
                value: '${progress.flashcardsMastered}',
                label: isArabic ? 'بطاقات' : 'Cards',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSheetStat extends StatelessWidget {
  const _BottomSheetStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconMD,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppDimensions.xxs),
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
