import 'package:flutter/foundation.dart';

/// Quiz entity
@immutable
class Quiz {
  const Quiz({
    required this.id,
    required this.mode,
    required this.difficulty,
    this.region,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answers = const [],
    required this.startedAt,
    this.completedAt,
  });

  final String id;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final String? region; // Filter by region (optional)
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<QuizAnswer> answers;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// Get current question
  QuizQuestion? get currentQuestion {
    if (currentQuestionIndex >= questions.length) return null;
    return questions[currentQuestionIndex];
  }

  /// Check if quiz is completed
  bool get isCompleted => currentQuestionIndex >= questions.length;

  /// Get score (correct answers count)
  int get score => answers.where((a) => a.isCorrect).length;

  /// Get total questions
  int get totalQuestions => questions.length;

  /// Get accuracy percentage
  double get accuracy {
    if (answers.isEmpty) return 0;
    return (score / answers.length) * 100;
  }

  /// Check if perfect score
  bool get isPerfectScore => score == totalQuestions;

  /// Get time elapsed
  Duration get timeElapsed {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  Quiz copyWith({
    String? id,
    QuizMode? mode,
    QuizDifficulty? difficulty,
    String? region,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<QuizAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      region: region ?? this.region,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Quiz question entity
@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.mode,
    required this.question,
    required this.questionArabic,
    required this.correctAnswer,
    required this.options,
    this.imageUrl,
    this.countryCode,
    this.metadata,
  });

  final String id;
  final QuizMode mode;
  final String question;
  final String questionArabic;
  final String correctAnswer;
  final List<String> options;
  final String? imageUrl; // For flag questions
  final String? countryCode; // For map questions
  final Map<String, dynamic>? metadata;

  /// Get display question based on locale
  String getDisplayQuestion({required bool isArabic}) {
    return isArabic ? questionArabic : question;
  }
}

/// Quiz answer entity
@immutable
class QuizAnswer {
  const QuizAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.timeTaken,
    required this.answeredAt,
  });

  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final Duration timeTaken;
  final DateTime answeredAt;

  /// Check if answer is correct
  bool get isCorrect => selectedAnswer == correctAnswer;
}

/// Quiz result entity
@immutable
class QuizResult {
  const QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.mode,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeTaken,
    required this.xpEarned,
    required this.completedAt,
    this.answers = const [],
  });

  final String id;
  final String quizId;
  final String userId;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final Duration timeTaken;
  final int xpEarned;
  final DateTime completedAt;
  final List<QuizAnswer> answers;

  /// Check if perfect score
  bool get isPerfectScore => score == totalQuestions;
}

/// Quiz modes
enum QuizMode {
  capitals,
  flags,
  maps,
  population,
  currencies,
  languages,
  mixed;

  String get displayName {
    switch (this) {
      case QuizMode.capitals:
        return 'Capitals';
      case QuizMode.flags:
        return 'Flags';
      case QuizMode.maps:
        return 'Maps';
      case QuizMode.population:
        return 'Population';
      case QuizMode.currencies:
        return 'Currencies';
      case QuizMode.languages:
        return 'Languages';
      case QuizMode.mixed:
        return 'Mixed';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case QuizMode.capitals:
        return 'العواصم';
      case QuizMode.flags:
        return 'الأعلام';
      case QuizMode.maps:
        return 'الخرائط';
      case QuizMode.population:
        return 'السكان';
      case QuizMode.currencies:
        return 'العملات';
      case QuizMode.languages:
        return 'اللغات';
      case QuizMode.mixed:
        return 'مختلط';
    }
  }
}

/// Quiz difficulty levels
enum QuizDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case QuizDifficulty.easy:
        return 'سهل';
      case QuizDifficulty.medium:
        return 'متوسط';
      case QuizDifficulty.hard:
        return 'صعب';
    }
  }

  /// Get number of options for this difficulty
  int get optionsCount {
    switch (this) {
      case QuizDifficulty.easy:
        return 3;
      case QuizDifficulty.medium:
        return 4;
      case QuizDifficulty.hard:
        return 5;
    }
  }

  /// Get time limit per question in seconds
  int get timeLimitSeconds {
    switch (this) {
      case QuizDifficulty.easy:
        return 20;
      case QuizDifficulty.medium:
        return 15;
      case QuizDifficulty.hard:
        return 10;
    }
  }

  /// Get XP multiplier
  double get xpMultiplier {
    switch (this) {
      case QuizDifficulty.easy:
        return 1.0;
      case QuizDifficulty.medium:
        return 1.25;
      case QuizDifficulty.hard:
        return 1.5;
    }
  }
}
