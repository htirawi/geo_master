import '../../domain/entities/user.dart';

/// User data model for Firestore
class UserModel {
  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    required this.isEmailVerified,
    required this.isPremium,
    required this.createdAt,
    this.lastLoginAt,
    required this.preferences,
    required this.progress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      preferences: json['preferences'] != null
          ? UserPreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : const UserPreferencesModel(),
      progress: json['progress'] != null
          ? UserProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : const UserProgressModel(),
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      isAnonymous: entity.isAnonymous,
      isEmailVerified: entity.isEmailVerified,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      preferences: UserPreferencesModel.fromEntity(entity.preferences),
      progress: UserProgressModel.fromEntity(entity.progress),
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
  final UserPreferencesModel preferences;
  final UserProgressModel progress;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences.toJson(),
      'progress': progress.toJson(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
      isEmailVerified: isEmailVerified,
      isPremium: isPremium,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      preferences: preferences.toEntity(),
      progress: progress.toEntity(),
    );
  }
}

/// User preferences data model
class UserPreferencesModel {
  const UserPreferencesModel({
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

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      language: json['language'] as String? ?? 'en',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 15,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'medium',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      language: entity.language,
      isDarkMode: entity.isDarkMode,
      soundEnabled: entity.soundEnabled,
      hapticsEnabled: entity.hapticsEnabled,
      notificationsEnabled: entity.notificationsEnabled,
      dailyReminderEnabled: entity.dailyReminderEnabled,
      dailyGoalMinutes: entity.dailyGoalMinutes,
      difficultyLevel: entity.difficultyLevel,
      interests: entity.interests,
    );
  }

  final String language;
  final bool isDarkMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final int dailyGoalMinutes;
  final String difficultyLevel;
  final List<String> interests;

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isDarkMode': isDarkMode,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyGoalMinutes': dailyGoalMinutes,
      'difficultyLevel': difficultyLevel,
      'interests': interests,
    };
  }

  UserPreferences toEntity() {
    return UserPreferences(
      language: language,
      isDarkMode: isDarkMode,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      notificationsEnabled: notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled,
      dailyGoalMinutes: dailyGoalMinutes,
      difficultyLevel: difficultyLevel,
      interests: interests,
    );
  }
}

/// User progress data model
class UserProgressModel {
  const UserProgressModel({
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

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      countriesLearned: json['countriesLearned'] as int? ?? 0,
      quizzesCompleted: json['quizzesCompleted'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      regionProgress:
          (json['regionProgress'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
              ) ??
              {},
    );
  }

  factory UserProgressModel.fromEntity(UserProgress entity) {
    return UserProgressModel(
      totalXp: entity.totalXp,
      level: entity.level,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      lastActiveDate: entity.lastActiveDate,
      countriesLearned: entity.countriesLearned,
      quizzesCompleted: entity.quizzesCompleted,
      questionsAnswered: entity.questionsAnswered,
      correctAnswers: entity.correctAnswers,
      unlockedAchievements: entity.unlockedAchievements,
      regionProgress: entity.regionProgress,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'countriesLearned': countriesLearned,
      'quizzesCompleted': quizzesCompleted,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'unlockedAchievements': unlockedAchievements,
      'regionProgress': regionProgress,
    };
  }

  UserProgress toEntity() {
    return UserProgress(
      totalXp: totalXp,
      level: level,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: lastActiveDate,
      countriesLearned: countriesLearned,
      quizzesCompleted: quizzesCompleted,
      questionsAnswered: questionsAnswered,
      correctAnswers: correctAnswers,
      unlockedAchievements: unlockedAchievements,
      regionProgress: regionProgress,
    );
  }
}
