import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// User entity
@immutable
class User {
  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.isEmailVerified = false,
    this.isPremium = false,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences = const UserPreferences(),
    this.progress = const UserProgress(),
  });

  /// Create a guest user
  factory User.guest() {
    return User(
      id: 'guest',
      isAnonymous: true,
      createdAt: DateTime.now(),
    );
  }

  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isEmailVerified;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserPreferences preferences;
  final UserProgress progress;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    bool? isEmailVerified,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    UserProgress? progress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User preferences
@immutable
class UserPreferences {
  const UserPreferences({
    this.language = 'en',
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.dailyGoalMinutes = 15,
    this.difficultyLevel = 'medium',
    this.interests = const [],
  });

  final String language;
  final bool isDarkMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final int dailyGoalMinutes;
  final String difficultyLevel;
  final List<String> interests;

  UserPreferences copyWith({
    String? language,
    bool? isDarkMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    int? dailyGoalMinutes,
    String? difficultyLevel,
    List<String>? interests,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      interests: interests ?? this.interests,
    );
  }
}

/// User progress tracking
@immutable
class UserProgress {
  const UserProgress({
    this.totalXp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.countriesLearned = 0,
    this.quizzesCompleted = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.unlockedAchievements = const [],
    this.regionProgress = const {},
  });

  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int countriesLearned;
  final int quizzesCompleted;
  final int questionsAnswered;
  final int correctAnswers;
  final List<String> unlockedAchievements;
  final Map<String, int> regionProgress;

  /// Calculate accuracy percentage
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }

  /// Calculate XP needed for next level
  /// Formula: 100 * (1.2 ^ level) - exponential scaling
  int get xpForNextLevel {
    return (100 * math.pow(1.2, level)).round();
  }

  /// Calculate current level progress percentage
  double get levelProgress {
    final xpInCurrentLevel = totalXp - _xpForLevel(level);
    final xpNeeded = xpForNextLevel;
    return (xpInCurrentLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Calculate total XP required to reach a specific level
  int _xpForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += (100 * math.pow(1.2, i)).round();
    }
    return total;
  }

  UserProgress copyWith({
    int? totalXp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    int? countriesLearned,
    int? quizzesCompleted,
    int? questionsAnswered,
    int? correctAnswers,
    List<String>? unlockedAchievements,
    Map<String, int>? regionProgress,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      countriesLearned: countriesLearned ?? this.countriesLearned,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      regionProgress: regionProgress ?? this.regionProgress,
    );
  }
}
