import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/user.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/user_provider.dart';

/// Achievements screen displaying all achievements and user progress
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  final List<AchievementCategory?> _categories = [
    null, // All
    AchievementCategory.learning,
    AchievementCategory.quiz,
    AchievementCategory.streak,
    AchievementCategory.exploration,
    AchievementCategory.social,
    AchievementCategory.special,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final progress = ref.watch(userProgressProvider);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final expandedHeight = responsive.sp(180);
    final paddingLG = responsive.sp(AppDimensions.paddingLG);
    final spacingMD = responsive.sp(AppDimensions.spacingMD);

    final unlockedIds = progress.unlockedAchievements.toSet();
    const allAchievements = Achievements.all;

    // Filter by category
    final filteredAchievements = _selectedCategory == null
        ? allAchievements
        : allAchievements
            .where((a) => a.category == _selectedCategory)
            .toList();

    // Separate unlocked and locked
    final unlockedAchievements =
        filteredAchievements.where((a) => unlockedIds.contains(a.id)).toList();
    final lockedAchievements =
        filteredAchievements.where((a) => !unlockedIds.contains(a.id)).toList();

    // Calculate stats
    final totalUnlocked = allAchievements.where((a) => unlockedIds.contains(a.id)).length;
    final totalAchievements = allAchievements.length;
    final progressPercent = totalAchievements > 0
        ? (totalUnlocked / totalAchievements * 100).round()
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(paddingLG),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildStatCard(
                              context,
                              theme,
                              Icons.emoji_events,
                              '$totalUnlocked/$totalAchievements',
                              l10n.unlocked,
                            ),
                            SizedBox(width: spacingMD),
                            _buildStatCard(
                              context,
                              theme,
                              Icons.pie_chart,
                              '$progressPercent%',
                              l10n.progress,
                            ),
                            SizedBox(width: spacingMD),
                            _buildStatCard(
                              context,
                              theme,
                              Icons.star,
                              '${_calculateTotalXpEarned(unlockedIds)}',
                              l10n.xpLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.achievements,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Category Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: _categories.map((category) {
                  return Tab(
                    text: category == null
                        ? l10n.all
                        : isArabic
                            ? category.displayNameArabic
                            : category.displayName,
                  );
                }).toList(),
              ),
              theme.colorScheme.surface,
            ),
          ),

          // Unlocked Achievements Section
          if (unlockedAchievements.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: responsive.insetsOnly(
                  left: AppDimensions.paddingMD,
                  top: AppDimensions.paddingMD,
                  right: AppDimensions.paddingMD,
                  bottom: AppDimensions.paddingSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: responsive.sp(AppDimensions.iconSM),
                    ),
                    SizedBox(width: responsive.sp(AppDimensions.spacingSM)),
                    Text(
                      '${l10n.unlocked} (${unlockedAchievements.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: responsive.insetsSymmetric(
                horizontal: AppDimensions.paddingMD,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.gridColumns(context),
                  mainAxisSpacing: responsive.sp(AppDimensions.spacingMD),
                  crossAxisSpacing: responsive.sp(AppDimensions.spacingMD),
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = unlockedAchievements[index];
                    return _AchievementCard(
                      achievement: achievement,
                      isUnlocked: true,
                      isArabic: isArabic,
                      progress: progress,
                    );
                  },
                  childCount: unlockedAchievements.length,
                ),
              ),
            ),
          ],

          // Locked Achievements Section
          if (lockedAchievements.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: responsive.insetsOnly(
                  left: AppDimensions.paddingMD,
                  top: AppDimensions.paddingLG,
                  right: AppDimensions.paddingMD,
                  bottom: AppDimensions.paddingSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: responsive.sp(AppDimensions.iconSM),
                    ),
                    SizedBox(width: responsive.sp(AppDimensions.spacingSM)),
                    Text(
                      '${l10n.locked} (${lockedAchievements.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: responsive.insetsOnly(
                left: AppDimensions.paddingMD,
                right: AppDimensions.paddingMD,
                bottom: AppDimensions.paddingLG,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.gridColumns(context),
                  mainAxisSpacing: responsive.sp(AppDimensions.spacingMD),
                  crossAxisSpacing: responsive.sp(AppDimensions.spacingMD),
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = lockedAchievements[index];
                    return _AchievementCard(
                      achievement: achievement,
                      isUnlocked: false,
                      isArabic: isArabic,
                      progress: progress,
                    );
                  },
                  childCount: lockedAchievements.length,
                ),
              ),
            ),
          ],

          // Empty state
          if (filteredAchievements.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: responsive.sp(AppDimensions.iconXXL),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: spacingMD),
                    Text(
                      'No achievements in this category',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    final responsive = ResponsiveUtils.of(context);
    final paddingSM = responsive.sp(AppDimensions.paddingSM);
    final radiusMD = responsive.sp(AppDimensions.radiusMD);
    final iconMD = responsive.sp(AppDimensions.iconMD);
    final xxs = responsive.sp(AppDimensions.xxs);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(paddingSM),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: iconMD),
            SizedBox(height: xxs),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalXpEarned(Set<String> unlockedIds) {
    return Achievements.all
        .where((a) => unlockedIds.contains(a.id))
        .fold(0, (sum, a) => sum + a.xpReward);
  }
}

