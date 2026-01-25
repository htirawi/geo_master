import 'package:flutter/material.dart';

/// Type of daily challenge
enum DailyChallengeType {
  /// Complete X quizzes
  completeQuizzes(
    iconData: Icons.quiz,
    defaultTarget: 3,
  ),

  /// Get a perfect score on any quiz
  perfectScore(
    iconData: Icons.star,
    defaultTarget: 1,
  ),

  /// Learn X new countries
  learnCountries(
    iconData: Icons.school,
    defaultTarget: 5,
  ),

  /// Complete a quiz on a specific continent
  specificContinent(
    iconData: Icons.public,
    defaultTarget: 1,
  ),

  /// Answer X questions correctly within time limit
  speedChallenge(
    iconData: Icons.timer,
    defaultTarget: 10,
  ),

  /// Answer X questions in a row without mistakes
  noMistakes(
    iconData: Icons.check_circle,
    defaultTarget: 15,
  ),

  /// Spend X minutes studying
  studyTime(
    iconData: Icons.access_time,
    defaultTarget: 15,
  ),

  /// Complete a specific quiz type
  quizType(
    iconData: Icons.category,
    defaultTarget: 1,
  ),

  /// Achieve a certain score threshold
  scoreThreshold(
    iconData: Icons.trending_up,
    defaultTarget: 80,
  ),

  /// Practice a weak area
  practiceWeakArea(
    iconData: Icons.fitness_center,
    defaultTarget: 1,
  );

  const DailyChallengeType({
    required this.iconData,
    required this.defaultTarget,
  });

  final IconData iconData;
  final int defaultTarget;

  String getNameEn() {
    switch (this) {
      case DailyChallengeType.completeQuizzes:
        return 'Complete Quizzes';
      case DailyChallengeType.perfectScore:
        return 'Perfect Score';
      case DailyChallengeType.learnCountries:
        return 'Learn Countries';
      case DailyChallengeType.specificContinent:
        return 'Continent Focus';
      case DailyChallengeType.speedChallenge:
        return 'Speed Challenge';
      case DailyChallengeType.noMistakes:
        return 'Accuracy Challenge';
      case DailyChallengeType.studyTime:
        return 'Study Time';
      case DailyChallengeType.quizType:
        return 'Quiz Type';
      case DailyChallengeType.scoreThreshold:
        return 'Score Goal';
      case DailyChallengeType.practiceWeakArea:
        return 'Practice Weak Area';
    }
  }

  String getNameAr() {
    switch (this) {
      case DailyChallengeType.completeQuizzes:
        return 'أكمل الاختبارات';
      case DailyChallengeType.perfectScore:
        return 'درجة كاملة';
      case DailyChallengeType.learnCountries:
        return 'تعلم الدول';
      case DailyChallengeType.specificContinent:
        return 'تركيز على قارة';
      case DailyChallengeType.speedChallenge:
        return 'تحدي السرعة';
      case DailyChallengeType.noMistakes:
        return 'تحدي الدقة';
      case DailyChallengeType.studyTime:
        return 'وقت الدراسة';
      case DailyChallengeType.quizType:
        return 'نوع الاختبار';
      case DailyChallengeType.scoreThreshold:
        return 'هدف الدرجة';
      case DailyChallengeType.practiceWeakArea:
        return 'تدرب على نقاط الضعف';
    }
  }
}

/// Challenge difficulty level
enum ChallengeDifficulty {
  easy(xpMultiplier: 1.0, color: Color(0xFF4CAF50)),
  medium(xpMultiplier: 1.5, color: Color(0xFFFF9800)),
  hard(xpMultiplier: 2.0, color: Color(0xFFF44336));

  const ChallengeDifficulty({
    required this.xpMultiplier,
    required this.color,
  });

  final double xpMultiplier;
  final Color color;

