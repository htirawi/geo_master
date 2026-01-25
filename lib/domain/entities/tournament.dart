import 'package:flutter/material.dart';

/// Tournament status
enum TournamentStatus {
  /// Registration open, hasn't started
  upcoming,

  /// Currently active
  active,

  /// Finished, results available
  completed,

  /// Tournament cancelled
  cancelled;

  String getNameEn() {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Upcoming';
      case TournamentStatus.active:
        return 'Active';
      case TournamentStatus.completed:
        return 'Completed';
      case TournamentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String getNameAr() {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'قادم';
      case TournamentStatus.active:
        return 'نشط';
      case TournamentStatus.completed:
        return 'مكتمل';
      case TournamentStatus.cancelled:
        return 'ملغى';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();

  Color get color {
    switch (this) {
      case TournamentStatus.upcoming:
        return const Color(0xFF2196F3);
      case TournamentStatus.active:
        return const Color(0xFF4CAF50);
      case TournamentStatus.completed:
        return const Color(0xFF9E9E9E);
      case TournamentStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }
}

/// Tournament type
enum TournamentType {
  /// Daily mini-tournament
  daily,

  /// Weekly competition
  weekly,

  /// Monthly championship
  monthly,

  /// Special event tournament
  special;

  String getNameEn() {
    switch (this) {
      case TournamentType.daily:
        return 'Daily';
      case TournamentType.weekly:
        return 'Weekly';
      case TournamentType.monthly:
        return 'Monthly';
      case TournamentType.special:
        return 'Special Event';
    }
  }

  String getNameAr() {
    switch (this) {
      case TournamentType.daily:
        return 'يومي';
      case TournamentType.weekly:
        return 'أسبوعي';
      case TournamentType.monthly:
        return 'شهري';
      case TournamentType.special:
        return 'حدث خاص';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();

  IconData get icon {
    switch (this) {
      case TournamentType.daily:
        return Icons.today;
      case TournamentType.weekly:
        return Icons.view_week;
      case TournamentType.monthly:
        return Icons.calendar_month;
      case TournamentType.special:
        return Icons.star;
    }
  }
}

/// Tournament reward tier
@immutable
class TournamentReward {
  const TournamentReward({
    required this.minRank,
    required this.maxRank,
    required this.xpBonus,
    this.badgeId,
    this.title,
  });

  factory TournamentReward.fromJson(Map<String, dynamic> json) {
    return TournamentReward(
      minRank: json['minRank'] as int,
      maxRank: json['maxRank'] as int,
      xpBonus: json['xpBonus'] as int,
      badgeId: json['badgeId'] as String?,
      title: json['title'] as String?,
    );
  }

  /// Minimum rank to qualify (inclusive)
  final int minRank;

  /// Maximum rank to qualify (inclusive)
  final int maxRank;

  /// XP bonus for this rank range
  final int xpBonus;

  /// Optional badge ID to award
  final String? badgeId;

  /// Optional title (e.g., "Champion", "Runner-up")
  final String? title;

  /// Check if a rank qualifies for this reward
  bool qualifiesForRank(int rank) => rank >= minRank && rank <= maxRank;

  Map<String, dynamic> toJson() {
    return {
      'minRank': minRank,
      'maxRank': maxRank,
      'xpBonus': xpBonus,
      'badgeId': badgeId,
      'title': title,
    };
  }

  /// Standard reward tiers
  static const List<TournamentReward> standardRewards = [
    TournamentReward(minRank: 1, maxRank: 1, xpBonus: 500, title: 'Champion'),
    TournamentReward(minRank: 2, maxRank: 2, xpBonus: 300, title: 'Runner-up'),
    TournamentReward(minRank: 3, maxRank: 3, xpBonus: 200, title: 'Third Place'),
    TournamentReward(minRank: 4, maxRank: 10, xpBonus: 100),
    TournamentReward(minRank: 11, maxRank: 50, xpBonus: 50),
    TournamentReward(minRank: 51, maxRank: 100, xpBonus: 25),
  ];
}

/// Tournament participant entry
@immutable
class TournamentParticipant {
  const TournamentParticipant({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.rank,
    required this.joinedAt,
    this.lastUpdated,
    this.level = 1,
    this.quizzesCompleted = 0,
    this.perfectScores = 0,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      level: json['level'] as int? ?? 1,
      quizzesCompleted: json['quizzesCompleted'] as int? ?? 0,
      perfectScores: json['perfectScores'] as int? ?? 0,
    );
  }

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int rank;
  final DateTime joinedAt;
  final DateTime? lastUpdated;
  final int level;
  final int quizzesCompleted;
  final int perfectScores;

  TournamentParticipant copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    int? score,
    int? rank,
    DateTime? joinedAt,
    DateTime? lastUpdated,
    int? level,
    int? quizzesCompleted,
    int? perfectScores,
  }) {
    return TournamentParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      joinedAt: joinedAt ?? this.joinedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      level: level ?? this.level,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      perfectScores: perfectScores ?? this.perfectScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'score': score,
      'rank': rank,
      'joinedAt': joinedAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'level': level,
      'quizzesCompleted': quizzesCompleted,
      'perfectScores': perfectScores,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentParticipant && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// Tournament entity
@immutable
class Tournament {
  const Tournament({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.rewards,
    this.participantCount = 0,
    this.maxParticipants,
    this.requiredLevel = 1,
    this.entryFee = 0,
    this.prizePool = 0,
    this.continent,
    this.quizType,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      type: TournamentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TournamentType.weekly,
      ),
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TournamentStatus.upcoming,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      rewards: (json['rewards'] as List?)
              ?.map((r) => TournamentReward.fromJson(r as Map<String, dynamic>))
              .toList() ??
          TournamentReward.standardRewards,
      participantCount: json['participantCount'] as int? ?? 0,
      maxParticipants: json['maxParticipants'] as int?,
      requiredLevel: json['requiredLevel'] as int? ?? 1,
      entryFee: json['entryFee'] as int? ?? 0,
      prizePool: json['prizePool'] as int? ?? 0,
      continent: json['continent'] as String?,
      quizType: json['quizType'] as String?,
    );
  }

  /// Unique tournament ID
  final String id;

  /// English title
  final String titleEn;

  /// Arabic title
  final String titleAr;

  /// English description
  final String? descriptionEn;

  /// Arabic description
  final String? descriptionAr;

  /// Tournament type
  final TournamentType type;

  /// Current status
  final TournamentStatus status;

  /// Start date/time
  final DateTime startDate;

  /// End date/time
  final DateTime endDate;

  /// Reward tiers
  final List<TournamentReward> rewards;

  /// Number of current participants
  final int participantCount;

  /// Maximum participants (null = unlimited)
  final int? maxParticipants;

  /// Minimum level required to join
  final int requiredLevel;

  /// Entry fee in XP (0 = free)
  final int entryFee;

  /// Total prize pool in XP
  final int prizePool;

  /// Optional continent filter
  final String? continent;

  /// Optional quiz type filter
  final String? quizType;

  /// Get localized title
  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  /// Get localized description
  String? getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;

  /// Check if tournament is currently active
  bool get isActive => status == TournamentStatus.active;

  /// Check if registration is open
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return status == TournamentStatus.upcoming && now.isBefore(startDate);
  }

  /// Check if tournament has started
  bool get hasStarted => DateTime.now().isAfter(startDate);

  /// Check if tournament has ended
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Check if tournament is full
  bool get isFull =>
      maxParticipants != null && participantCount >= maxParticipants!;

  /// Duration of the tournament
  Duration get duration => endDate.difference(startDate);

  /// Time remaining until tournament ends
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }

  /// Time until tournament starts
  Duration get timeUntilStart {
    final now = DateTime.now();
    if (now.isAfter(startDate)) return Duration.zero;
    return startDate.difference(now);
  }

  /// Get reward for a specific rank
  TournamentReward? getRewardForRank(int rank) {
    for (final reward in rewards) {
      if (reward.qualifiesForRank(rank)) {
        return reward;
      }
    }
    return null;
  }

  Tournament copyWith({
    String? id,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    TournamentType? type,
    TournamentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<TournamentReward>? rewards,
    int? participantCount,
    int? maxParticipants,
    int? requiredLevel,
    int? entryFee,
    int? prizePool,
    String? continent,
    String? quizType,
  }) {
    return Tournament(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rewards: rewards ?? this.rewards,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      continent: continent ?? this.continent,
      quizType: quizType ?? this.quizType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'type': type.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rewards': rewards.map((r) => r.toJson()).toList(),
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'requiredLevel': requiredLevel,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'continent': continent,
      'quizType': quizType,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tournament && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Generator for tournaments
class TournamentGenerator {
  TournamentGenerator._();

  /// Generate a weekly tournament
  static Tournament generateWeeklyTournament({
    required DateTime weekStart,
    String? continent,
  }) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    return Tournament(
      id: 'weekly_${weekStart.millisecondsSinceEpoch}',
      titleEn: continent != null
          ? '$continent Championship'
          : 'Weekly Championship',
      titleAr: continent != null ? 'بطولة $continent' : 'البطولة الأسبوعية',
      descriptionEn: 'Compete with explorers from around the world!',
      descriptionAr: 'تنافس مع المستكشفين من جميع أنحاء العالم!',
      type: TournamentType.weekly,
      status: TournamentStatus.upcoming,
      startDate: weekStart,
      endDate: weekEnd,
      rewards: TournamentReward.standardRewards,
      continent: continent,
    );
  }

  /// Generate a monthly tournament
  static Tournament generateMonthlyTournament({
    required int year,
    required int month,
  }) {
    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1).subtract(const Duration(days: 1));

    final monthName = _getMonthName(month);

    return Tournament(
      id: 'monthly_${year}_$month',
      titleEn: '$monthName Championship',
      titleAr: 'بطولة $monthName',
      descriptionEn: 'The ultimate monthly geography challenge!',
      descriptionAr: 'تحدي الجغرافيا الشهري النهائي!',
      type: TournamentType.monthly,
      status: TournamentStatus.upcoming,
      startDate: monthStart,
      endDate: monthEnd,
      rewards: const [
        TournamentReward(
          minRank: 1,
          maxRank: 1,
          xpBonus: 2000,
          title: 'Grand Champion',
          badgeId: 'monthly_champion',
        ),
        TournamentReward(minRank: 2, maxRank: 2, xpBonus: 1000, title: 'First Runner-up'),
        TournamentReward(minRank: 3, maxRank: 3, xpBonus: 500, title: 'Second Runner-up'),
        TournamentReward(minRank: 4, maxRank: 10, xpBonus: 250),
        TournamentReward(minRank: 11, maxRank: 50, xpBonus: 100),
        TournamentReward(minRank: 51, maxRank: 100, xpBonus: 50),
      ],
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
