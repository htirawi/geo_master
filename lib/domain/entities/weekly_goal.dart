import 'package:flutter/material.dart';

/// Type of weekly goal
enum WeeklyGoalType {
  /// Earn X XP this week
  totalXp(
    iconData: Icons.stars,
    color: Color(0xFFFFD700),
  ),

  /// Complete X quizzes
  quizzesCompleted(
    iconData: Icons.quiz,
    color: Color(0xFF4CAF50),
  ),

  /// Learn X new countries
  countriesLearned(
    iconData: Icons.school,
    color: Color(0xFF2196F3),
  ),

  /// Get X perfect scores
  perfectScores(
    iconData: Icons.emoji_events,
    color: Color(0xFFE91E63),
  ),

  /// Study on X different days
  studyDays(
    iconData: Icons.calendar_today,
    color: Color(0xFF9C27B0),
  ),

  /// Complete X daily challenges
  challengesCompleted(
    iconData: Icons.flag,
    color: Color(0xFFFF9800),
  ),

  /// Maintain a X day streak
  maintainStreak(
    iconData: Icons.local_fire_department,
    color: Color(0xFFFF5722),
  ),

  /// Answer X questions correctly
  correctAnswers(
    iconData: Icons.check_circle,
    color: Color(0xFF00BCD4),
  ),

  /// Achieve X% average accuracy
  averageAccuracy(
    iconData: Icons.track_changes,
    color: Color(0xFF795548),
  ),

  /// Explore X continents
  continentsExplored(
    iconData: Icons.public,
    color: Color(0xFF607D8B),
  );

  const WeeklyGoalType({
    required this.iconData,
    required this.color,
  });

  final IconData iconData;
  final Color color;

  String getNameEn() {
    switch (this) {
      case WeeklyGoalType.totalXp:
        return 'Earn XP';
      case WeeklyGoalType.quizzesCompleted:
        return 'Complete Quizzes';
      case WeeklyGoalType.countriesLearned:
        return 'Learn Countries';
      case WeeklyGoalType.perfectScores:
        return 'Perfect Scores';
      case WeeklyGoalType.studyDays:
        return 'Study Days';
      case WeeklyGoalType.challengesCompleted:
        return 'Daily Challenges';
      case WeeklyGoalType.maintainStreak:
        return 'Maintain Streak';
      case WeeklyGoalType.correctAnswers:
        return 'Correct Answers';
      case WeeklyGoalType.averageAccuracy:
        return 'Average Accuracy';
      case WeeklyGoalType.continentsExplored:
        return 'Explore Continents';
    }
  }

  String getNameAr() {
    switch (this) {
      case WeeklyGoalType.totalXp:
        return 'اكسب نقاط';
      case WeeklyGoalType.quizzesCompleted:
        return 'أكمل اختبارات';
      case WeeklyGoalType.countriesLearned:
        return 'تعلم دول';
      case WeeklyGoalType.perfectScores:
        return 'درجات كاملة';
      case WeeklyGoalType.studyDays:
        return 'أيام الدراسة';
      case WeeklyGoalType.challengesCompleted:
        return 'التحديات اليومية';
      case WeeklyGoalType.maintainStreak:
        return 'حافظ على السلسلة';
      case WeeklyGoalType.correctAnswers:
        return 'إجابات صحيحة';
      case WeeklyGoalType.averageAccuracy:
        return 'متوسط الدقة';
      case WeeklyGoalType.continentsExplored:
        return 'استكشف قارات';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();
}

/// Goal difficulty level
enum GoalDifficulty {
  easy(xpMultiplier: 1.0),
  medium(xpMultiplier: 1.5),
  hard(xpMultiplier: 2.0),
  extreme(xpMultiplier: 3.0);

  const GoalDifficulty({required this.xpMultiplier});

  final double xpMultiplier;

  String getNameEn() {
    switch (this) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
      case GoalDifficulty.extreme:
        return 'Extreme';
    }
  }

  String getNameAr() {
    switch (this) {
      case GoalDifficulty.easy:
        return 'سهل';
      case GoalDifficulty.medium:
        return 'متوسط';
      case GoalDifficulty.hard:
        return 'صعب';
      case GoalDifficulty.extreme:
        return 'متطرف';
    }
  }

  String getName(bool isArabic) => isArabic ? getNameAr() : getNameEn();
}

/// Weekly goal entity
@immutable
class WeeklyGoal {
  const WeeklyGoal({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.targetValue,
    required this.xpReward,
    required this.weekStart,
    required this.weekEnd,
    required this.difficulty,
    this.isCustom = false,
    this.currentValue = 0,
  });

