import '../../domain/entities/quiz.dart';

/// Quiz data model for Firestore/local storage
class QuizModel {
  const QuizModel({
    required this.id,
    required this.mode,
    required this.difficulty,
    this.region,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.startedAt,
    this.completedAt,
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
      region: json['region'] as String?,
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
    );
  }

  factory QuizModel.fromEntity(Quiz entity) {
    return QuizModel(
      id: entity.id,
      mode: entity.mode,
      difficulty: entity.difficulty,
      region: entity.region,
      questions:
          entity.questions.map((q) => QuizQuestionModel.fromEntity(q)).toList(),
      currentQuestionIndex: entity.currentQuestionIndex,
      answers:
          entity.answers.map((a) => QuizAnswerModel.fromEntity(a)).toList(),
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
    );
  }

  final String id;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final String? region;
  final List<QuizQuestionModel> questions;
  final int currentQuestionIndex;
  final List<QuizAnswerModel> answers;
  final DateTime startedAt;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'difficulty': difficulty.name,
      'region': region,
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'answers': answers.map((a) => a.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Quiz toEntity() {
    return Quiz(
      id: id,
      mode: mode,
      difficulty: difficulty,
      region: region,
      questions: questions.map((q) => q.toEntity()).toList(),
      currentQuestionIndex: currentQuestionIndex,
      answers: answers.map((a) => a.toEntity()).toList(),
      startedAt: startedAt,
      completedAt: completedAt,
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
    this.imageUrl,
    this.countryCode,
    this.metadata,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      mode: QuizMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizMode.mixed,
      ),
      question: json['question'] as String? ?? '',
      questionArabic: json['questionArabic'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      countryCode: json['countryCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      mode: entity.mode,
      question: entity.question,
      questionArabic: entity.questionArabic,
      correctAnswer: entity.correctAnswer,
      options: entity.options,
      imageUrl: entity.imageUrl,
      countryCode: entity.countryCode,
      metadata: entity.metadata,
    );
  }

  final String id;
  final QuizMode mode;
  final String question;
  final String questionArabic;
  final String correctAnswer;
  final List<String> options;
  final String? imageUrl;
  final String? countryCode;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'question': question,
      'questionArabic': questionArabic,
      'correctAnswer': correctAnswer,
      'options': options,
      'imageUrl': imageUrl,
      'countryCode': countryCode,
      'metadata': metadata,
    };
  }

  QuizQuestion toEntity() {
    return QuizQuestion(
      id: id,
      mode: mode,
      question: question,
      questionArabic: questionArabic,
      correctAnswer: correctAnswer,
      options: options,
      imageUrl: imageUrl,
      countryCode: countryCode,
      metadata: metadata,
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
    );
  }

  factory QuizAnswerModel.fromEntity(QuizAnswer entity) {
    return QuizAnswerModel(
      questionId: entity.questionId,
      selectedAnswer: entity.selectedAnswer,
      correctAnswer: entity.correctAnswer,
      timeTakenMs: entity.timeTaken.inMilliseconds,
      answeredAt: entity.answeredAt,
    );
  }

  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final int timeTakenMs;
  final DateTime answeredAt;

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'timeTakenMs': timeTakenMs,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  QuizAnswer toEntity() {
    return QuizAnswer(
      questionId: questionId,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
      timeTaken: Duration(milliseconds: timeTakenMs),
      answeredAt: answeredAt,
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
    );
  }

  factory QuizResultModel.fromEntity(QuizResult entity) {
    return QuizResultModel(
      id: entity.id,
      quizId: entity.quizId,
      userId: entity.userId,
      mode: entity.mode,
      difficulty: entity.difficulty,
      score: entity.score,
      totalQuestions: entity.totalQuestions,
      accuracy: entity.accuracy,
      timeTakenMs: entity.timeTaken.inMilliseconds,
      xpEarned: entity.xpEarned,
      completedAt: entity.completedAt,
      answers:
          entity.answers.map((a) => QuizAnswerModel.fromEntity(a)).toList(),
    );
  }

  final String id;
  final String quizId;
  final String userId;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeTakenMs;
  final int xpEarned;
  final DateTime completedAt;
  final List<QuizAnswerModel> answers;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'mode': mode.name,
      'difficulty': difficulty.name,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'timeTakenMs': timeTakenMs,
      'xpEarned': xpEarned,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }

  QuizResult toEntity() {
    return QuizResult(
      id: id,
      quizId: quizId,
      userId: userId,
      mode: mode,
      difficulty: difficulty,
      score: score,
      totalQuestions: totalQuestions,
      accuracy: accuracy,
      timeTaken: Duration(milliseconds: timeTakenMs),
      xpEarned: xpEarned,
      completedAt: completedAt,
      answers: answers.map((a) => a.toEntity()).toList(),
    );
  }
}
