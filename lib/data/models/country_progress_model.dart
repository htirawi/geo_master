import '../../domain/entities/country_progress.dart';

/// Country progress data model with JSON serialization
class CountryProgressModel {
  const CountryProgressModel({
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

  factory CountryProgressModel.fromJson(Map<String, dynamic> json) {
    return CountryProgressModel(
      countryCode: json['countryCode'] as String? ?? '',
      exploredAt: json['exploredAt'] != null
          ? DateTime.tryParse(json['exploredAt'] as String)
          : null,
      lastVisitedAt: json['lastVisitedAt'] != null
          ? DateTime.tryParse(json['lastVisitedAt'] as String)
          : null,
      visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      quizzesTaken: (json['quizzesTaken'] as num?)?.toInt() ?? 0,
      quizzesPassed: (json['quizzesPassed'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalAnswers: (json['totalAnswers'] as num?)?.toInt() ?? 0,
      bookmarkedFacts: (json['bookmarkedFacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedModules: (json['completedModules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      flashcardsReviewed: (json['flashcardsReviewed'] as num?)?.toInt() ?? 0,
      flashcardsMastered: (json['flashcardsMastered'] as num?)?.toInt() ?? 0,
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Create model from entity
  factory CountryProgressModel.fromEntity(CountryProgress entity) {
    return CountryProgressModel(
      countryCode: entity.countryCode,
      exploredAt: entity.exploredAt,
      lastVisitedAt: entity.lastVisitedAt,
      visitCount: entity.visitCount,
      xpEarned: entity.xpEarned,
      quizzesTaken: entity.quizzesTaken,
      quizzesPassed: entity.quizzesPassed,
      correctAnswers: entity.correctAnswers,
      totalAnswers: entity.totalAnswers,
      bookmarkedFacts: entity.bookmarkedFacts,
      completedModules: entity.completedModules,
      flashcardsReviewed: entity.flashcardsReviewed,
      flashcardsMastered: entity.flashcardsMastered,
      timeSpentSeconds: entity.timeSpentSeconds,
      isFavorite: entity.isFavorite,
      notes: entity.notes,
    );
  }

  final String countryCode;
  final DateTime? exploredAt;
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

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'exploredAt': exploredAt?.toIso8601String(),
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
      'visitCount': visitCount,
      'xpEarned': xpEarned,
      'quizzesTaken': quizzesTaken,
      'quizzesPassed': quizzesPassed,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'bookmarkedFacts': bookmarkedFacts,
      'completedModules': completedModules,
      'flashcardsReviewed': flashcardsReviewed,
      'flashcardsMastered': flashcardsMastered,
      'timeSpentSeconds': timeSpentSeconds,
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }

  /// Convert to domain entity
  CountryProgress toEntity() {
    return CountryProgress(
      countryCode: countryCode,
      exploredAt: exploredAt,
      lastVisitedAt: lastVisitedAt,
      visitCount: visitCount,
      xpEarned: xpEarned,
      quizzesTaken: quizzesTaken,
      quizzesPassed: quizzesPassed,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
      bookmarkedFacts: bookmarkedFacts,
      completedModules: completedModules,
      flashcardsReviewed: flashcardsReviewed,
      flashcardsMastered: flashcardsMastered,
      timeSpentSeconds: timeSpentSeconds,
      isFavorite: isFavorite,
      notes: notes,
    );
  }
}