  /// Unique identifier
  final String id;

  /// Type of goal
  final WeeklyGoalType type;

  /// English title
  final String titleEn;

  /// Arabic title
  final String titleAr;

  /// English description
  final String descriptionEn;

  /// Arabic description
  final String descriptionAr;

  /// Target value to complete the goal
  final int targetValue;

  /// Current progress value
  final int currentValue;

  /// XP reward for completion
  final int xpReward;

  /// Start of the week
  final DateTime weekStart;

  /// End of the week
  final DateTime weekEnd;

  /// Difficulty level
  final GoalDifficulty difficulty;

  /// Whether this is a user-set custom goal
  final bool isCustom;

  /// Get localized title
  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  /// Get localized description
  String getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetValue <= 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Check if goal is completed
  bool get isCompleted => currentValue >= targetValue;

  /// Check if goal is active (within the week)
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(weekStart) && now.isBefore(weekEnd);
  }

  /// Check if goal has expired
  bool get isExpired => DateTime.now().isAfter(weekEnd);

  /// Days remaining until goal expires
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(weekEnd)) return 0;
    return weekEnd.difference(now).inDays;
  }

  /// Calculate total XP with difficulty multiplier
  int get totalXpReward => (xpReward * difficulty.xpMultiplier).round();

  WeeklyGoal copyWith({
    String? id,
    WeeklyGoalType? type,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    int? targetValue,
    int? currentValue,
    int? xpReward,
    DateTime? weekStart,
    DateTime? weekEnd,
    GoalDifficulty? difficulty,
    bool? isCustom,
  }) {
    return WeeklyGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      xpReward: xpReward ?? this.xpReward,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      difficulty: difficulty ?? this.difficulty,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'xpReward': xpReward,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'difficulty': difficulty.name,
      'isCustom': isCustom,
    };
  }

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      id: json['id'] as String,
      type: WeeklyGoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WeeklyGoalType.totalXp,
      ),
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionAr: json['descriptionAr'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      xpReward: json['xpReward'] as int,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      difficulty: GoalDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => GoalDifficulty.medium,
      ),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Preset templates for weekly goals
@immutable
class WeeklyGoalPreset {
  const WeeklyGoalPreset({
    required this.id,
    required this.type,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.easyTarget,
    required this.mediumTarget,
    required this.hardTarget,
    required this.extremeTarget,
    required this.baseXpReward,
  });

  final String id;
  final WeeklyGoalType type;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final int easyTarget;
  final int mediumTarget;
  final int hardTarget;
  final int extremeTarget;
  final int baseXpReward;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;
  String getDescription(bool isArabic) =>
      isArabic ? descriptionAr : descriptionEn;