/// Tab bar delegate for persistent header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// Achievement card widget
class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.isArabic,
    required this.progress,
  });

  final Achievement achievement;
  final bool isUnlocked;
  final bool isArabic;
  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final radiusLG = responsive.sp(AppDimensions.radiusLG);
    final paddingMD = responsive.sp(AppDimensions.paddingMD);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final xxs = responsive.sp(AppDimensions.xxs);
    final xs = responsive.sp(AppDimensions.xs);
    final paddingSM = responsive.sp(AppDimensions.paddingSM);
    final radiusSM = responsive.sp(AppDimensions.radiusSM);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radiusLG),
        border: isUnlocked
            ? Border.all(color: _getTierColor(achievement.tier), width: 2)
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: _getTierColor(achievement.tier).withValues(alpha: 0.3),
                  blurRadius: xs,
                  offset: Offset(0, xxs),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(paddingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Achievement Icon
                _buildAchievementIcon(context, theme),
                SizedBox(height: spacingSM),

                // Title
                Text(
                  achievement.getDisplayName(isArabic: isArabic),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: xxs),

                // Description
                Text(
                  achievement.getDisplayDescription(isArabic: isArabic),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacingSM),

                // XP Reward or Progress
                if (isUnlocked)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingSM,
                      vertical: xxs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(achievement.tier).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(radiusSM),
                    ),
                    child: Text(
                      '+${achievement.xpReward} XP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTierColor(achievement.tier),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  _buildProgressIndicator(context, theme),
              ],
            ),
          ),

          // Tier Badge
          Positioned(
            top: xs,
            right: isArabic ? null : xs,
            left: isArabic ? xs : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.sp(AppDimensions.xs - 2), vertical: 2),
              decoration: BoxDecoration(
                color: _getTierColor(achievement.tier),
                borderRadius: BorderRadius.circular(radiusSM),
              ),
              child: Text(
                achievement.tier.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.sp(10),
                ),
              ),
            ),
          ),

          // Lock overlay
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(radiusLG),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(BuildContext context, ThemeData theme) {
    final responsive = ResponsiveUtils.of(context);
    final avatarSize = responsive.sp(AppDimensions.avatarLG - 8);
    final iconSize = responsive.sp(AppDimensions.iconLG - 4);

    final iconColor = isUnlocked
        ? _getTierColor(achievement.tier)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isUnlocked ? 0.2 : 0.1),
        shape: BoxShape.circle,
        border: isUnlocked
            ? Border.all(color: iconColor, width: 2)
            : null,
      ),
      child: Icon(
        _getCategoryIcon(achievement.category),
        color: iconColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ThemeData theme) {
    final responsive = ResponsiveUtils.of(context);
    final xxs = responsive.sp(AppDimensions.xxs);

    final currentValue = _getCurrentValue();
    final progressPercent = achievement.requiredValue > 0
        ? (currentValue / achievement.requiredValue).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progressPercent,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(_getTierColor(achievement.tier)),
          borderRadius: BorderRadius.circular(2),
        ),
        SizedBox(height: xxs),
        Text(
          '$currentValue / ${achievement.requiredValue}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  int _getCurrentValue() {
    // Map achievement category to user progress values
    switch (achievement.category) {
      case AchievementCategory.learning:
        return progress.countriesLearned;
      case AchievementCategory.quiz:
        return progress.quizzesCompleted;
      case AchievementCategory.streak:
        return progress.currentStreak;
      case AchievementCategory.exploration:
        // Check specific region progress based on achievement ID
        if (achievement.id.contains('africa')) {
          return progress.regionProgress['Africa'] ?? 0;
        } else if (achievement.id.contains('europe')) {
          return progress.regionProgress['Europe'] ?? 0;
        } else if (achievement.id.contains('asia')) {
          return progress.regionProgress['Asia'] ?? 0;
        }
        return progress.countriesLearned;
      case AchievementCategory.social:
        return 0; // Social features not yet implemented
      case AchievementCategory.special:
        return 0; // Special achievements have custom requirements
    }
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learning:
        return Icons.school;
      case AchievementCategory.quiz:
        return Icons.quiz;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.exploration:
        return Icons.explore;
      case AchievementCategory.social:
        return Icons.people;
      case AchievementCategory.special:
        return Icons.star;
    }
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }
}
