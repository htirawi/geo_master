import 'package:flutter/material.dart';

/// Duel status
enum DuelStatus {
  /// Challenge sent, waiting for opponent
  pending,

  /// Both players accepted, game in progress
  inProgress,

  /// Duel completed with results
  completed,

  /// Challenge expired (not accepted in time)
  expired,

  /// Opponent declined the challenge
  declined;

  String getNameEn() {
    switch (this) {
      case DuelStatus.pending:
        return 'Pending';
      case DuelStatus.inProgress:
        return 'In Progress';
      case DuelStatus.completed:
        return 'Completed';
      case DuelStatus.expired:
        return 'Expired';
      case DuelStatus.declined:
        return 'Declined';
    }
  }

  String getNameAr() {
    switch (this) {
      case DuelStatus.pending:
        return 'قيد الانتظار';
      case DuelStatus.inProgress:
        return 'جاري';
      case DuelStatus.completed:
        return 'مكتمل';
      case DuelStatus.expired:
        return 'منتهي الصلاحية';
      case DuelStatus.declined:
        return 'مرفوض';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();

  Color get color {
    switch (this) {
      case DuelStatus.pending:
        return const Color(0xFFFF9800);
      case DuelStatus.inProgress:
        return const Color(0xFF2196F3);
      case DuelStatus.completed:
        return const Color(0xFF4CAF50);
      case DuelStatus.expired:
        return const Color(0xFF9E9E9E);
      case DuelStatus.declined:
        return const Color(0xFFF44336);
    }
  }
}

/// Duel quiz configuration
@immutable
class DuelConfig {
  const DuelConfig({
    this.questionCount = 10,
    this.timePerQuestion = 15,
    this.continent,
    this.quizType = DuelQuizType.mixed,
    this.difficulty = DuelDifficulty.medium,
  });

  factory DuelConfig.fromJson(Map<String, dynamic> json) {
    return DuelConfig(
      questionCount: json['questionCount'] as int? ?? 10,
      timePerQuestion: json['timePerQuestion'] as int? ?? 15,
      continent: json['continent'] as String?,
      quizType: DuelQuizType.values.firstWhere(
        (e) => e.name == json['quizType'],
        orElse: () => DuelQuizType.mixed,
      ),
      difficulty: DuelDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DuelDifficulty.medium,
      ),
    );
  }

  /// Number of questions in the duel
  final int questionCount;

  /// Seconds allowed per question
  final int timePerQuestion;

  /// Optional continent filter
  final String? continent;

  /// Type of quiz questions
  final DuelQuizType quizType;

  /// Difficulty level
  final DuelDifficulty difficulty;

  /// Total time for the duel in seconds
  int get totalTime => questionCount * timePerQuestion;

  DuelConfig copyWith({
    int? questionCount,
    int? timePerQuestion,
    String? continent,
    DuelQuizType? quizType,
    DuelDifficulty? difficulty,
  }) {
    return DuelConfig(
      questionCount: questionCount ?? this.questionCount,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      continent: continent ?? this.continent,
      quizType: quizType ?? this.quizType,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionCount': questionCount,
      'timePerQuestion': timePerQuestion,
      'continent': continent,
      'quizType': quizType.name,
      'difficulty': difficulty.name,
    };
  }

  /// Default configuration
  static const standard = DuelConfig();

  /// Quick duel configuration
  static const quick = DuelConfig(
    questionCount: 5,
    timePerQuestion: 10,
    difficulty: DuelDifficulty.easy,
  );

  /// Challenge duel configuration
  static const challenge = DuelConfig(
    questionCount: 15,
    timePerQuestion: 20,
    difficulty: DuelDifficulty.hard,
  );
}

/// Duel quiz type
enum DuelQuizType {
  flags,
  capitals,
  countries,
  mixed;

  String getNameEn() {
    switch (this) {
      case DuelQuizType.flags:
        return 'Flags';
      case DuelQuizType.capitals:
        return 'Capitals';
      case DuelQuizType.countries:
        return 'Countries';
      case DuelQuizType.mixed:
        return 'Mixed';
    }
  }

