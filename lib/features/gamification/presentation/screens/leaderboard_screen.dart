import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/repositories/i_user_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/user_provider.dart';

/// Leaderboard screen displaying global rankings
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardType _currentType = LeaderboardType.global;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentType = [
          LeaderboardType.global,
          LeaderboardType.weekly,
          LeaderboardType.friends,
        ][_tabController.index];
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
    final leaderboardAsync = ref.watch(leaderboardProvider(_currentType));
    final userRankAsync = ref.watch(userRankProvider);
    final currentUser = ref.watch(userDataProvider);
    final userProgress = ref.watch(userProgressProvider);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final expandedHeight = responsive.sp(200);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: responsive.insets(AppDimensions.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Current user rank card
                        userRankAsync.when(
                          data: (rank) => _buildCurrentUserCard(
                            context,
                            theme,
                            l10n,
                            rank,
                            currentUser?.displayName ?? l10n.guest,
                            currentUser?.photoUrl,
                            userProgress.totalXp,
                            userProgress.level,
                          ),
                          loading: () => _buildCurrentUserCardLoading(context, theme),
                          error: (_, __) => _buildCurrentUserCard(
                            context,
                            theme,
                            l10n,
                            0,
                            currentUser?.displayName ?? l10n.guest,
                            currentUser?.photoUrl,
                            userProgress.totalXp,
                            userProgress.level,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.leaderboard,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: [
                  Tab(text: l10n.global),
                  Tab(text: l10n.weekly),
                  Tab(text: l10n.friends),
                ],
              ),
              theme.colorScheme.surface,
            ),
          ),

          // Leaderboard List
          leaderboardAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, theme, l10n),
                );
              }

              return SliverPadding(
                padding: responsive.insets(AppDimensions.paddingMD),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = entries[index];
                      final isCurrentUser = entry.oduserId == currentUser?.id;

                      return _LeaderboardEntryCard(
                        entry: entry,
                        isCurrentUser: isCurrentUser,
                        isTopThree: index < 3,
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: responsive.sp(AppDimensions.avatarMD),
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(height: responsive.sp(AppDimensions.spacingMD)),
                    Text(
                      l10n.error,
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: responsive.sp(AppDimensions.spacingSM)),
                    TextButton(
                      onPressed: () => ref.refresh(leaderboardProvider(_currentType)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    int rank,
    String displayName,
    String? photoUrl,
    int totalXp,
    int level,
  ) {
    final responsive = ResponsiveUtils.of(context);
    final paddingMD = responsive.sp(AppDimensions.paddingMD);
    final spacingMD = responsive.sp(AppDimensions.spacingMD);
    final avatarMD = responsive.sp(AppDimensions.avatarMD);
    final avatarRadius = responsive.sp(AppDimensions.lg);
    final radiusLG = responsive.sp(AppDimensions.radiusLG);
    final radiusMD = responsive.sp(AppDimensions.radiusMD);
    final paddingSM = responsive.sp(AppDimensions.sm);
    final paddingXS = responsive.sp(AppDimensions.xs - 2);

    return Container(
      padding: EdgeInsets.all(paddingMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radiusLG),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: avatarMD,
            height: avatarMD,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank > 0 ? '#$rank' : '-',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: spacingMD),

          // Avatar
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            backgroundImage: photoUrl != null
                ? CachedNetworkImageProvider(photoUrl)
                : null,
            child: photoUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          SizedBox(width: spacingMD),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${l10n.levelNumber(level)} • $totalXp ${l10n.xpLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Your Rank label
          Container(
            padding: EdgeInsets.symmetric(horizontal: paddingSM, vertical: paddingXS),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radiusMD),
            ),
            child: Text(
              l10n.yourRank,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCardLoading(BuildContext context, ThemeData theme) {
    final responsive = ResponsiveUtils.of(context);
    final paddingMD = responsive.sp(AppDimensions.paddingMD);
    final radiusLG = responsive.sp(AppDimensions.radiusLG);

    return Container(
      padding: EdgeInsets.all(paddingMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final responsive = ResponsiveUtils.of(context);
    final iconSize = responsive.sp(AppDimensions.iconXXL);
    final spacingMD = responsive.sp(AppDimensions.spacingMD);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: spacingMD),
          Text(
            'No rankings yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacingSM),
          Text(
            'Be the first to earn XP and climb the ranks!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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

/// Leaderboard entry card
class _LeaderboardEntryCard extends StatelessWidget {
  const _LeaderboardEntryCard({
    required this.entry,
    required this.isCurrentUser,
    required this.isTopThree,
  });

  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final bool isTopThree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final radiusMD = responsive.sp(AppDimensions.radiusMD);
    final radiusSM = responsive.sp(AppDimensions.radiusSM);
    final avatarSM = responsive.sp(AppDimensions.avatarSM);
    final avatarRadius = responsive.sp(AppDimensions.lg - 4);
    final paddingSM = responsive.sp(AppDimensions.sm);
    final paddingXS = responsive.sp(AppDimensions.xs - 2);

    return Container(
      margin: EdgeInsets.only(bottom: spacingSM),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radiusMD),
        border: isCurrentUser
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank
            SizedBox(
              width: avatarSM,
              child: isTopThree
                  ? _buildMedalIcon(context, entry.rank)
                  : Text(
                      '#${entry.rank}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            SizedBox(width: spacingSM),

            // Avatar
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: entry.photoUrl != null
                  ? CachedNetworkImageProvider(entry.photoUrl!)
                  : null,
              child: entry.photoUrl == null
                  ? Text(
                      entry.displayName.isNotEmpty
                          ? entry.displayName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        title: Text(
          entry.displayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${l10n.levelNumber(entry.level)} • ${entry.countriesLearned} ${l10n.countriesLabel}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: paddingSM, vertical: paddingXS),
          decoration: BoxDecoration(
            color: isTopThree
                ? _getMedalColor(entry.rank).withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          child: Text(
            '${entry.totalXp} XP',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isTopThree
                  ? _getMedalColor(entry.rank)
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedalIcon(BuildContext context, int rank) {
    final responsive = ResponsiveUtils.of(context);
    final iconSize = responsive.sp(AppDimensions.iconLG - 4);

    IconData icon;
    Color color;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = const Color(0xFFFFD700); // Gold
        break;
      case 2:
        icon = Icons.emoji_events;
        color = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        icon = Icons.emoji_events;
        color = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: iconSize);
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}
