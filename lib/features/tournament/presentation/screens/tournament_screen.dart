import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/tournament.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';
import '../../../../presentation/providers/tournament_provider.dart';

/// Tournament screen with active tournament, leaderboard, and join functionality
class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock user ID for demo
  static const _userId = 'current_user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final activeTournament = ref.watch(activeTournamentProvider);
    final upcomingTournaments = ref.watch(upcomingTournamentsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _TournamentHeader(isArabic: isArabic),
          ),
          // Active tournament card
          SliverToBoxAdapter(
            child: activeTournament.when(
              data: (tournament) => tournament != null
                  ? _ActiveTournamentCard(
                      tournament: tournament,
                      isArabic: isArabic,
                      userId: _userId,
                    )
                  : _NoActiveTournament(l10n: l10n),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ),
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: [
                Tab(text: l10n.tournamentLeaderboard),
                Tab(text: l10n.tournamentUpcoming),
                Tab(text: l10n.tournamentRewards),
              ],
            ),
          ),
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Leaderboard
                activeTournament.when(
                  data: (tournament) => tournament != null
                      ? _LeaderboardTab(
                          tournamentId: tournament.id,
                          isArabic: isArabic,
                        )
                      : Center(child: Text(l10n.noActiveTournament)),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                // Upcoming tournaments
                upcomingTournaments.when(
                  data: (tournaments) => tournaments.isEmpty
                      ? Center(child: Text(l10n.noUpcomingTournaments))
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          itemCount: tournaments.length,
                          itemBuilder: (context, index) =>
                              _UpcomingTournamentCard(
                            tournament: tournaments[index],
                            isArabic: isArabic,
                            userId: _userId,
                          ).animate(delay: (index * 50).ms).fadeIn().slideY(
                                begin: 0.1,
                                end: 0,
                              ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                // Rewards
                activeTournament.when(
                  data: (tournament) => tournament != null
                      ? _RewardsTab(tournament: tournament, isArabic: isArabic)
                      : Center(child: Text(l10n.noActiveTournament)),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tournament header
class _TournamentHeader extends StatelessWidget {
  const _TournamentHeader({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.explorer,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: responsive.insets(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    l10n.tournamentsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                l10n.tournamentSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active tournament card
class _ActiveTournamentCard extends ConsumerWidget {
  const _ActiveTournamentCard({
    required this.tournament,
    required this.isArabic,
    required this.userId,
  });

  final Tournament tournament;
  final bool isArabic;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    final participationKey = TournamentParticipationKey(
      userId: userId,
      tournamentId: tournament.id,
    );
    final isParticipating = ref.watch(isUserParticipatingProvider(participationKey));
    final userRank = ref.watch(userTournamentRankProvider(participationKey));

    return Container(
      margin: responsive.insets(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tournament.type.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tournament.type.getName(isArabic),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  l10n.tournamentActive,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            tournament.getTitle(isArabic),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (tournament.getDescription(isArabic) != null) ...[
            const SizedBox(height: AppDimensions.xs),
            Text(
              tournament.getDescription(isArabic)!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _InfoChip(
                icon: Icons.people,
                label: '${tournament.participantCount} ${l10n.tournamentParticipants}',
              ),
              const SizedBox(width: AppDimensions.sm),
              _InfoChip(
                icon: Icons.timer,
                label: _formatTimeRemaining(tournament.timeRemaining, l10n),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          isParticipating.when(
            data: (participating) => participating
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: AppDimensions.xs),
                              Text(
                                l10n.tournamentJoined,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              userRank.when(
                                data: (rank) => rank != null
                                    ? Text(
                                        ' - ${l10n.rank}: #$rank',
                                        style:
                                            theme.textTheme.labelLarge?.copyWith(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref.read(tournamentActionsProvider.notifier).joinTournament(
                              userId,
                              tournament.id,
                            );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(l10n.tournamentJoinNow),
                    ),
                  ),
            loading: () => const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  String _formatTimeRemaining(Duration duration, AppLocalizations l10n) {
    if (duration.inDays > 0) {
      return '${duration.inDays}${l10n.daysShort} ${l10n.tournamentRemaining}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}${l10n.hoursShort} ${l10n.tournamentRemaining}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}${l10n.minutesShort} ${l10n.tournamentRemaining}';
    }
    return l10n.tournamentEnding;
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

/// No active tournament placeholder
class _NoActiveTournament extends StatelessWidget {
  const _NoActiveTournament({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: AppColors.textHintLight,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              l10n.noActiveTournament,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab bar delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<Tab> tabs;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: tabs,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

/// Leaderboard tab
class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({
    required this.tournamentId,
    required this.isArabic,
  });

  final String tournamentId;
  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final leaderboard = ref.watch(tournamentLeaderboardProvider(tournamentId));

    return leaderboard.when(
      data: (entries) => entries.isEmpty
          ? Center(child: Text(l10n.noLeaderboardData))
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isTopThree = index < 3;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                  color: isTopThree
                      ? _getRankColor(index).withValues(alpha: 0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isTopThree
                          ? _getRankColor(index)
                          : AppColors.primary.withValues(alpha: 0.1),
                      child: isTopThree
                          ? Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '${entry.rank}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(
                      entry.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.xpGold,
                        ),
                        const SizedBox(width: 4),
                        Text('${l10n.level} ${entry.level}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.totalXp} XP',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.xpGold,
                          ),
                        ),
                        Text(
                          '#${entry.rank}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (index * 30).ms).fadeIn().slideX(
                      begin: isArabic ? -0.1 : 0.1,
                      end: 0,
                    );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }
}

/// Upcoming tournament card
class _UpcomingTournamentCard extends ConsumerWidget {
  const _UpcomingTournamentCard({
    required this.tournament,
    required this.isArabic,
    required this.userId,
  });

  final Tournament tournament;
  final bool isArabic;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final participationKey = TournamentParticipationKey(
      userId: userId,
      tournamentId: tournament.id,
    );
    final isParticipating = ref.watch(isUserParticipatingProvider(participationKey));

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tournament.type.icon, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    tournament.getTitle(isArabic),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tournament.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    tournament.status.getName(isArabic),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tournament.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              tournament.getDescription(isArabic) ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  '${l10n.startsIn}: ${_formatTimeUntilStart(tournament.timeUntilStart)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            isParticipating.when(
              data: (participating) => participating
                  ? OutlinedButton.icon(
                      onPressed: () {
                        ref.read(tournamentActionsProvider.notifier).leaveTournament(
                              userId,
                              tournament.id,
                            );
                      },
                      icon: const Icon(Icons.check),
                      label: Text(l10n.tournamentRegistered),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        ref.read(tournamentActionsProvider.notifier).joinTournament(
                              userId,
                              tournament.id,
                            );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.tournamentRegister),
                    ),
              loading: () => const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeUntilStart(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    }
    return 'Soon';
  }
}

/// Rewards tab
class _RewardsTab extends StatelessWidget {
  const _RewardsTab({
    required this.tournament,
    required this.isArabic,
  });

  final Tournament tournament;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: tournament.rewards.length,
      itemBuilder: (context, index) {
        final reward = tournament.rewards[index];
        final isTopThree = index < 3;

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isTopThree
                  ? _getRankColor(index)
                  : AppColors.primary.withValues(alpha: 0.1),
              child: isTopThree
                  ? const Icon(Icons.emoji_events, color: Colors.white)
                  : Text(
                      '#${reward.minRank}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
            title: Text(
              reward.title ??
                  (reward.minRank == reward.maxRank
                      ? '${l10n.rank} #${reward.minRank}'
                      : '${l10n.rank} #${reward.minRank} - #${reward.maxRank}'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                '+${reward.xpBonus} XP',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.xpGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ).animate(delay: (index * 50).ms).fadeIn().slideX(
              begin: isArabic ? -0.1 : 0.1,
              end: 0,
            );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }
}
