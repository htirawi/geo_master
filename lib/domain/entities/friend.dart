import 'package:flutter/material.dart';

/// Friend status in the social system
enum FriendStatus {
  /// Request sent, awaiting response
  pending,

  /// Active friendship
  accepted,

  /// User blocked
  blocked;

  String getNameEn() {
    switch (this) {
      case FriendStatus.pending:
        return 'Pending';
      case FriendStatus.accepted:
        return 'Friend';
      case FriendStatus.blocked:
        return 'Blocked';
    }
  }

  String getNameAr() {
    switch (this) {
      case FriendStatus.pending:
        return 'قيد الانتظار';
      case FriendStatus.accepted:
        return 'صديق';
      case FriendStatus.blocked:
        return 'محظور';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();
}

/// Friend entity
@immutable
class Friend {
  const Friend({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.status,
    this.friendSince,
    this.lastActive,
    this.friendCode,
  });

  /// Unique user ID
  final String userId;

  /// Display name
  final String displayName;

  /// Avatar URL (optional)
  final String? avatarUrl;

  /// Current level
  final int level;

  /// Total XP earned
  final int totalXp;

  /// Current study streak
  final int currentStreak;

  /// Friendship status
  final FriendStatus status;

  /// When the friendship was established
  final DateTime? friendSince;

  /// Last active timestamp
  final DateTime? lastActive;

  /// User's friend code for sharing
  final String? friendCode;

  /// Check if user is online (active within last 5 minutes)
  bool get isOnline {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inMinutes < 5;
  }

  /// Check if user was recently active (within last hour)
  bool get isRecentlyActive {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inHours < 1;
  }

  /// Get initials for avatar fallback
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.substring(0, displayName.length.clamp(0, 2)).toUpperCase();
  }

  Friend copyWith({
    String? newUserId,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? totalXp,
    int? currentStreak,
    FriendStatus? status,
    DateTime? friendSince,
    DateTime? lastActive,
    String? friendCode,
  }) {
    return Friend(
      userId: newUserId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      status: status ?? this.status,
      friendSince: friendSince ?? this.friendSince,
      lastActive: lastActive ?? this.lastActive,
      friendCode: friendCode ?? this.friendCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'status': status.name,
      'friendSince': friendSince?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'friendCode': friendCode,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      level: json['level'] as int? ?? 1,
      totalXp: json['totalXp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      friendSince: json['friendSince'] != null
          ? DateTime.parse(json['friendSince'] as String)
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      friendCode: json['friendCode'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// Friend request entity
@immutable
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserAvatar,
    required this.fromUserLevel,
    required this.toUserId,
    required this.sentAt,
    this.message,
  });

  /// Request ID
  final String id;

  /// Sender user ID
  final String fromUserId;

  /// Sender display name
  final String fromUserName;

  /// Sender avatar URL
  final String? fromUserAvatar;

  /// Sender's level
  final int fromUserLevel;

  /// Recipient user ID
  final String toUserId;

  /// When the request was sent
  final DateTime sentAt;

  /// Optional message with the request
  final String? message;

  /// Check if request is recent (within last 24 hours)
  bool get isRecent {
    return DateTime.now().difference(sentAt).inHours < 24;
  }

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserAvatar,
    int? fromUserLevel,
    String? toUserId,
    DateTime? sentAt,
    String? message,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      fromUserLevel: fromUserLevel ?? this.fromUserLevel,
      toUserId: toUserId ?? this.toUserId,
      sentAt: sentAt ?? this.sentAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'fromUserLevel': fromUserLevel,
      'toUserId': toUserId,
      'sentAt': sentAt.toIso8601String(),
      'message': message,
    };
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserAvatar: json['fromUserAvatar'] as String?,
      fromUserLevel: json['fromUserLevel'] as int? ?? 1,
      toUserId: json['toUserId'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      message: json['message'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User's social stats
@immutable
class SocialStats {
  const SocialStats({
    required this.friendsCount,
    required this.pendingRequestsCount,
    required this.duelsWon,
    required this.duelsLost,
    required this.duelWinStreak,
    required this.globalRank,
    required this.friendsRank,
  });

  final int friendsCount;
  final int pendingRequestsCount;
  final int duelsWon;
  final int duelsLost;
  final int duelWinStreak;
  final int globalRank;
  final int friendsRank;

  /// Duel win rate percentage
  double get duelWinRate {
    final total = duelsWon + duelsLost;
    if (total == 0) return 0.0;
    return duelsWon / total;
  }

  /// Total duels played
  int get totalDuels => duelsWon + duelsLost;

  SocialStats copyWith({
    int? friendsCount,
    int? pendingRequestsCount,
    int? duelsWon,
    int? duelsLost,
    int? duelWinStreak,
    int? globalRank,
    int? friendsRank,
  }) {
    return SocialStats(
      friendsCount: friendsCount ?? this.friendsCount,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
      duelsWon: duelsWon ?? this.duelsWon,
      duelsLost: duelsLost ?? this.duelsLost,
      duelWinStreak: duelWinStreak ?? this.duelWinStreak,
      globalRank: globalRank ?? this.globalRank,
      friendsRank: friendsRank ?? this.friendsRank,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendsCount': friendsCount,
      'pendingRequestsCount': pendingRequestsCount,
      'duelsWon': duelsWon,
      'duelsLost': duelsLost,
      'duelWinStreak': duelWinStreak,
      'globalRank': globalRank,
      'friendsRank': friendsRank,
    };
  }

  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      friendsCount: json['friendsCount'] as int? ?? 0,
      pendingRequestsCount: json['pendingRequestsCount'] as int? ?? 0,
      duelsWon: json['duelsWon'] as int? ?? 0,
      duelsLost: json['duelsLost'] as int? ?? 0,
      duelWinStreak: json['duelWinStreak'] as int? ?? 0,
      globalRank: json['globalRank'] as int? ?? 0,
      friendsRank: json['friendsRank'] as int? ?? 0,
    );
  }

  factory SocialStats.initial() {
    return const SocialStats(
      friendsCount: 0,
      pendingRequestsCount: 0,
      duelsWon: 0,
      duelsLost: 0,
      duelWinStreak: 0,
      globalRank: 0,
      friendsRank: 0,
    );
  }
}

/// Friend code generator utility
class FriendCodeGenerator {
  FriendCodeGenerator._();

  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Generate a new friend code (e.g., "GEO-ABC123")
  static String generate() {
    final buffer = StringBuffer('GEO-');
    final random = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < 6; i++) {
      final index = (random + i * 37) % _chars.length;
      buffer.write(_chars[index]);
    }

    return buffer.toString();
  }

  /// Validate friend code format
  static bool isValid(String code) {
    final pattern = RegExp(r'^GEO-[A-Z2-9]{6}$');
    return pattern.hasMatch(code.toUpperCase());
  }

  /// Normalize friend code (uppercase, remove extra spaces)
  static String normalize(String code) {
    return code.trim().toUpperCase().replaceAll(' ', '');
  }
}
