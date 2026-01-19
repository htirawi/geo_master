import 'package:flutter/foundation.dart';

/// Per-country learning progress tracking
@immutable
class CountryProgress {
  const CountryProgress({
    required this.countryCode,
    this.exploredAt,
    this.lastVisitedAt,
    this.visitCount = 0,
    this.xpEarned = 0,
    this.quizzesTaken = 0,
    this.quizzesPassed = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.bookmarkedFacts = const [],
    this.completedModules = const [],
    this.flashcardsReviewed = 0,
    this.flashcardsMastered = 0,
    this.timeSpentSeconds = 0,
    this.isFavorite = false,
    this.notes,
  });

  final String countryCode;
  final DateTime? exploredAt; // First time country was viewed
  final DateTime? lastVisitedAt;
  final int visitCount;
  final int xpEarned;
  final int quizzesTaken;
  final int quizzesPassed;
  final int correctAnswers;
  final int totalAnswers;
  final List<String> bookmarkedFacts;
  final List<String> completedModules;
  final int flashcardsReviewed;
  final int flashcardsMastered;
  final int timeSpentSeconds;
  final bool isFavorite;
  final String? notes;

  /// Calculate quiz accuracy percentage
  double get quizAccuracy {
    if (totalAnswers == 0) return 0;
    return (correctAnswers / totalAnswers) * 100;
  }

  /// Calculate overall completion percentage (0-100)
  double get completionPercentage {
    // Weights for different activities
    const quizWeight = 0.4;
    const moduleWeight = 0.3;
    const flashcardWeight = 0.2;
    const visitWeight = 0.1;

    // Quiz progress (passing at least 3 quizzes = 100%)
    final quizProgress = (quizzesPassed / 3).clamp(0.0, 1.0);

    // Module progress (completing all 5 modules = 100%)
    final moduleProgress = (completedModules.length / 5).clamp(0.0, 1.0);

    // Flashcard progress (mastering 20 flashcards = 100%)
    final flashcardProgress = (flashcardsMastered / 20).clamp(0.0, 1.0);

    // Visit progress (visiting 5+ times = 100%)
    final visitProgress = (visitCount / 5).clamp(0.0, 1.0);

    return ((quizProgress * quizWeight) +
            (moduleProgress * moduleWeight) +
            (flashcardProgress * flashcardWeight) +
            (visitProgress * visitWeight)) *
        100;
  }

  /// Get progress level based on completion percentage
  ProgressLevel get progressLevel {
    final percentage = completionPercentage;
    if (percentage >= 100) return ProgressLevel.mastered;
    if (percentage >= 75) return ProgressLevel.advanced;
    if (percentage >= 50) return ProgressLevel.intermediate;
    if (percentage >= 25) return ProgressLevel.beginner;
    if (percentage > 0) return ProgressLevel.started;
    return ProgressLevel.notStarted;
  }

  /// Format time spent as readable string
  String get formattedTimeSpent {
    final hours = timeSpentSeconds ~/ 3600;
    final minutes = (timeSpentSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if country is explored (visited at least once)
  bool get isExplored => exploredAt != null;

  /// Check if country is completed (100% progress)
  bool get isCompleted => completionPercentage >= 100;

  CountryProgress copyWith({
    String? countryCode,
    DateTime? exploredAt,
    DateTime? lastVisitedAt,
    int? visitCount,
    int? xpEarned,
    int? quizzesTaken,
    int? quizzesPassed,
    int? correctAnswers,
    int? totalAnswers,
    List<String>? bookmarkedFacts,
    List<String>? completedModules,
    int? flashcardsReviewed,
    int? flashcardsMastered,
    int? timeSpentSeconds,
    bool? isFavorite,
    String? notes,
  }) {
    return CountryProgress(
      countryCode: countryCode ?? this.countryCode,
      exploredAt: exploredAt ?? this.exploredAt,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      visitCount: visitCount ?? this.visitCount,
      xpEarned: xpEarned ?? this.xpEarned,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      quizzesPassed: quizzesPassed ?? this.quizzesPassed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      bookmarkedFacts: bookmarkedFacts ?? this.bookmarkedFacts,
      completedModules: completedModules ?? this.completedModules,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      flashcardsMastered: flashcardsMastered ?? this.flashcardsMastered,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryProgress && other.countryCode == countryCode;
  }

  @override
  int get hashCode => countryCode.hashCode;
}

/// Progress level enum
enum ProgressLevel {
  notStarted,
  started,
  beginner,
  intermediate,
  advanced,
  mastered;

  String get displayName {
    switch (this) {
      case ProgressLevel.notStarted:
        return 'Not Started';
      case ProgressLevel.started:
        return 'Started';
      case ProgressLevel.beginner:
        return 'Beginner';
      case ProgressLevel.intermediate:
        return 'Intermediate';
      case ProgressLevel.advanced:
        return 'Advanced';
      case ProgressLevel.mastered:
        return 'Mastered';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case ProgressLevel.notStarted:
        return 'لم يبدأ';
      case ProgressLevel.started:
        return 'بدأ';
      case ProgressLevel.beginner:
        return 'مبتدئ';
      case ProgressLevel.intermediate:
        return 'متوسط';
      case ProgressLevel.advanced:
        return 'متقدم';
      case ProgressLevel.mastered:
        return 'متقن';
    }
  }

  /// Get color hex for this level
  int get colorValue {
    switch (this) {
      case ProgressLevel.notStarted:
        return 0xFF9E9E9E; // Gray
      case ProgressLevel.started:
        return 0xFFFF9800; // Orange
      case ProgressLevel.beginner:
        return 0xFFFFC107; // Yellow
      case ProgressLevel.intermediate:
        return 0xFF8BC34A; // Light Green
      case ProgressLevel.advanced:
        return 0xFF4CAF50; // Green
      case ProgressLevel.mastered:
        return 0xFF2E7D32; // Dark Green
    }
  }

  /// Get progress value as decimal (0.0 to 1.0)
  double get progressValue {
    switch (this) {
      case ProgressLevel.notStarted:
        return 0.0;
      case ProgressLevel.started:
        return 0.125;
      case ProgressLevel.beginner:
        return 0.375;
      case ProgressLevel.intermediate:
        return 0.625;
      case ProgressLevel.advanced:
        return 0.875;
      case ProgressLevel.mastered:
        return 1.0;
    }
  }
}
