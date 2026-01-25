import '../../domain/entities/duel.dart';
import '../../domain/entities/friend.dart';

/// Repository interface for friends and social features
abstract class FriendsRepository {
  // Friend management
  Future<List<Friend>> getFriends(String userId);
  Future<Friend?> getFriend(String userId, String friendId);
  Future<void> sendFriendRequest(String userId, String friendCode);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> declineFriendRequest(String requestId);
  Future<void> removeFriend(String userId, String friendId);
  Future<void> blockUser(String userId, String blockUserId);
  Future<void> unblockUser(String userId, String blockedUserId);

  // Friend requests
  Future<List<FriendRequest>> getPendingRequests(String userId);
  Future<List<FriendRequest>> getSentRequests(String userId);

  // Friend code
  Future<String> getUserFriendCode(String userId);
  Future<Friend?> findUserByFriendCode(String friendCode);

  // Social stats
  Future<SocialStats> getSocialStats(String userId);

  // Duels
  Future<Duel> createDuel(
    String challengerId,
    String opponentId,
    DuelConfig config,
  );
  Future<void> acceptDuel(String duelId, String userId);
  Future<void> declineDuel(String duelId, String userId);
  Future<void> submitDuelResult(
    String duelId,
    String userId,
    DuelPlayerResult result,
  );
  Future<List<Duel>> getActiveDuels(String userId);
  Future<List<Duel>> getDuelHistory(String userId, {int limit = 20});
  Future<Duel?> getDuel(String duelId);

  // Streams
  Stream<List<Friend>> watchFriends(String userId);
  Stream<List<FriendRequest>> watchPendingRequests(String userId);
  Stream<List<Duel>> watchActiveDuels(String userId);
}

/// Local implementation of friends repository
class LocalFriendsRepository implements FriendsRepository {
  LocalFriendsRepository();

  // In-memory storage
  final Map<String, List<Friend>> _friendsCache = {};
  final Map<String, List<FriendRequest>> _requestsCache = {};
  final Map<String, List<FriendRequest>> _sentRequestsCache = {};
  final Map<String, String> _friendCodesCache = {};
  final Map<String, Duel> _duelsCache = {};
  final Map<String, SocialStats> _statsCache = {};

  @override
  Future<List<Friend>> getFriends(String userId) async {
    return _friendsCache[userId] ?? [];
  }