  String getNameEn() {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
    }
  }

  String getNameAr() {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'سهل';
      case ChallengeDifficulty.medium:
        return 'متوسط';
      case ChallengeDifficulty.hard:
        return 'صعب';
    }
  }
}

/// Theme for special challenge days
@immutable
class ChallengeTheme {
  const ChallengeTheme({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.accentColor,
    this.iconAsset,
    this.descriptionEn,
    this.descriptionAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final Color accentColor;
  final String? iconAsset;
  final String? descriptionEn;
  final String? descriptionAr;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;
  String? getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;

  /// Predefined themes for special days
  static const africaDay = ChallengeTheme(
    id: 'africa_day',
    nameEn: 'Africa Day',
    nameAr: 'يوم أفريقيا',
    accentColor: Color(0xFF009639),
    descriptionEn: 'Celebrate the African continent!',
    descriptionAr: 'احتفل بالقارة الأفريقية!',
  );

  static const europeWeek = ChallengeTheme(
    id: 'europe_week',
    nameEn: 'Europe Week',
    nameAr: 'أسبوع أوروبا',
    accentColor: Color(0xFF003399),
    descriptionEn: 'Explore the European continent!',
    descriptionAr: 'استكشف القارة الأوروبية!',
  );

  static const capitalsChallenge = ChallengeTheme(
    id: 'capitals_challenge',
    nameEn: 'Capitals Challenge',
    nameAr: 'تحدي العواصم',
    accentColor: Color(0xFFFFD700),
    descriptionEn: 'Test your knowledge of world capitals!',
    descriptionAr: 'اختبر معرفتك بعواصم العالم!',
  );

  static const flagFrenzy = ChallengeTheme(
    id: 'flag_frenzy',
    nameEn: 'Flag Frenzy',
    nameAr: 'جنون الأعلام',
    accentColor: Color(0xFFE91E63),
    descriptionEn: 'A day dedicated to world flags!',
    descriptionAr: 'يوم مخصص لأعلام العالم!',
  );

  static const speedMaster = ChallengeTheme(
    id: 'speed_master',
    nameEn: 'Speed Master',
    nameAr: 'سيد السرعة',
    accentColor: Color(0xFFFF5722),
    descriptionEn: 'Race against time!',
    descriptionAr: 'تسابق ضد الزمن!',
  );

  static const weekendWarrior = ChallengeTheme(
    id: 'weekend_warrior',
    nameEn: 'Weekend Warrior',
    nameAr: 'محارب نهاية الأسبوع',
    accentColor: Color(0xFF9C27B0),
    descriptionEn: 'Double XP weekend special!',
    descriptionAr: 'عرض نهاية الأسبوع - ضعف النقاط!',
  );

  static const List<ChallengeTheme> allThemes = [
    africaDay,
    europeWeek,
    capitalsChallenge,
    flagFrenzy,
    speedMaster,
    weekendWarrior,
  ];
}

/// Daily challenge entity
@immutable
class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.date,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.targetValue,
    required this.xpReward,
    required this.difficulty,
    this.bonusXpForStreak = 0,
    this.theme,
    this.metadata,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: DailyChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DailyChallengeType.completeQuizzes,
      ),
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionAr: json['descriptionAr'] as String,
      targetValue: json['targetValue'] as int,
      xpReward: json['xpReward'] as int,
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      bonusXpForStreak: json['bonusXpForStreak'] as int? ?? 0,
      theme: json['theme'] != null
          ? ChallengeTheme.allThemes.firstWhere(
              (t) => t.id == json['theme'],
              orElse: () => ChallengeTheme.allThemes.first,
            )
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Unique identifier
  final String id;

  /// Date this challenge is active
  final DateTime date;

  /// Type of challenge
  final DailyChallengeType type;

  /// English title
  final String titleEn;

  /// Arabic title
  final String titleAr;

  /// English description
  final String descriptionEn;

  /// Arabic description
  final String descriptionAr;

