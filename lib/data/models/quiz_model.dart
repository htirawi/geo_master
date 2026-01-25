import '../../domain/entities/quiz.dart';

/// Quiz data model for Firestore/local storage
class QuizModel {
  const QuizModel({
    required this.id,
    required this.mode,
    required this.difficulty,
    this.sessionType = QuizSessionType.standard,
    this.region,
    this.continent,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.startedAt,
    this.completedAt,
    this.livesRemaining,
    this.hintsUsed = 0,
    this.speedBonusMultiplier = 1.0,
    this.streakAtStart = 0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String? ?? '',
      mode: QuizMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizMode.mixed,
      ),
      difficulty: QuizDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      sessionType: QuizSessionType.values.firstWhere(
        (s) => s.name == json['sessionType'],
        orElse: () => QuizSessionType.standard,
      ),
      region: json['region'] as String?,
      continent: json['continent'] as String?,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) =>
                  QuizQuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => QuizAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      livesRemaining: json['livesRemaining'] as int?,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      speedBonusMultiplier: (json['speedBonusMultiplier'] as num?)?.toDouble() ?? 1.0,
      streakAtStart: json['streakAtStart'] as int? ?? 0,
    );
  }

  factory QuizModel.fromEntity(Quiz entity) {
    return QuizModel(
      id: entity.id,
      mode: entity.mode,
      difficulty: entity.difficulty,
      sessionType: entity.sessionType,
      region: entity.region,
      continent: entity.continent,
      questions:
          entity.questions.map(QuizQuestionModel.fromEntity).toList(),
      currentQuestionIndex: entity.currentQuestionIndex,
      answers:
          entity.answers.map(QuizAnswerModel.fromEntity).toList(),
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      livesRemaining: entity.livesRemaining,
      hintsUsed: entity.hintsUsed,
      speedBonusMultiplier: entity.speedBonusMultiplier,
      streakAtStart: entity.streakAtStart,
    );
  }

  final String id;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final QuizSessionType sessionType;
  final String? region;
  final String? continent;
  final List<QuizQuestionModel> questions;
  final int currentQuestionIndex;
  final List<QuizAnswerModel> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? livesRemaining;
  final int hintsUsed;
  final double speedBonusMultiplier;
  final int streakAtStart;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'difficulty': difficulty.name,
      'sessionType': sessionType.name,
      'region': region,
      'continent': continent,
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'answers': answers.map((a) => a.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'livesRemaining': livesRemaining,
      'hintsUsed': hintsUsed,
      'speedBonusMultiplier': speedBonusMultiplier,
      'streakAtStart': streakAtStart,
    };
  }

  Quiz toEntity() {
    return Quiz(
      id: id,
      mode: mode,
      difficulty: difficulty,
      sessionType: sessionType,
      region: region,
      continent: continent,
      questions: questions.map((q) => q.toEntity()).toList(),
      currentQuestionIndex: currentQuestionIndex,
      answers: answers.map((a) => a.toEntity()).toList(),
      startedAt: startedAt,
      completedAt: completedAt,
      livesRemaining: livesRemaining,
      hintsUsed: hintsUsed,
      speedBonusMultiplier: speedBonusMultiplier,
      streakAtStart: streakAtStart,
    );
  }
}