  @override
  Future<Friend?> getFriend(String userId, String friendId) async {
    final friends = _friendsCache[userId] ?? [];
    try {
      return friends.firstWhere((f) => f.userId == friendId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> sendFriendRequest(String userId, String friendCode) async {
    final targetUser = await findUserByFriendCode(friendCode);
    if (targetUser == null) {
      throw Exception('User not found with that friend code');
    }

    final request = FriendRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: userId,
      fromUserName: 'You', // Would come from user data
      fromUserLevel: 1,
      toUserId: targetUser.userId,
      sentAt: DateTime.now(),
    );

    // Add to sent requests
    _sentRequestsCache.putIfAbsent(userId, () => []);
    _sentRequestsCache[userId]!.add(request);

    // Add to target's pending requests
    _requestsCache.putIfAbsent(targetUser.userId, () => []);
    _requestsCache[targetUser.userId]!.add(request);
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    // Find the request
    FriendRequest? request;
    String? targetUserId;

    for (final entry in _requestsCache.entries) {
      final match = entry.value.where((r) => r.id == requestId);
      if (match.isNotEmpty) {
        request = match.first;
        targetUserId = entry.key;
        break;
      }
    }

    if (request == null || targetUserId == null) {
      throw Exception('Request not found');
    }

    // Create friend entries for both users
    final newFriend = Friend(
      userId: request.fromUserId,
      displayName: request.fromUserName,
      avatarUrl: request.fromUserAvatar,
      level: request.fromUserLevel,
      totalXp: 0,
      currentStreak: 0,
      status: FriendStatus.accepted,
      friendSince: DateTime.now(),
    );

    _friendsCache.putIfAbsent(targetUserId, () => []);
    _friendsCache[targetUserId]!.add(newFriend);

    // Remove from pending requests
    _requestsCache[targetUserId]?.removeWhere((r) => r.id == requestId);

    // Update stats
    _updateFriendCount(targetUserId);
    _updateFriendCount(request.fromUserId);
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    for (final entry in _requestsCache.entries) {
      entry.value.removeWhere((r) => r.id == requestId);
    }
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    _friendsCache[userId]?.removeWhere((f) => f.userId == friendId);
    _friendsCache[friendId]?.removeWhere((f) => f.userId == userId);

    _updateFriendCount(userId);
    _updateFriendCount(friendId);
  }

  @override
  Future<void> blockUser(String userId, String blockUserId) async {
    // Remove from friends if exists
    await removeFriend(userId, blockUserId);

    // Add to blocked list (would be in a separate collection)
    // For now, just remove the friend relationship
  }

  @override
  Future<void> unblockUser(String userId, String blockedUserId) async {
    // Remove from blocked list
    // Implementation would depend on block storage
  }

  @override
  Future<List<FriendRequest>> getPendingRequests(String userId) async {
    return _requestsCache[userId] ?? [];
  }

  @override
  Future<List<FriendRequest>> getSentRequests(String userId) async {
    return _sentRequestsCache[userId] ?? [];
  }

  @override
  Future<String> getUserFriendCode(String userId) async {
    if (!_friendCodesCache.containsKey(userId)) {
      _friendCodesCache[userId] = FriendCodeGenerator.generate();
    }
    return _friendCodesCache[userId]!;
  }

  @override
  Future<Friend?> findUserByFriendCode(String friendCode) async {
    final normalizedCode = FriendCodeGenerator.normalize(friendCode);

    for (final entry in _friendCodesCache.entries) {
      if (entry.value == normalizedCode) {
        return Friend(
          userId: entry.key,
          displayName: 'User ${entry.key.substring(0, 4)}',
          level: 1,
          totalXp: 0,
          currentStreak: 0,
          status: FriendStatus.pending,
          friendCode: entry.value,
        );
      }
    }

    // For demo, create a mock user if code is valid format
    if (FriendCodeGenerator.isValid(friendCode)) {
      return Friend(
        userId: 'user_$normalizedCode',
        displayName: 'Explorer',
        level: 5,
        totalXp: 1500,
        currentStreak: 3,
        status: FriendStatus.pending,
        friendCode: normalizedCode,
      );
    }

    return null;
  }

  @override
  Future<SocialStats> getSocialStats(String userId) async {
    return _statsCache[userId] ?? SocialStats.initial();
  }

  @override
  Future<Duel> createDuel(
    String challengerId,
    String opponentId,
    DuelConfig config,
  ) async {
    final duel = Duel(
      id: 'duel_${DateTime.now().millisecondsSinceEpoch}',
      challengerId: challengerId,
      challengerName: 'Challenger',
      opponentId: opponentId,
      opponentName: 'Opponent',
      config: config,
      status: DuelStatus.pending,
      createdAt: DateTime.now(),
    );

    _duelsCache[duel.id] = duel;
    return duel;
  }

  @override
  Future<void> acceptDuel(String duelId, String userId) async {
    final duel = _duelsCache[duelId];
    if (duel == null) throw Exception('Duel not found');

    _duelsCache[duelId] = duel.copyWith(
      status: DuelStatus.inProgress,
      startedAt: DateTime.now(),
    );
  }

  @override
  Future<void> declineDuel(String duelId, String userId) async {
    final duel = _duelsCache[duelId];
    if (duel == null) throw Exception('Duel not found');

    _duelsCache[duelId] = duel.copyWith(
      status: DuelStatus.declined,
    );
  }

  @override
  Future<void> submitDuelResult(
    String duelId,
    String userId,
    DuelPlayerResult result,
  ) async {
    final duel = _duelsCache[duelId];
    if (duel == null) throw Exception('Duel not found');

    Duel updatedDuel;

    if (userId == duel.challengerId) {
      updatedDuel = duel.copyWith(challengerResult: result);
    } else {
      updatedDuel = duel.copyWith(opponentResult: result);
    }

    // Check if both results are in
    if (updatedDuel.challengerResult != null &&
        updatedDuel.opponentResult != null) {
      // Determine winner
      final challengerScore = updatedDuel.challengerResult!.score;
      final opponentScore = updatedDuel.opponentResult!.score;

      String? winnerId;
      if (challengerScore > opponentScore) {
        winnerId = duel.challengerId;
      } else if (opponentScore > challengerScore) {
        winnerId = duel.opponentId;
      }
      // null means draw

      final scoreDiff = (challengerScore - opponentScore).abs();
      final xpReward = calculateDuelXpReward(
        duel.config,
        winnerId != null,
        scoreDiff,
      );

      updatedDuel = updatedDuel.copyWith(
        status: DuelStatus.completed,
        completedAt: DateTime.now(),
        winnerId: winnerId,
        xpReward: xpReward,
      );

      // Update stats for both users
      if (winnerId != null) {
        _updateDuelStats(winnerId, true);
        final loserId =
            winnerId == duel.challengerId ? duel.opponentId : duel.challengerId;
        _updateDuelStats(loserId, false);
      }
    }

    _duelsCache[duelId] = updatedDuel;
  }

  @override
  Future<List<Duel>> getActiveDuels(String userId) async {
    return _duelsCache.values
        .where((d) =>
            (d.challengerId == userId || d.opponentId == userId) && d.isActive)
        .toList();
  }

  @override
  Future<List<Duel>> getDuelHistory(String userId, {int limit = 20}) async {
    final duels = _duelsCache.values
        .where((d) =>
            (d.challengerId == userId || d.opponentId == userId) &&
            d.status == DuelStatus.completed)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    return duels.take(limit).toList();
  }

  @override
  Future<Duel?> getDuel(String duelId) async {
    return _duelsCache[duelId];
  }

  @override
  Stream<List<Friend>> watchFriends(String userId) async* {
    yield await getFriends(userId);
  }

  @override
  Stream<List<FriendRequest>> watchPendingRequests(String userId) async* {
    yield await getPendingRequests(userId);
  }

  @override
  Stream<List<Duel>> watchActiveDuels(String userId) async* {
    yield await getActiveDuels(userId);
  }

  // Helper methods

  void _updateFriendCount(String userId) {
    final stats = _statsCache[userId] ?? SocialStats.initial();
    final friendCount = _friendsCache[userId]?.length ?? 0;
    _statsCache[userId] = stats.copyWith(friendsCount: friendCount);
  }

  void _updateDuelStats(String userId, bool won) {
    final stats = _statsCache[userId] ?? SocialStats.initial();
    _statsCache[userId] = stats.copyWith(
      duelsWon: won ? stats.duelsWon + 1 : stats.duelsWon,
      duelsLost: won ? stats.duelsLost : stats.duelsLost + 1,
      duelWinStreak: won ? stats.duelWinStreak + 1 : 0,
    );
  }
}