  /// Target value to complete the challenge
  final int targetValue;

  /// Base XP reward for completion
  final int xpReward;

  /// Difficulty level
  final ChallengeDifficulty difficulty;

  /// Extra XP if user is on a challenge streak
  final int bonusXpForStreak;

  /// Optional theme for special days
  final ChallengeTheme? theme;

  /// Additional metadata (e.g., specific continent, quiz type)
  final Map<String, dynamic>? metadata;

  /// Get localized title
  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  /// Get localized description
  String getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;

  /// Calculate total XP reward including streak bonus
  int getTotalXpReward(int currentStreak) {
    final streakBonus =
        currentStreak > 0 ? (bonusXpForStreak * (currentStreak ~/ 7)) : 0;
    return (xpReward * difficulty.xpMultiplier).round() + streakBonus;
  }

  /// Check if this challenge is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if this challenge has expired
  bool get isExpired {
    final now = DateTime.now();
    final challengeEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return now.isAfter(challengeEnd);
  }

  /// Time remaining until challenge expires
  Duration get timeRemaining {
    final now = DateTime.now();
    final challengeEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    if (now.isAfter(challengeEnd)) return Duration.zero;
    return challengeEnd.difference(now);
  }

  DailyChallenge copyWith({
    String? id,
    DateTime? date,
    DailyChallengeType? type,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    int? targetValue,
    int? xpReward,
    ChallengeDifficulty? difficulty,
    int? bonusXpForStreak,
    ChallengeTheme? theme,
    Map<String, dynamic>? metadata,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      bonusXpForStreak: bonusXpForStreak ?? this.bonusXpForStreak,
      theme: theme ?? this.theme,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'difficulty': difficulty.name,
      'bonusXpForStreak': bonusXpForStreak,
      'theme': theme?.id,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Progress tracking for a daily challenge
@immutable
class ChallengeProgress {
  const ChallengeProgress({
    required this.challengeId,
    required this.userId,
    required this.currentValue,
    required this.isCompleted,
    this.completedAt,
    this.xpAwarded = 0,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      currentValue: json['currentValue'] as int,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      xpAwarded: json['xpAwarded'] as int? ?? 0,
    );
  }

  /// Create initial progress for a challenge
  factory ChallengeProgress.initial(String challengeId, String userId) {
    return ChallengeProgress(
      challengeId: challengeId,
      userId: userId,
      currentValue: 0,
      isCompleted: false,
    );
  }

  final String challengeId;
  final String userId;
  final int currentValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final int xpAwarded;

  double getProgressPercentage(int targetValue) {
    if (targetValue <= 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  ChallengeProgress copyWith({
    String? challengeId,
    String? newUserId,
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
    int? xpAwarded,
  }) {
    return ChallengeProgress(
      challengeId: challengeId ?? this.challengeId,
      userId: newUserId ?? userId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      xpAwarded: xpAwarded ?? this.xpAwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'xpAwarded': xpAwarded,
    };
  }
}

/// User's daily challenge streak information
@immutable
class ChallengeStreak {
  const ChallengeStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletedDate,
    required this.totalChallengesCompleted,
  });

  factory ChallengeStreak.fromJson(Map<String, dynamic> json) {
    return ChallengeStreak(
      userId: json['userId'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      totalChallengesCompleted: json['totalChallengesCompleted'] as int? ?? 0,
    );
  }

  /// Create initial streak for a new user
  factory ChallengeStreak.initial(String userId) {
    return ChallengeStreak(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastCompletedDate: null,
      totalChallengesCompleted: 0,
    );
  }

  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int totalChallengesCompleted;

  /// Check if streak is still active (completed yesterday or today)
  bool get isStreakActive {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastCompleted = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return lastCompleted == today || lastCompleted == yesterday;
  }

  /// Check if user already completed today's challenge
  bool get completedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  ChallengeStreak copyWith({
    String? newUserId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? totalChallengesCompleted,
  }) {
    return ChallengeStreak(
      userId: newUserId ?? userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalChallengesCompleted:
          totalChallengesCompleted ?? this.totalChallengesCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'totalChallengesCompleted': totalChallengesCompleted,
    };
  }
}

/// Generator for daily challenges
class DailyChallengeGenerator {
  DailyChallengeGenerator._();

  /// Generate a challenge for a specific date
  static DailyChallenge generateForDate(DateTime date) {
    // Use date as seed for deterministic generation
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final typeIndex = seed % DailyChallengeType.values.length;
    final type = DailyChallengeType.values[typeIndex];

    // Determine difficulty based on day of week
    final difficulty = switch (date.weekday) {
      DateTime.saturday || DateTime.sunday => ChallengeDifficulty.hard,
      DateTime.friday => ChallengeDifficulty.medium,
      _ => seed % 3 == 0 ? ChallengeDifficulty.medium : ChallengeDifficulty.easy,
    };

    // Calculate target based on type and difficulty
    final baseTarget = type.defaultTarget;
    final target = switch (difficulty) {
      ChallengeDifficulty.easy => baseTarget,
      ChallengeDifficulty.medium => (baseTarget * 1.5).round(),
      ChallengeDifficulty.hard => baseTarget * 2,
    };

    // Base XP reward
    const baseXp = 50;
    final xpReward = (baseXp * difficulty.xpMultiplier).round();

    // Check for themed days
    ChallengeTheme? theme;
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      theme = ChallengeTheme.weekendWarrior;
    }

    return DailyChallenge(
      id: 'daily_${date.year}_${date.month}_${date.day}',
      date: DateTime(date.year, date.month, date.day),
      type: type,
      titleEn: _getTitleEn(type, target, difficulty),
      titleAr: _getTitleAr(type, target, difficulty),
      descriptionEn: _getDescriptionEn(type, target),
      descriptionAr: _getDescriptionAr(type, target),
      targetValue: target,
      xpReward: xpReward,
      difficulty: difficulty,
      bonusXpForStreak: 10,
      theme: theme,
    );
  }

  /// Generate today's challenge
  static DailyChallenge generateForToday() {
    return generateForDate(DateTime.now());
  }

  static String _getTitleEn(
      DailyChallengeType type, int target, ChallengeDifficulty difficulty) {
    final difficultyPrefix = switch (difficulty) {
      ChallengeDifficulty.easy => '',
      ChallengeDifficulty.medium => 'Challenge: ',
      ChallengeDifficulty.hard => 'Hard Challenge: ',
    };

    return switch (type) {
      DailyChallengeType.completeQuizzes =>
        '${difficultyPrefix}Complete $target Quizzes',
      DailyChallengeType.perfectScore =>
        '${difficultyPrefix}Get $target Perfect Score${target > 1 ? 's' : ''}',
      DailyChallengeType.learnCountries =>
        '${difficultyPrefix}Learn $target New Countries',
      DailyChallengeType.specificContinent =>
        '${difficultyPrefix}Continent Explorer',
      DailyChallengeType.speedChallenge =>
        '$difficultyPrefix Speed Demon - $target Quick Answers',
      DailyChallengeType.noMistakes =>
        '$difficultyPrefix$target Correct in a Row',
      DailyChallengeType.studyTime =>
        '${difficultyPrefix}Study for $target Minutes',
      DailyChallengeType.quizType => '${difficultyPrefix}Quiz Type Master',
      DailyChallengeType.scoreThreshold =>
        '${difficultyPrefix}Score $target% or Higher',
      DailyChallengeType.practiceWeakArea =>
        '${difficultyPrefix}Improve Your Weak Areas',
    };
  }

  static String _getTitleAr(
      DailyChallengeType type, int target, ChallengeDifficulty difficulty) {
    final difficultyPrefix = switch (difficulty) {
      ChallengeDifficulty.easy => '',
      ChallengeDifficulty.medium => 'تحدي: ',
      ChallengeDifficulty.hard => 'تحدي صعب: ',
    };

    return switch (type) {
      DailyChallengeType.completeQuizzes =>
        '$difficultyPrefixأكمل $target اختبارات',
      DailyChallengeType.perfectScore =>
        '$difficultyPrefixاحصل على $target درجة كاملة',
      DailyChallengeType.learnCountries =>
        '$difficultyPrefixتعلم $target دول جديدة',
      DailyChallengeType.specificContinent => '$difficultyPrefixمستكشف القارات',
      DailyChallengeType.speedChallenge =>
        '$difficultyPrefix تحدي السرعة - $target إجابات سريعة',
      DailyChallengeType.noMistakes =>
        '$difficultyPrefix$target إجابات صحيحة متتالية',
      DailyChallengeType.studyTime =>
        '$difficultyPrefixادرس لمدة $target دقيقة',
      DailyChallengeType.quizType => '$difficultyPrefixأستاذ أنواع الاختبارات',
      DailyChallengeType.scoreThreshold =>
        '$difficultyPrefixاحصل على $target% أو أعلى',
      DailyChallengeType.practiceWeakArea => '$difficultyPrefixحسّن نقاط ضعفك',
    };
  }

  static String _getDescriptionEn(DailyChallengeType type, int target) {
    return switch (type) {
      DailyChallengeType.completeQuizzes =>
        'Complete $target quizzes of any type to earn your reward.',
      DailyChallengeType.perfectScore =>
        'Achieve a perfect score on $target quiz${target > 1 ? 'zes' : ''} without any mistakes.',
      DailyChallengeType.learnCountries =>
        'Learn about $target countries you haven\'t explored yet.',
      DailyChallengeType.specificContinent =>
        'Complete a quiz focusing on a specific continent.',
      DailyChallengeType.speedChallenge =>
        'Answer $target questions correctly in under 5 seconds each.',
      DailyChallengeType.noMistakes =>
        'Answer $target questions in a row without making any mistakes.',
      DailyChallengeType.studyTime =>
        'Spend at least $target minutes studying and learning.',
      DailyChallengeType.quizType =>
        'Complete a quiz of a specific type you haven\'t tried recently.',
      DailyChallengeType.scoreThreshold =>
        'Complete any quiz with a score of $target% or higher.',
      DailyChallengeType.practiceWeakArea =>
        'Focus on improving areas where you\'ve struggled before.',
    };
  }

  static String _getDescriptionAr(DailyChallengeType type, int target) {
    return switch (type) {
      DailyChallengeType.completeQuizzes =>
        'أكمل $target اختبارات من أي نوع للحصول على مكافأتك.',
      DailyChallengeType.perfectScore =>
        'احصل على درجة كاملة في $target اختبار بدون أي أخطاء.',
      DailyChallengeType.learnCountries =>
        'تعلم عن $target دول لم تستكشفها بعد.',
      DailyChallengeType.specificContinent =>
        'أكمل اختبارًا يركز على قارة معينة.',
      DailyChallengeType.speedChallenge =>
        'أجب على $target أسئلة بشكل صحيح في أقل من 5 ثوانٍ لكل سؤال.',
      DailyChallengeType.noMistakes =>
        'أجب على $target أسئلة متتالية بدون أي أخطاء.',
      DailyChallengeType.studyTime =>
        'اقضِ $target دقيقة على الأقل في الدراسة والتعلم.',
      DailyChallengeType.quizType =>
        'أكمل اختبارًا من نوع لم تجربه مؤخرًا.',
      DailyChallengeType.scoreThreshold =>
        'أكمل أي اختبار بدرجة $target% أو أعلى.',
      DailyChallengeType.practiceWeakArea =>
        'ركز على تحسين المجالات التي واجهت صعوبة فيها سابقًا.',
    };
  }
}