/// Quiz question data model
class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.mode,
    required this.question,
    required this.questionArabic,
    required this.correctAnswer,
    required this.options,
    this.correctAnswerArabic,
    this.optionsArabic,
    this.questionType = QuestionType.multipleChoice,
    this.imageUrl,
    this.countryCode,
    this.metadata,
    this.hint,
    this.hintArabic,
    this.explanation,
    this.explanationArabic,
    this.correctAnswers,
    this.correctAnswersArabic,
    this.matchingPairs,
    this.funFact,
    this.funFactArabic,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      mode: QuizMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizMode.mixed,
      ),
      questionType: QuestionType.values.firstWhere(
        (t) => t.name == json['questionType'],
        orElse: () => QuestionType.multipleChoice,
      ),
      question: json['question'] as String? ?? '',
      questionArabic: json['questionArabic'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      correctAnswerArabic: json['correctAnswerArabic'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      optionsArabic: (json['optionsArabic'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      countryCode: json['countryCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      hint: json['hint'] as String?,
      hintArabic: json['hintArabic'] as String?,
      explanation: json['explanation'] as String?,
      explanationArabic: json['explanationArabic'] as String?,
      correctAnswers: (json['correctAnswers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      correctAnswersArabic: (json['correctAnswersArabic'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      matchingPairs: (json['matchingPairs'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      funFact: json['funFact'] as String?,
      funFactArabic: json['funFactArabic'] as String?,
    );
  }

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      mode: entity.mode,
      questionType: entity.questionType,
      question: entity.question,
      questionArabic: entity.questionArabic,
      correctAnswer: entity.correctAnswer,
      correctAnswerArabic: entity.correctAnswerArabic,
      options: entity.options,
      optionsArabic: entity.optionsArabic,
      imageUrl: entity.imageUrl,
      countryCode: entity.countryCode,
      metadata: entity.metadata,
      hint: entity.hint,
      hintArabic: entity.hintArabic,
      explanation: entity.explanation,
      explanationArabic: entity.explanationArabic,
      correctAnswers: entity.correctAnswers,
      correctAnswersArabic: entity.correctAnswersArabic,
      matchingPairs: entity.matchingPairs,
      funFact: entity.funFact,
      funFactArabic: entity.funFactArabic,
    );
  }

  final String id;
  final QuizMode mode;
  final QuestionType questionType;
  final String question;
  final String questionArabic;
  final String correctAnswer;
  final String? correctAnswerArabic;
  final List<String> options;
  final List<String>? optionsArabic;
  final String? imageUrl;
  final String? countryCode;
  final Map<String, dynamic>? metadata;
  final String? hint;
  final String? hintArabic;
  final String? explanation;
  final String? explanationArabic;
  final List<String>? correctAnswers;
  final List<String>? correctAnswersArabic;
  final Map<String, String>? matchingPairs;
  final String? funFact;
  final String? funFactArabic;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'questionType': questionType.name,
      'question': question,
      'questionArabic': questionArabic,
      'correctAnswer': correctAnswer,
      'correctAnswerArabic': correctAnswerArabic,
      'options': options,
      'optionsArabic': optionsArabic,
      'imageUrl': imageUrl,
      'countryCode': countryCode,
      'metadata': metadata,
      'hint': hint,
      'hintArabic': hintArabic,
      'explanation': explanation,
      'explanationArabic': explanationArabic,
      'correctAnswers': correctAnswers,
      'correctAnswersArabic': correctAnswersArabic,
      'matchingPairs': matchingPairs,
      'funFact': funFact,
      'funFactArabic': funFactArabic,
    };
  }

  QuizQuestion toEntity() {
    return QuizQuestion(
      id: id,
      mode: mode,
      questionType: questionType,
      question: question,
      questionArabic: questionArabic,
      correctAnswer: correctAnswer,
      correctAnswerArabic: correctAnswerArabic,
      options: options,
      optionsArabic: optionsArabic,
      imageUrl: imageUrl,
      countryCode: countryCode,
      metadata: metadata,
      hint: hint,
      hintArabic: hintArabic,
      explanation: explanation,
      explanationArabic: explanationArabic,
      correctAnswers: correctAnswers,
      correctAnswersArabic: correctAnswersArabic,
      matchingPairs: matchingPairs,
      funFact: funFact,
      funFactArabic: funFactArabic,
    );
  }
}

/// Quiz answer data model
class QuizAnswerModel {
  const QuizAnswerModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.timeTakenMs,
    required this.answeredAt,
    this.selectedAnswers,
    this.correctAnswers,
    this.usedHint = false,
    this.speedBonus = 1.0,
    this.xpEarned = 0,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      questionId: json['questionId'] as String? ?? '',
      selectedAnswer: json['selectedAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      timeTakenMs: json['timeTakenMs'] as int? ?? 0,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : DateTime.now(),
      selectedAnswers: (json['selectedAnswers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      correctAnswers: (json['correctAnswers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      usedHint: json['usedHint'] as bool? ?? false,
      speedBonus: (json['speedBonus'] as num?)?.toDouble() ?? 1.0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }

  factory QuizAnswerModel.fromEntity(QuizAnswer entity) {
    return QuizAnswerModel(
      questionId: entity.questionId,
      selectedAnswer: entity.selectedAnswer,
      correctAnswer: entity.correctAnswer,
      timeTakenMs: entity.timeTaken.inMilliseconds,
      answeredAt: entity.answeredAt,
      selectedAnswers: entity.selectedAnswers,
      correctAnswers: entity.correctAnswers,
      usedHint: entity.usedHint,
      speedBonus: entity.speedBonus,
      xpEarned: entity.xpEarned,
    );
  }

  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final int timeTakenMs;
  final DateTime answeredAt;
  final List<String>? selectedAnswers;
  final List<String>? correctAnswers;
  final bool usedHint;
  final double speedBonus;
  final int xpEarned;

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'timeTakenMs': timeTakenMs,
      'answeredAt': answeredAt.toIso8601String(),
      'selectedAnswers': selectedAnswers,
      'correctAnswers': correctAnswers,
      'usedHint': usedHint,
      'speedBonus': speedBonus,
      'xpEarned': xpEarned,
    };
  }