  int getTargetForDifficulty(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return easyTarget;
      case GoalDifficulty.medium:
        return mediumTarget;
      case GoalDifficulty.hard:
        return hardTarget;
      case GoalDifficulty.extreme:
        return extremeTarget;
    }
  }

  /// Create a WeeklyGoal from this preset
  WeeklyGoal createGoal({
    required GoalDifficulty difficulty,
    DateTime? weekStart,
    bool isCustom = false,
  }) {
    final start = weekStart ?? _getWeekStart(DateTime.now());
    final end = start.add(const Duration(days: 7));
    final target = getTargetForDifficulty(difficulty);

    return WeeklyGoal(
      id: '${id}_${start.millisecondsSinceEpoch}',
      type: type,
      titleEn: nameEn,
      titleAr: nameAr,
      descriptionEn: _formatDescription(descriptionEn, target),
      descriptionAr: _formatDescription(descriptionAr, target),
      targetValue: target,
      xpReward: baseXpReward,
      weekStart: start,
      weekEnd: end,
      difficulty: difficulty,
      isCustom: isCustom,
    );
  }

  String _formatDescription(String description, int target) {
    return description.replaceAll('{target}', target.toString());
  }

  static DateTime _getWeekStart(DateTime date) {
    // Week starts on Monday
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// All available goal presets
  static const List<WeeklyGoalPreset> allPresets = [
    xpGoal,
    quizzesGoal,
    countriesGoal,
    perfectScoresGoal,
    studyDaysGoal,
    challengesGoal,
    streakGoal,
    answersGoal,
  ];

  static const xpGoal = WeeklyGoalPreset(
    id: 'weekly_xp',
    type: WeeklyGoalType.totalXp,
    nameEn: 'XP Hunter',
    nameAr: 'صائد النقاط',
    descriptionEn: 'Earn {target} XP this week through any activity.',
    descriptionAr: 'اكسب {target} نقطة هذا الأسبوع من أي نشاط.',
    easyTarget: 500,
    mediumTarget: 1500,
    hardTarget: 4000,
    extremeTarget: 10000,
    baseXpReward: 100,
  );

  static const quizzesGoal = WeeklyGoalPreset(
    id: 'weekly_quizzes',
    type: WeeklyGoalType.quizzesCompleted,
    nameEn: 'Quiz Master',
    nameAr: 'أستاذ الاختبارات',
    descriptionEn: 'Complete {target} quizzes this week.',
    descriptionAr: 'أكمل {target} اختبارات هذا الأسبوع.',
    easyTarget: 5,
    mediumTarget: 15,
    hardTarget: 30,
    extremeTarget: 50,
    baseXpReward: 75,
  );

  static const countriesGoal = WeeklyGoalPreset(
    id: 'weekly_countries',
    type: WeeklyGoalType.countriesLearned,
    nameEn: 'World Explorer',
    nameAr: 'مستكشف العالم',
    descriptionEn: 'Learn about {target} new countries this week.',
    descriptionAr: 'تعلم عن {target} دول جديدة هذا الأسبوع.',
    easyTarget: 10,
    mediumTarget: 25,
    hardTarget: 50,
    extremeTarget: 100,
    baseXpReward: 100,
  );

  static const perfectScoresGoal = WeeklyGoalPreset(
    id: 'weekly_perfects',
    type: WeeklyGoalType.perfectScores,
    nameEn: 'Perfectionist',
    nameAr: 'الكمالي',
    descriptionEn: 'Achieve {target} perfect quiz scores this week.',
    descriptionAr: 'احصل على {target} درجات كاملة هذا الأسبوع.',
    easyTarget: 2,
    mediumTarget: 5,
    hardTarget: 10,
    extremeTarget: 20,
    baseXpReward: 150,
  );

  static const studyDaysGoal = WeeklyGoalPreset(
    id: 'weekly_study_days',
    type: WeeklyGoalType.studyDays,
    nameEn: 'Consistent Learner',
    nameAr: 'متعلم مستمر',
    descriptionEn: 'Study on {target} different days this week.',
    descriptionAr: 'ادرس في {target} أيام مختلفة هذا الأسبوع.',
    easyTarget: 3,
    mediumTarget: 5,
    hardTarget: 7,
    extremeTarget: 7,
    baseXpReward: 80,
  );

  static const challengesGoal = WeeklyGoalPreset(
    id: 'weekly_challenges',
    type: WeeklyGoalType.challengesCompleted,
    nameEn: 'Challenge Champion',
    nameAr: 'بطل التحديات',
    descriptionEn: 'Complete {target} daily challenges this week.',
    descriptionAr: 'أكمل {target} تحديات يومية هذا الأسبوع.',
    easyTarget: 3,
    mediumTarget: 5,
    hardTarget: 7,
    extremeTarget: 7,
    baseXpReward: 100,
  );

  static const streakGoal = WeeklyGoalPreset(
    id: 'weekly_streak',
    type: WeeklyGoalType.maintainStreak,
    nameEn: 'Streak Keeper',
    nameAr: 'حافظ السلسلة',
    descriptionEn: 'Maintain a {target} day study streak.',
    descriptionAr: 'حافظ على سلسلة دراسة {target} أيام.',
    easyTarget: 3,
    mediumTarget: 5,
    hardTarget: 7,
    extremeTarget: 14,
    baseXpReward: 120,
  );

  static const answersGoal = WeeklyGoalPreset(
    id: 'weekly_answers',
    type: WeeklyGoalType.correctAnswers,
    nameEn: 'Answer Machine',
    nameAr: 'آلة الإجابات',
    descriptionEn: 'Answer {target} questions correctly this week.',
    descriptionAr: 'أجب على {target} سؤال بشكل صحيح هذا الأسبوع.',
    easyTarget: 50,
    mediumTarget: 150,
    hardTarget: 300,
    extremeTarget: 500,
    baseXpReward: 90,
  );
}

