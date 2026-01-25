import 'package:flutter/material.dart';

/// Detailed user statistics for the stats dashboard
@immutable
class UserStats {
  const UserStats({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.totalQuizzes,
    required this.perfectScores,
    required this.averageScore,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.totalStudyTime,
    required this.currentStreak,
    required this.longestStreak,
    required this.countriesPerContinent,
    required this.accuracyPerContinent,
    required this.accuracyPerQuizType,
    required this.activityHistory,
    required this.weakAreas,
    required this.strongAreas,
    this.lastUpdated,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      totalQuizzes: json['totalQuizzes'] as int? ?? 0,
      perfectScores: json['perfectScores'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      totalStudyTime:
          Duration(minutes: json['totalStudyTime'] as int? ?? 0),
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      countriesPerContinent: (json['countriesPerContinent'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      accuracyPerContinent: (json['accuracyPerContinent'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ) ??
          {},
      accuracyPerQuizType: (json['accuracyPerQuizType'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ) ??
          {},
      activityHistory: (json['activityHistory'] as List?)
              ?.map((a) => DailyActivity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      weakAreas: (json['weakAreas'] as List?)
              ?.map((w) => WeakArea.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      strongAreas: (json['strongAreas'] as List?)
              ?.map((s) => StrongArea.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  factory UserStats.initial(String userId) {
    return UserStats(
      userId: userId,
      totalXp: 0,
      level: 1,
      totalQuizzes: 0,
      perfectScores: 0,
      averageScore: 0,
      totalQuestions: 0,
      correctAnswers: 0,
      accuracy: 0,
      totalStudyTime: Duration.zero,
      currentStreak: 0,
      longestStreak: 0,
      countriesPerContinent: const {},
      accuracyPerContinent: const {},
      accuracyPerQuizType: const {},
      activityHistory: const [],
      weakAreas: const [],
      strongAreas: const [],
    );
  }

  final String userId;
  final int totalXp;
  final int level;
  final int totalQuizzes;
  final int perfectScores;
  final double averageScore;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final Duration totalStudyTime;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> countriesPerContinent;
  final Map<String, double> accuracyPerContinent;
  final Map<String, double> accuracyPerQuizType;
  final List<DailyActivity> activityHistory;
  final List<WeakArea> weakAreas;
  final List<StrongArea> strongAreas;
  final DateTime? lastUpdated;

  /// Total countries learned across all continents
  int get totalCountriesLearned =>
      countriesPerContinent.values.fold(0, (sum, count) => sum + count);

  /// Perfect score rate
  double get perfectScoreRate {
    if (totalQuizzes == 0) return 0;
    return perfectScores / totalQuizzes;
  }

  /// Average study time per day
  Duration get averageStudyTimePerDay {
    if (activityHistory.isEmpty) return Duration.zero;
    final totalMinutes = activityHistory.fold<int>(
      0,
      (sum, activity) => sum + activity.studyTime.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ activityHistory.length);
  }

  /// Total days active
  int get totalDaysActive =>
      activityHistory.where((a) => a.xpEarned > 0).length;

  UserStats copyWith({
    String? userId,
    int? totalXp,
    int? level,
    int? totalQuizzes,
    int? perfectScores,
    double? averageScore,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
    Duration? totalStudyTime,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? countriesPerContinent,
    Map<String, double>? accuracyPerContinent,
    Map<String, double>? accuracyPerQuizType,
    List<DailyActivity>? activityHistory,
    List<WeakArea>? weakAreas,
    List<StrongArea>? strongAreas,
    DateTime? lastUpdated,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      perfectScores: perfectScores ?? this.perfectScores,
      averageScore: averageScore ?? this.averageScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      countriesPerContinent:
          countriesPerContinent ?? this.countriesPerContinent,
      accuracyPerContinent: accuracyPerContinent ?? this.accuracyPerContinent,
      accuracyPerQuizType: accuracyPerQuizType ?? this.accuracyPerQuizType,
      activityHistory: activityHistory ?? this.activityHistory,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalXp': totalXp,
      'level': level,
      'totalQuizzes': totalQuizzes,
      'perfectScores': perfectScores,
      'averageScore': averageScore,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'totalStudyTime': totalStudyTime.inMinutes,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'countriesPerContinent': countriesPerContinent,
      'accuracyPerContinent': accuracyPerContinent,
      'accuracyPerQuizType': accuracyPerQuizType,
      'activityHistory': activityHistory.map((a) => a.toJson()).toList(),
      'weakAreas': weakAreas.map((w) => w.toJson()).toList(),
      'strongAreas': strongAreas.map((s) => s.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

/// Daily activity record for activity heatmap
@immutable
class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.xpEarned,
    required this.quizzesCompleted,
    required this.questionsAnswered,
    required this.studyTime,
    this.correctAnswers = 0,
    this.perfectScores = 0,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: DateTime.parse(json['date'] as String),
      xpEarned: json['xpEarned'] as int? ?? 0,
      quizzesCompleted: json['quizzesCompleted'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      studyTime: Duration(minutes: json['studyTime'] as int? ?? 0),
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      perfectScores: json['perfectScores'] as int? ?? 0,
    );
  }

  final DateTime date;
  final int xpEarned;
  final int quizzesCompleted;
  final int questionsAnswered;
  final Duration studyTime;
  final int correctAnswers;
  final int perfectScores;

  /// Activity intensity level (0-4) for heatmap coloring
  int get intensityLevel {
    if (xpEarned == 0) return 0;
    if (xpEarned < 50) return 1;
    if (xpEarned < 150) return 2;
    if (xpEarned < 300) return 3;
    return 4;
  }

  /// Accuracy for this day
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return correctAnswers / questionsAnswered;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'xpEarned': xpEarned,
      'quizzesCompleted': quizzesCompleted,
      'questionsAnswered': questionsAnswered,
      'studyTime': studyTime.inMinutes,
      'correctAnswers': correctAnswers,
      'perfectScores': perfectScores,
    };
  }
}

/// Weak area identification for improvement suggestions
@immutable
class WeakArea {
  const WeakArea({
    required this.areaType,
    required this.areaId,
    required this.nameEn,
    required this.nameAr,
    required this.accuracy,
    required this.questionsAttempted,
    required this.recommendationEn,
    required this.recommendationAr,
  });

  factory WeakArea.fromJson(Map<String, dynamic> json) {
    return WeakArea(
      areaType: json['areaType'] as String,
      areaId: json['areaId'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      questionsAttempted: json['questionsAttempted'] as int? ?? 0,
      recommendationEn: json['recommendationEn'] as String,
      recommendationAr: json['recommendationAr'] as String,
    );
  }

  /// Type of weak area (continent, quiz_type, country_set)
  final String areaType;

  /// Identifier (e.g., 'africa', 'flags', 'capitals')
  final String areaId;

  /// English name
  final String nameEn;

  /// Arabic name
  final String nameAr;

  /// Current accuracy in this area
  final double accuracy;

  /// Number of questions attempted
  final int questionsAttempted;

  /// English recommendation text
  final String recommendationEn;

  /// Arabic recommendation text
  final String recommendationAr;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;
  String getRecommendation(bool isArabic) =>
      isArabic ? recommendationAr : recommendationEn;

  /// Severity level (higher = weaker)
  int get severityLevel {
    if (accuracy > 0.7) return 1;
    if (accuracy > 0.5) return 2;
    if (accuracy > 0.3) return 3;
    return 4;
  }

  Map<String, dynamic> toJson() {
    return {
      'areaType': areaType,
      'areaId': areaId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'accuracy': accuracy,
      'questionsAttempted': questionsAttempted,
      'recommendationEn': recommendationEn,
      'recommendationAr': recommendationAr,
    };
  }
}

/// Strong area for highlighting achievements
@immutable
class StrongArea {
  const StrongArea({
    required this.areaType,
    required this.areaId,
    required this.nameEn,
    required this.nameAr,
    required this.accuracy,
    required this.questionsAttempted,
  });

  factory StrongArea.fromJson(Map<String, dynamic> json) {
    return StrongArea(
      areaType: json['areaType'] as String,
      areaId: json['areaId'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      questionsAttempted: json['questionsAttempted'] as int? ?? 0,
    );
  }

  final String areaType;
  final String areaId;
  final String nameEn;
  final String nameAr;
  final double accuracy;
  final int questionsAttempted;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;

  Map<String, dynamic> toJson() {
    return {
      'areaType': areaType,
      'areaId': areaId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'accuracy': accuracy,
      'questionsAttempted': questionsAttempted,
    };
  }
}

/// Stats summary for compact display
@immutable
class StatsSummary {
  const StatsSummary({
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.accuracy,
    required this.countriesLearned,
    required this.quizzesCompleted,
  });

  factory StatsSummary.fromUserStats(UserStats stats) {
    return StatsSummary(
      totalXp: stats.totalXp,
      level: stats.level,
      currentStreak: stats.currentStreak,
      accuracy: stats.accuracy,
      countriesLearned: stats.totalCountriesLearned,
      quizzesCompleted: stats.totalQuizzes,
    );
  }

  final int totalXp;
  final int level;
  final int currentStreak;
  final double accuracy;
  final int countriesLearned;
  final int quizzesCompleted;
}