  QuizAnswer toEntity() {
    return QuizAnswer(
      questionId: questionId,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
      timeTaken: Duration(milliseconds: timeTakenMs),
      answeredAt: answeredAt,
      selectedAnswers: selectedAnswers,
      correctAnswers: correctAnswers,
      usedHint: usedHint,
      speedBonus: speedBonus,
      xpEarned: xpEarned,
    );
  }
}

/// Quiz result data model for Firestore
class QuizResultModel {
  const QuizResultModel({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.mode,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeTakenMs,
    required this.xpEarned,
    required this.completedAt,
    this.answers = const [],
    this.sessionType = QuizSessionType.standard,
    this.continent,
    this.hintsUsed = 0,
    this.streakBonus = 1.0,
    this.speedBonus = 1.0,
    this.averageTimePerQuestionMs = 0,
    this.perfectStreak = 0,
    this.weakAreas = const [],
    this.strongAreas = const [],
    this.newAchievements = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      mode: QuizMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizMode.mixed,
      ),
      difficulty: QuizDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      sessionType: QuizSessionType.values.firstWhere(
        (s) => s.name == json['sessionType'],
        orElse: () => QuizSessionType.standard,
      ),
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenMs: json['timeTakenMs'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : DateTime.now(),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => QuizAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      continent: json['continent'] as String?,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      streakBonus: (json['streakBonus'] as num?)?.toDouble() ?? 1.0,
      speedBonus: (json['speedBonus'] as num?)?.toDouble() ?? 1.0,
      averageTimePerQuestionMs: json['averageTimePerQuestionMs'] as int? ?? 0,
      perfectStreak: json['perfectStreak'] as int? ?? 0,
      weakAreas: (json['weakAreas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      strongAreas: (json['strongAreas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      newAchievements: (json['newAchievements'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  factory QuizResultModel.fromEntity(QuizResult entity) {
    return QuizResultModel(
      id: entity.id,
      quizId: entity.quizId,
      userId: entity.userId,
      mode: entity.mode,
      difficulty: entity.difficulty,
      sessionType: entity.sessionType,
      score: entity.score,
      totalQuestions: entity.totalQuestions,
      accuracy: entity.accuracy,
      timeTakenMs: entity.timeTaken.inMilliseconds,
      xpEarned: entity.xpEarned,
      completedAt: entity.completedAt,
      answers: entity.answers.map(QuizAnswerModel.fromEntity).toList(),
      continent: entity.continent,
      hintsUsed: entity.hintsUsed,
      streakBonus: entity.streakBonus,
      speedBonus: entity.speedBonus,
      averageTimePerQuestionMs: entity.averageTimePerQuestion.inMilliseconds,
      perfectStreak: entity.perfectStreak,
      weakAreas: entity.weakAreas,
      strongAreas: entity.strongAreas,
      newAchievements: entity.newAchievements,
    );
  }

  final String id;
  final String quizId;
  final String userId;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final QuizSessionType sessionType;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeTakenMs;
  final int xpEarned;
  final DateTime completedAt;
  final List<QuizAnswerModel> answers;
  final String? continent;
  final int hintsUsed;
  final double streakBonus;
  final double speedBonus;
  final int averageTimePerQuestionMs;
  final int perfectStreak;
  final List<String> weakAreas;
  final List<String> strongAreas;
  final List<String> newAchievements;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'mode': mode.name,
      'difficulty': difficulty.name,
      'sessionType': sessionType.name,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'timeTakenMs': timeTakenMs,
      'xpEarned': xpEarned,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'continent': continent,
      'hintsUsed': hintsUsed,
      'streakBonus': streakBonus,
      'speedBonus': speedBonus,
      'averageTimePerQuestionMs': averageTimePerQuestionMs,
      'perfectStreak': perfectStreak,
      'weakAreas': weakAreas,
      'strongAreas': strongAreas,
      'newAchievements': newAchievements,
    };
  }

  QuizResult toEntity() {
    return QuizResult(
      id: id,
      quizId: quizId,
      userId: userId,
      mode: mode,
      difficulty: difficulty,
      sessionType: sessionType,
      score: score,
      totalQuestions: totalQuestions,
      accuracy: accuracy,
      timeTaken: Duration(milliseconds: timeTakenMs),
      xpEarned: xpEarned,
      completedAt: completedAt,
      answers: answers.map((a) => a.toEntity()).toList(),
      continent: continent,
      hintsUsed: hintsUsed,
      streakBonus: streakBonus,
      speedBonus: speedBonus,
      averageTimePerQuestion: Duration(milliseconds: averageTimePerQuestionMs),
      perfectStreak: perfectStreak,
      weakAreas: weakAreas,
      strongAreas: strongAreas,
      newAchievements: newAchievements,
    );
  }
}
