import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/friend.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';
import '../../../../presentation/providers/friends_provider.dart';

/// Friends screen with friend list, requests, and add friend functionality
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _friendCodeController = TextEditingController();

  // Mock user ID for demo
  static const _userId = 'current_user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendCodeController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addFriendTitle),
        content: TextField(
          controller: _friendCodeController,
          decoration: InputDecoration(
            hintText: l10n.addFriendHint,
            prefixIcon: const Icon(Icons.person_add),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (_friendCodeController.text.isNotEmpty) {
                ref.read(friendsNotifierProvider(_userId).notifier).sendFriendRequest(
                      _friendCodeController.text.trim(),
                    );
                _friendCodeController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.friendRequestSent)),
                );
              }
            },
            child: Text(l10n.sendFriendRequest),
          ),
        ],
      ),
    );
  }

  void _copyFriendCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.friendCodeCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final responsive = ResponsiveUtils.of(context);

    final friendsAsync = ref.watch(friendsListProvider(_userId));
    final requestsAsync = ref.watch(pendingRequestsProvider(_userId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _FriendsHeader(
              isArabic: isArabic,
              onCopyCode: _copyFriendCode,
            ),
          ),
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: [
                Tab(text: l10n.friendsTitle),
                Tab(text: l10n.friendRequestsTitle),
              ],
            ),
          ),
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Friends list
                friendsAsync.when(
                  data: (friends) => friends.isEmpty
                      ? _EmptyFriendsState(l10n: l10n)
                      : ListView.builder(
                          padding: responsive.insets(AppDimensions.md),
                          itemCount: friends.length,
                          itemBuilder: (context, index) => _FriendCard(
                            friend: friends[index],
                            onChallenge: () => _showChallengeDialog(friends[index]),
                          ).animate(delay: (index * 50).ms).fadeIn().slideX(
                                begin: isArabic ? -0.1 : 0.1,
                                end: 0,
                              ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                // Friend requests
                requestsAsync.when(
                  data: (requests) => requests.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noFriendsYet,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: responsive.insets(AppDimensions.md),
                          itemCount: requests.length,
                          itemBuilder: (context, index) => _FriendRequestCard(
                            request: requests[index],
                            onAccept: () {
                              ref.read(friendsNotifierProvider(_userId).notifier)
                                  .acceptRequest(requests[index].id);
                            },
                            onDecline: () {
                              ref.read(friendsNotifierProvider(_userId).notifier)
                                  .declineRequest(requests[index].id);
                            },
                          ).animate(delay: (index * 50).ms).fadeIn(),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriendDialog,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addFriendTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showChallengeDialog(Friend friend) {
    // TODO: Navigate to duel configuration screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Challenge ${friend.displayName}!')),
    );
  }
}

/// Friends header with friend code
class _FriendsHeader extends ConsumerWidget {
  const _FriendsHeader({
    required this.isArabic,
    required this.onCopyCode,
  });

  final bool isArabic;
  final void Function(String) onCopyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.of(context);

    // Generate a mock friend code
    const friendCode = 'GEO-ABCD-1234';

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
              // Back button and title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    l10n.friendsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              // Friend code card
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code, color: Colors.white, size: 32),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.friendCodeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            friendCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onCopyCode(friendCode),
                      icon: const Icon(Icons.copy, color: Colors.white),
                      tooltip: l10n.friendCodeCopied,
                    ),
                  ],
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

/// Tab bar delegate for pinned tabs
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

/// Friend card widget
class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.friend,
    required this.onChallenge,
  });

  final Friend friend;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage:
              friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
          child: friend.avatarUrl == null
              ? Text(
                  friend.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          friend.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: AppColors.xpGold,
            ),
            const SizedBox(width: 4),
            Text('Level ${friend.level}'),
            const SizedBox(width: AppDimensions.sm),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: friend.isOnline ? AppColors.success : AppColors.textHintLight,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              friend.isOnline ? l10n.friendOnline : l10n.friendOffline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        trailing: FilledButton.tonal(
          onPressed: onChallenge,
          child: Text(l10n.challengeFriend),
        ),
      ),
    );
  }
}

/// Friend request card widget
class _FriendRequestCard extends StatelessWidget {
  const _FriendRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              backgroundImage: request.fromUserAvatar != null
                  ? NetworkImage(request.fromUserAvatar!)
                  : null,
              child: request.fromUserAvatar == null
                  ? Text(
                      request.fromUserName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.fromUserName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatTimeAgo(request.sentAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onDecline,
              child: Text(l10n.declineFriendRequest),
            ),
            const SizedBox(width: AppDimensions.xs),
            FilledButton(
              onPressed: onAccept,
              child: Text(l10n.acceptFriendRequest),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

/// Empty friends state
class _EmptyFriendsState extends StatelessWidget {
  const _EmptyFriendsState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            l10n.noFriendsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Add friends using their friend code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHintLight,
                ),
          ),
        ],
      ),
    );
  }
}