/// User's weekly goals progress tracking
@immutable
class WeeklyGoalsProgress {
  const WeeklyGoalsProgress({
    required this.userId,
    required this.goals,
    required this.weekStart,
    required this.totalGoalsCompleted,
    required this.totalXpEarned,
  });

  final String userId;
  final List<WeeklyGoal> goals;
  final DateTime weekStart;
  final int totalGoalsCompleted;
  final int totalXpEarned;

  /// Number of active goals
  int get activeGoalsCount => goals.where((g) => g.isActive).length;

  /// Number of completed goals
  int get completedGoalsCount => goals.where((g) => g.isCompleted).length;

  /// Overall progress percentage
  double get overallProgress {
    if (goals.isEmpty) return 0.0;
    final totalProgress =
        goals.fold<double>(0, (sum, g) => sum + g.progressPercentage);
    return totalProgress / goals.length;
  }

  WeeklyGoalsProgress copyWith({
    String? userId,
    List<WeeklyGoal>? goals,
    DateTime? weekStart,
    int? totalGoalsCompleted,
    int? totalXpEarned,
  }) {
    return WeeklyGoalsProgress(
      userId: userId ?? this.userId,
      goals: goals ?? this.goals,
      weekStart: weekStart ?? this.weekStart,
      totalGoalsCompleted: totalGoalsCompleted ?? this.totalGoalsCompleted,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'goals': goals.map((g) => g.toJson()).toList(),
      'weekStart': weekStart.toIso8601String(),
      'totalGoalsCompleted': totalGoalsCompleted,
      'totalXpEarned': totalXpEarned,
    };
  }

  factory WeeklyGoalsProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalsProgress(
      userId: json['userId'] as String,
      goals: (json['goals'] as List)
          .map((g) => WeeklyGoal.fromJson(g as Map<String, dynamic>))
          .toList(),
      weekStart: DateTime.parse(json['weekStart'] as String),
      totalGoalsCompleted: json['totalGoalsCompleted'] as int? ?? 0,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
    );
  }

  factory WeeklyGoalsProgress.initial(String userId) {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - DateTime.monday;
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));

    return WeeklyGoalsProgress(
      userId: userId,
      goals: const [],
      weekStart: weekStart,
      totalGoalsCompleted: 0,
      totalXpEarned: 0,
    );
  }
}

/// Generator for weekly goals
class WeeklyGoalGenerator {
  WeeklyGoalGenerator._();

  /// Generate default goals for a new week
  static List<WeeklyGoal> generateDefaultGoals({
    GoalDifficulty difficulty = GoalDifficulty.medium,
    DateTime? weekStart,
  }) {
    final start = weekStart ?? _getWeekStart(DateTime.now());

    // Select 3 diverse goals
    return [
      WeeklyGoalPreset.xpGoal.createGoal(
        difficulty: difficulty,
        weekStart: start,
      ),
      WeeklyGoalPreset.quizzesGoal.createGoal(
        difficulty: difficulty,
        weekStart: start,
      ),
      WeeklyGoalPreset.studyDaysGoal.createGoal(
        difficulty: difficulty,
        weekStart: start,
      ),
    ];
  }

  /// Generate a random set of goals
  static List<WeeklyGoal> generateRandomGoals({
    int count = 3,
    GoalDifficulty difficulty = GoalDifficulty.medium,
    DateTime? weekStart,
  }) {
    final start = weekStart ?? _getWeekStart(DateTime.now());
    final presets = List<WeeklyGoalPreset>.from(WeeklyGoalPreset.allPresets)
      ..shuffle();

    return presets
        .take(count)
        .map((preset) => preset.createGoal(
              difficulty: difficulty,
              weekStart: start,
            ))
        .toList();
  }

  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }
}