  String getNameAr() {
    switch (this) {
      case DuelQuizType.flags:
        return 'الأعلام';
      case DuelQuizType.capitals:
        return 'العواصم';
      case DuelQuizType.countries:
        return 'الدول';
      case DuelQuizType.mixed:
        return 'مختلط';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();

  IconData get icon {
    switch (this) {
      case DuelQuizType.flags:
        return Icons.flag;
      case DuelQuizType.capitals:
        return Icons.location_city;
      case DuelQuizType.countries:
        return Icons.public;
      case DuelQuizType.mixed:
        return Icons.shuffle;
    }
  }
}

/// Duel difficulty
enum DuelDifficulty {
  easy(xpMultiplier: 1.0),
  medium(xpMultiplier: 1.5),
  hard(xpMultiplier: 2.0);

  const DuelDifficulty({required this.xpMultiplier});

  final double xpMultiplier;

  String getNameEn() {
    switch (this) {
      case DuelDifficulty.easy:
        return 'Easy';
      case DuelDifficulty.medium:
        return 'Medium';
      case DuelDifficulty.hard:
        return 'Hard';
    }
  }

  String getNameAr() {
    switch (this) {
      case DuelDifficulty.easy:
        return 'سهل';
      case DuelDifficulty.medium:
        return 'متوسط';
      case DuelDifficulty.hard:
        return 'صعب';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();
}

/// Duel result for a player
@immutable
class DuelPlayerResult {
  const DuelPlayerResult({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.correctAnswers,
    required this.totalTime,
    required this.averageTime,
  });

  factory DuelPlayerResult.fromJson(Map<String, dynamic> json) {
    return DuelPlayerResult(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      score: json['score'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalTime: json['totalTime'] as int? ?? 0,
      averageTime: (json['averageTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Player's user ID
  final String userId;

  /// Player's display name
  final String displayName;

  /// Player's avatar URL
  final String? avatarUrl;

  /// Final score (points)
  final int score;

  /// Number of correct answers
  final int correctAnswers;

  /// Total time taken (seconds)
  final int totalTime;

  /// Average time per question (seconds)
  final double averageTime;

  DuelPlayerResult copyWith({
    String? newUserId,
    String? displayName,
    String? avatarUrl,
    int? score,
    int? correctAnswers,
    int? totalTime,
    double? averageTime,
  }) {
    return DuelPlayerResult(
      userId: newUserId ?? userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalTime: totalTime ?? this.totalTime,
      averageTime: averageTime ?? this.averageTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalTime': totalTime,
      'averageTime': averageTime,
    };
  }
}

/// Duel entity
@immutable
class Duel {
  const Duel({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    this.challengerAvatar,
    required this.opponentId,
    required this.opponentName,
    this.opponentAvatar,
    required this.config,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.challengerResult,
    this.opponentResult,
    this.winnerId,
    this.xpReward = 0,
  });

  factory Duel.fromJson(Map<String, dynamic> json) {
    return Duel(
      id: json['id'] as String,
      challengerId: json['challengerId'] as String,
      challengerName: json['challengerName'] as String,
      challengerAvatar: json['challengerAvatar'] as String?,
      opponentId: json['opponentId'] as String,
      opponentName: json['opponentName'] as String,
      opponentAvatar: json['opponentAvatar'] as String?,
      config: DuelConfig.fromJson(json['config'] as Map<String, dynamic>),
      status: DuelStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DuelStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      challengerResult: json['challengerResult'] != null
          ? DuelPlayerResult.fromJson(
              json['challengerResult'] as Map<String, dynamic>)
          : null,
      opponentResult: json['opponentResult'] != null
          ? DuelPlayerResult.fromJson(
              json['opponentResult'] as Map<String, dynamic>)
          : null,
      winnerId: json['winnerId'] as String?,
      xpReward: json['xpReward'] as int? ?? 0,
    );
  }

  /// Unique duel ID
  final String id;

  /// Challenger (who initiated) user ID
  final String challengerId;

  /// Challenger display name
  final String challengerName;

  /// Challenger avatar URL
  final String? challengerAvatar;

  /// Opponent user ID
  final String opponentId;

  /// Opponent display name
  final String opponentName;

  /// Opponent avatar URL
  final String? opponentAvatar;

  /// Quiz configuration for this duel
  final DuelConfig config;

  /// Current status
  final DuelStatus status;

  /// When the challenge was created
  final DateTime createdAt;

  /// When the duel started (both accepted)
  final DateTime? startedAt;

  /// When the duel was completed
  final DateTime? completedAt;

  /// Challenger's result
  final DuelPlayerResult? challengerResult;

  /// Opponent's result
  final DuelPlayerResult? opponentResult;

  /// Winner user ID (null if draw)
  final String? winnerId;

  /// XP reward for the winner
  final int xpReward;

  /// Check if duel is active (can still be played)
  bool get isActive =>
      status == DuelStatus.pending || status == DuelStatus.inProgress;

  /// Check if this is a draw
  bool get isDraw =>
      status == DuelStatus.completed &&
      winnerId == null &&
      challengerResult != null &&
      opponentResult != null;

  /// Get winner result
  DuelPlayerResult? get winnerResult {
    if (winnerId == null) return null;
    if (winnerId == challengerId) return challengerResult;
    return opponentResult;
  }

  /// Get loser result
  DuelPlayerResult? get loserResult {
    if (winnerId == null) return null;
    if (winnerId == challengerId) return opponentResult;
    return challengerResult;
  }

  /// Check if a specific user won
  bool didUserWin(String userId) => winnerId == userId;

  /// Check if a specific user is the challenger
  bool isChallenger(String userId) => challengerId == userId;

  /// Check if challenge has expired (older than 24 hours and still pending)
  bool get hasExpired {
    if (status != DuelStatus.pending) return false;
    return DateTime.now().difference(createdAt).inHours >= 24;
  }

  /// Time remaining to accept challenge
  Duration get timeToAccept {
    if (status != DuelStatus.pending) return Duration.zero;
    final expiresAt = createdAt.add(const Duration(hours: 24));
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duel copyWith({
    String? id,
    String? challengerId,
    String? challengerName,
    String? challengerAvatar,
    String? opponentId,
    String? opponentName,
    String? opponentAvatar,
    DuelConfig? config,
    DuelStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DuelPlayerResult? challengerResult,
    DuelPlayerResult? opponentResult,
    String? winnerId,
    int? xpReward,
  }) {
    return Duel(
      id: id ?? this.id,
      challengerId: challengerId ?? this.challengerId,
      challengerName: challengerName ?? this.challengerName,
      challengerAvatar: challengerAvatar ?? this.challengerAvatar,
      opponentId: opponentId ?? this.opponentId,
      opponentName: opponentName ?? this.opponentName,
      opponentAvatar: opponentAvatar ?? this.opponentAvatar,
      config: config ?? this.config,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      challengerResult: challengerResult ?? this.challengerResult,
      opponentResult: opponentResult ?? this.opponentResult,
      winnerId: winnerId ?? this.winnerId,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengerId': challengerId,
      'challengerName': challengerName,
      'challengerAvatar': challengerAvatar,
      'opponentId': opponentId,
      'opponentName': opponentName,
      'opponentAvatar': opponentAvatar,
      'config': config.toJson(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'challengerResult': challengerResult?.toJson(),
      'opponentResult': opponentResult?.toJson(),
      'winnerId': winnerId,
      'xpReward': xpReward,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Duel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Duel invitation to display
@immutable
class DuelInvitation {
  const DuelInvitation({
    required this.duel,
    required this.fromUser,
    required this.toUser,
  });

  final Duel duel;
  final String fromUser;
  final String toUser;

  bool isForUser(String userId) => toUser == userId;
  bool isFromUser(String userId) => fromUser == userId;
}

/// Calculate XP reward based on duel config and result
int calculateDuelXpReward(DuelConfig config, bool won, int scoreDifference) {
  const baseWinXp = 50;
  const baseLoseXp = 15;

  final base = won ? baseWinXp : baseLoseXp;
  final difficultyBonus = (base * config.difficulty.xpMultiplier).round();

  // Bonus for margin of victory
  final marginBonus = won ? (scoreDifference ~/ 10) * 5 : 0;

  // Bonus for more questions
  final questionBonus = (config.questionCount - 10) * 2;

  return difficultyBonus + marginBonus + questionBonus;
}
