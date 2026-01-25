import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository.dart';
import '../../domain/entities/duel.dart';
import '../../domain/entities/friend.dart';

/// Provider for the friends repository
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return LocalFriendsRepository();
});

/// Provider for user's friends list
final friendsListProvider =
    FutureProvider.family<List<Friend>, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getFriends(userId);
});

/// Provider for watching friends list stream
final friendsStreamProvider =
    StreamProvider.family<List<Friend>, String>((ref, userId) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.watchFriends(userId);
});

/// Provider for pending friend requests
final pendingRequestsProvider =
    FutureProvider.family<List<FriendRequest>, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getPendingRequests(userId);
});

/// Provider for watching pending requests stream
final pendingRequestsStreamProvider =
    StreamProvider.family<List<FriendRequest>, String>((ref, userId) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.watchPendingRequests(userId);
});

/// Provider for user's friend code
final userFriendCodeProvider =
    FutureProvider.family<String, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getUserFriendCode(userId);
});

/// Provider for social stats
final socialStatsProvider =
    FutureProvider.family<SocialStats, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getSocialStats(userId);
});

/// Provider for active duels
final activeDuelsProvider =
    FutureProvider.family<List<Duel>, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getActiveDuels(userId);
});

/// Provider for watching active duels stream
final activeDuelsStreamProvider =
    StreamProvider.family<List<Duel>, String>((ref, userId) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.watchActiveDuels(userId);
});

/// Provider for duel history
final duelHistoryProvider =
    FutureProvider.family<List<Duel>, String>((ref, userId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getDuelHistory(userId);
});

/// State notifier for managing friends
class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  FriendsNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    _loadFriends();
  }

  final FriendsRepository _repository;
  final String _userId;

  Future<void> _loadFriends() async {
    state = const AsyncValue.loading();
    try {
      final friends = await _repository.getFriends(_userId);
      state = AsyncValue.data(friends);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadFriends();

  Future<bool> sendFriendRequest(String friendCode) async {
    try {
      await _repository.sendFriendRequest(_userId, friendCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _repository.acceptFriendRequest(requestId);
      await _loadFriends();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await _repository.declineFriendRequest(requestId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _repository.removeFriend(_userId, friendId);

      // Optimistic update
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.where((f) => f.userId != friendId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _loadFriends();
    }
  }

  Future<void> blockUser(String blockUserId) async {
    try {
      await _repository.blockUser(_userId, blockUserId);
      await _loadFriends();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for friends state notifier
final friendsNotifierProvider = StateNotifierProvider.family<FriendsNotifier,
    AsyncValue<List<Friend>>, String>(
  (ref, userId) {
    final repository = ref.read(friendsRepositoryProvider);
    return FriendsNotifier(repository, userId);
  },
);

/// State notifier for managing duels
class DuelsNotifier extends StateNotifier<AsyncValue<List<Duel>>> {
  DuelsNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    _loadDuels();
  }

  final FriendsRepository _repository;
  final String _userId;

  Future<void> _loadDuels() async {
    state = const AsyncValue.loading();
    try {
      final duels = await _repository.getActiveDuels(_userId);
      state = AsyncValue.data(duels);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadDuels();

  Future<Duel?> challengeFriend(String friendId, DuelConfig config) async {
    try {
      final duel = await _repository.createDuel(_userId, friendId, config);
      await _loadDuels();
      return duel;
    } catch (e) {
      return null;
    }
  }

  Future<bool> acceptDuel(String duelId) async {
    try {
      await _repository.acceptDuel(duelId, _userId);
      await _loadDuels();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> declineDuel(String duelId) async {
    try {
      await _repository.declineDuel(duelId, _userId);
      await _loadDuels();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitResult(String duelId, DuelPlayerResult result) async {
    try {
      await _repository.submitDuelResult(duelId, _userId, result);
      await _loadDuels();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for duels state notifier
final duelsNotifierProvider =
    StateNotifierProvider.family<DuelsNotifier, AsyncValue<List<Duel>>, String>(
  (ref, userId) {
    final repository = ref.read(friendsRepositoryProvider);
    return DuelsNotifier(repository, userId);
  },
);

/// Provider for finding a user by friend code
final findUserByCodeProvider =
    FutureProvider.family<Friend?, String>((ref, friendCode) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.findUserByFriendCode(friendCode);
});

/// Provider for a specific duel
final duelProvider =
    FutureProvider.family<Duel?, String>((ref, duelId) async {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getDuel(duelId);
});

/// Provider for online friends count
final onlineFriendsCountProvider =
    Provider.family<int, AsyncValue<List<Friend>>>((ref, friendsAsync) {
  return friendsAsync.when(
    data: (friends) => friends.where((f) => f.isOnline).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for friends sorted by activity
final sortedFriendsProvider =
    Provider.family<List<Friend>, List<Friend>>((ref, friends) {
  final sorted = List<Friend>.from(friends);
  sorted.sort((a, b) {
    // Online first
    if (a.isOnline != b.isOnline) {
      return a.isOnline ? -1 : 1;
    }
    // Then by recent activity
    if (a.lastActive != null && b.lastActive != null) {
      return b.lastActive!.compareTo(a.lastActive!);
    }
    // Then by XP
    return b.totalXp.compareTo(a.totalXp);
  });
  return sorted;
});

/// Extension for friend list operations
extension FriendListExtension on List<Friend> {
  /// Get online friends
  List<Friend> get online => where((f) => f.isOnline).toList();

  /// Get recently active friends
  List<Friend> get recentlyActive => where((f) => f.isRecentlyActive).toList();

  /// Search friends by name
  List<Friend> searchByName(String query) {
    final lowercaseQuery = query.toLowerCase();
    return where((f) => f.displayName.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get friends sorted by level
  List<Friend> get byLevel {
    final sorted = List<Friend>.from(this);
    sorted.sort((a, b) => b.level.compareTo(a.level));
    return sorted;
  }

  /// Get friends sorted by XP
  List<Friend> get byXp {
    final sorted = List<Friend>.from(this);
    sorted.sort((a, b) => b.totalXp.compareTo(a.totalXp));
    return sorted;
  }

  /// Get friends sorted by streak
  List<Friend> get byStreak {
    final sorted = List<Friend>.from(this);
    sorted.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return sorted;
  }
}

/// Extension for duel list operations
extension DuelListExtension on List<Duel> {
  /// Get pending duels (challenges received)
  List<Duel> pendingFor(String userId) =>
      where((d) => d.status == DuelStatus.pending && d.opponentId == userId)
          .toList();

  /// Get sent challenges (waiting for response)
  List<Duel> sentBy(String userId) =>
      where((d) => d.status == DuelStatus.pending && d.challengerId == userId)
          .toList();

  /// Get in-progress duels
  List<Duel> get inProgress =>
      where((d) => d.status == DuelStatus.inProgress).toList();

  /// Get completed duels
  List<Duel> get completed =>
      where((d) => d.status == DuelStatus.completed).toList();

  /// Get duels won by user
  List<Duel> wonBy(String userId) =>
      where((d) => d.status == DuelStatus.completed && d.winnerId == userId)
          .toList();

  /// Get duels lost by user
  List<Duel> lostBy(String userId) =>
      where((d) =>
          d.status == DuelStatus.completed &&
          d.winnerId != null &&
          d.winnerId != userId)
          .toList();
}
