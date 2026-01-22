import 'package:flutter/foundation.dart';

/// Quiz Session Type - determines the game mode
enum QuizSessionType {
  quickQuiz,       // 5 questions, ~3 mins
  continentChallenge, // 10 questions, one continent
  timedBlitz,      // 30 seconds per question, speed multiplier
  dailyChallenge,  // 5 curated questions, changes daily
  marathon,        // 50+ questions, lives system
  studyMode,       // No pressure, see answers, no XP
  standard;        // Default mode (10 questions)

  String get displayName {
    switch (this) {
      case QuizSessionType.quickQuiz:
        return 'Quick Quiz';
      case QuizSessionType.continentChallenge:
        return 'Continent Challenge';
      case QuizSessionType.timedBlitz:
        return 'Timed Blitz';
      case QuizSessionType.dailyChallenge:
        return 'Daily Challenge';
      case QuizSessionType.marathon:
        return 'Marathon';
      case QuizSessionType.studyMode:
        return 'Study Mode';
      case QuizSessionType.standard:
        return 'Standard Quiz';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case QuizSessionType.quickQuiz:
        return 'اختبار سريع';
      case QuizSessionType.continentChallenge:
        return 'تحدي القارة';
      case QuizSessionType.timedBlitz:
        return 'البرق المحدد بوقت';
      case QuizSessionType.dailyChallenge:
        return 'التحدي اليومي';
      case QuizSessionType.marathon:
        return 'الماراثون';
      case QuizSessionType.studyMode:
        return 'وضع الدراسة';
      case QuizSessionType.standard:
        return 'اختبار عادي';
    }
  }

  /// Get the number of questions for this session type
  int get questionCount {
    switch (this) {
      case QuizSessionType.quickQuiz:
        return 5;
      case QuizSessionType.continentChallenge:
        return 10;
      case QuizSessionType.timedBlitz:
        return 15;
      case QuizSessionType.dailyChallenge:
        return 5;
      case QuizSessionType.marathon:
        return 50;
      case QuizSessionType.studyMode:
        return 10;
      case QuizSessionType.standard:
        return 10;
    }
  }

  /// Get base XP reward multiplier
  double get xpMultiplier {
    switch (this) {
      case QuizSessionType.quickQuiz:
        return 1.0;
      case QuizSessionType.continentChallenge:
        return 1.5;
      case QuizSessionType.timedBlitz:
        return 2.0;
      case QuizSessionType.dailyChallenge:
        return 1.5;
      case QuizSessionType.marathon:
        return 3.0;
      case QuizSessionType.studyMode:
        return 0.0; // No XP in study mode
      case QuizSessionType.standard:
        return 1.0;
    }
  }

  /// Check if this mode is premium only
  bool get isPremiumOnly {
    switch (this) {
      case QuizSessionType.marathon:
        return true;
      default:
        return false;
    }
  }
}

/// Quiz entity
@immutable
class Quiz {
  const Quiz({
    required this.id,
    required this.mode,
    required this.difficulty,
    this.sessionType = QuizSessionType.standard,
    this.region,
    this.continent,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answers = const [],
    required this.startedAt,
    this.completedAt,
    this.livesRemaining,
    this.hintsUsed = 0,
    this.speedBonusMultiplier = 1.0,
    this.streakAtStart = 0,
  });

  final String id;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final QuizSessionType sessionType;
  final String? region; // Filter by region (optional)
  final String? continent; // For continent challenge
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<QuizAnswer> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? livesRemaining; // For marathon mode
  final int hintsUsed;
  final double speedBonusMultiplier; // For timed blitz
  final int streakAtStart; // For streak bonus calculation

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

  /// Calculate XP bonus based on streak at start
  double get streakBonus {
    if (streakAtStart >= 30) return 2.0; // 100% bonus
    if (streakAtStart >= 14) return 1.5; // 50% bonus
    if (streakAtStart >= 7) return 1.25; // 25% bonus
    if (streakAtStart >= 3) return 1.1; // 10% bonus
    return 1.0;
  }

  /// Check if user has lost (for marathon mode)
  bool get hasLost => livesRemaining != null && livesRemaining! <= 0;

  /// Anti-cheat: Validate quiz state integrity
  /// Returns true if the quiz state is valid and hasn't been tampered with
  bool get isStateValid {
    // 1. Validate question index matches answers count
    if (currentQuestionIndex != answers.length) return false;

    // 2. Validate currentQuestionIndex is within bounds
    if (currentQuestionIndex < 0 || currentQuestionIndex > questions.length) {
      return false;
    }

    // 3. Validate score matches actual correct answers
    final calculatedScore = answers.where((a) => a.isCorrect).length;
    if (score != calculatedScore) return false;

    // 4. Validate lives remaining (if in marathon mode)
    if (sessionType == QuizSessionType.marathon && livesRemaining != null) {
      final incorrectAnswers = answers.where((a) => !a.isCorrect).length;
      final expectedLives = 3 - incorrectAnswers;
      if (livesRemaining != expectedLives.clamp(0, 3)) return false;
    }

    // 5. Validate answer question IDs match actual questions
    for (int i = 0; i < answers.length; i++) {
      if (i >= questions.length) return false;
      if (answers[i].questionId != questions[i].id) return false;
    }

    // 6. Validate hints used count
    final hintsUsedInAnswers = answers.where((a) => a.usedHint).length;
    if (hintsUsed < hintsUsedInAnswers) return false;

    return true;
  }

  /// Anti-cheat: Calculate a simple integrity hash of the quiz state
  /// This helps detect client-side state manipulation
  int get integrityHash {
    var hash = 0;
    hash = hash ^ id.hashCode;
    hash = hash ^ mode.index;
    hash = hash ^ difficulty.index;
    hash = hash ^ sessionType.index;
    hash = hash ^ questions.length;
    hash = hash ^ currentQuestionIndex;
    hash = hash ^ answers.length;
    for (final answer in answers) {
      hash = hash ^ answer.questionId.hashCode;
      hash = hash ^ answer.isCorrect.hashCode;
    }
    return hash;
  }

  Quiz copyWith({
    String? id,
    QuizMode? mode,
    QuizDifficulty? difficulty,
    QuizSessionType? sessionType,
    String? region,
    String? continent,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<QuizAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
    int? livesRemaining,
    int? hintsUsed,
    double? speedBonusMultiplier,
    int? streakAtStart,
  }) {
    return Quiz(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      sessionType: sessionType ?? this.sessionType,
      region: region ?? this.region,
      continent: continent ?? this.continent,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      speedBonusMultiplier: speedBonusMultiplier ?? this.speedBonusMultiplier,
      streakAtStart: streakAtStart ?? this.streakAtStart,
    );
  }
}

/// Question type for different interaction patterns
enum QuestionType {
  multipleChoice,    // Standard A/B/C/D
  multiSelect,       // Select all that apply
  flagIdentification,// Identify flag
  reverseFlag,       // Select flag for country
  mapLocation,       // Tap on map
  dragAndDrop,       // Match pairs
  population,        // Compare populations
  timeZone,          // Time zone calculation
  trueFalse,         // True/False questions
  textInput;         // Type answer

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.multiSelect:
        return 'Multi-Select';
      case QuestionType.flagIdentification:
        return 'Flag Quiz';
      case QuestionType.reverseFlag:
        return 'Reverse Flag';
      case QuestionType.mapLocation:
        return 'Map Location';
      case QuestionType.dragAndDrop:
        return 'Matching';
      case QuestionType.population:
        return 'Population';
      case QuestionType.timeZone:
        return 'Time Zones';
      case QuestionType.trueFalse:
        return 'True or False';
      case QuestionType.textInput:
        return 'Type Answer';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'اختيار من متعدد';
      case QuestionType.multiSelect:
        return 'تحديد متعدد';
      case QuestionType.flagIdentification:
        return 'تعرف على العلم';
      case QuestionType.reverseFlag:
        return 'اختر العلم';
      case QuestionType.mapLocation:
        return 'حدد على الخريطة';
      case QuestionType.dragAndDrop:
        return 'المطابقة';
      case QuestionType.population:
        return 'السكان';
      case QuestionType.timeZone:
        return 'المناطق الزمنية';
      case QuestionType.trueFalse:
        return 'صح أو خطأ';
      case QuestionType.textInput:
        return 'اكتب الإجابة';
    }
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
    this.questionType = QuestionType.multipleChoice,
    this.imageUrl,
    this.countryCode,
    this.metadata,
    this.hint,
    this.hintArabic,
    this.explanation,
    this.explanationArabic,
    this.correctAnswers, // For multi-select questions
    this.matchingPairs, // For drag-and-drop
    this.funFact,
    this.funFactArabic,
  });

  final String id;
  final QuizMode mode;
  final QuestionType questionType;
  final String question;
  final String questionArabic;
  final String correctAnswer;
  final List<String> options;
  final String? imageUrl; // For flag questions
  final String? countryCode; // For map questions
  final Map<String, dynamic>? metadata;
  final String? hint;
  final String? hintArabic;
  final String? explanation;
  final String? explanationArabic;
  final List<String>? correctAnswers; // For multi-select
  final Map<String, String>? matchingPairs; // For drag-and-drop {"France": "Paris", "Italy": "Rome"}
  final String? funFact;
  final String? funFactArabic;

  /// Get display question based on locale
  String getDisplayQuestion({required bool isArabic}) {
    return isArabic ? questionArabic : question;
  }

  /// Get hint based on locale
  String? getHint({required bool isArabic}) {
    if (hint == null) return null;
    return isArabic ? (hintArabic ?? hint) : hint;
  }

  /// Get explanation based on locale
  String? getExplanation({required bool isArabic}) {
    if (explanation == null) return null;
    return isArabic ? (explanationArabic ?? explanation) : explanation;
  }

  /// Get fun fact based on locale
  String? getFunFact({required bool isArabic}) {
    if (funFact == null) return null;
    return isArabic ? (funFactArabic ?? funFact) : funFact;
  }

  /// Check if this is a multi-select question
  bool get isMultiSelect => questionType == QuestionType.multiSelect;

  /// Check if this question has a hint available
  bool get hasHint => hint != null && hint!.isNotEmpty;

  /// Validate multi-select answer
  bool validateMultiSelectAnswer(List<String> selectedAnswers) {
    if (correctAnswers == null) return false;
    if (selectedAnswers.length != correctAnswers!.length) return false;
    return selectedAnswers.toSet().containsAll(correctAnswers!.toSet());
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
    this.selectedAnswers, // For multi-select
    this.correctAnswers, // For multi-select
    this.usedHint = false,
    this.speedBonus = 1.0,
    this.xpEarned = 0,
  });

  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final Duration timeTaken;
  final DateTime answeredAt;
  final List<String>? selectedAnswers; // For multi-select questions
  final List<String>? correctAnswers; // For multi-select questions
  final bool usedHint;
  final double speedBonus; // Speed multiplier for timed blitz
  final int xpEarned;

  /// Check if answer is correct (handles both single and multi-select)
  bool get isCorrect {
    if (selectedAnswers != null && correctAnswers != null) {
      // Multi-select validation
      if (selectedAnswers!.length != correctAnswers!.length) return false;
      return selectedAnswers!.toSet().containsAll(correctAnswers!.toSet());
    }
    // Single answer validation
    return selectedAnswer == correctAnswer;
  }

  /// Check if answer is partially correct (for multi-select)
  bool get isPartiallyCorrect {
    if (selectedAnswers == null || correctAnswers == null) return false;
    final correctCount =
        selectedAnswers!.where((a) => correctAnswers!.contains(a)).length;
    return correctCount > 0 && correctCount < correctAnswers!.length;
  }

  /// Get partial score for multi-select (0.0 to 1.0)
  double get partialScore {
    if (selectedAnswers == null || correctAnswers == null) {
      return isCorrect ? 1.0 : 0.0;
    }
    final correctCount =
        selectedAnswers!.where((a) => correctAnswers!.contains(a)).length;
    final incorrectCount =
        selectedAnswers!.where((a) => !correctAnswers!.contains(a)).length;
    final score = (correctCount - incorrectCount * 0.5) / correctAnswers!.length;
    return score.clamp(0.0, 1.0);
  }
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
    this.sessionType = QuizSessionType.standard,
    this.continent,
    this.hintsUsed = 0,
    this.streakBonus = 1.0,
    this.speedBonus = 1.0,
    this.averageTimePerQuestion = Duration.zero,
    this.perfectStreak = 0, // Consecutive correct answers
    this.weakAreas = const [],
    this.strongAreas = const [],
    this.newAchievements = const [],
  });

  final String id;
  final String quizId;
  final String userId;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final QuizSessionType sessionType;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final Duration timeTaken;
  final int xpEarned;
  final DateTime completedAt;
  final List<QuizAnswer> answers;
  final String? continent;
  final int hintsUsed;
  final double streakBonus;
  final double speedBonus;
  final Duration averageTimePerQuestion;
  final int perfectStreak; // Longest streak of consecutive correct answers
  final List<String> weakAreas; // Areas needing improvement
  final List<String> strongAreas; // Areas of strength
  final List<String> newAchievements; // Achievement IDs unlocked during this quiz

  /// Check if perfect score
  bool get isPerfectScore => score == totalQuestions;

  /// Calculate star rating (1-5)
  int get starRating {
    if (accuracy >= 100) return 5;
    if (accuracy >= 80) return 4;
    if (accuracy >= 60) return 3;
    if (accuracy >= 40) return 2;
    return 1;
  }

  /// Get performance grade (A, B, C, D, F)
  String get grade {
    if (accuracy >= 90) return 'A';
    if (accuracy >= 80) return 'B';
    if (accuracy >= 70) return 'C';
    if (accuracy >= 60) return 'D';
    return 'F';
  }

  /// Check if this qualifies for leaderboard
  bool get isLeaderboardEligible =>
      sessionType != QuizSessionType.studyMode && accuracy >= 50;

  /// Calculate total bonus multiplier applied
  double get totalBonusMultiplier => streakBonus * speedBonus;
}

/// Quiz modes
enum QuizMode {
  capitals,
  flags,
  reverseFlags, // Select the flag for a given country
  maps,
  population,
  currencies,
  languages,
  borders, // Neighboring countries
  timezones, // Time zone questions
  landmarks, // Premium - Identify landmarks
  mixed;

  String get displayName {
    switch (this) {
      case QuizMode.capitals:
        return 'Capitals';
      case QuizMode.flags:
        return 'Flags';
      case QuizMode.reverseFlags:
        return 'Reverse Flags';
      case QuizMode.maps:
        return 'Maps';
      case QuizMode.population:
        return 'Population';
      case QuizMode.currencies:
        return 'Currencies';
      case QuizMode.languages:
        return 'Languages';
      case QuizMode.borders:
        return 'Neighbors';
      case QuizMode.timezones:
        return 'Time Zones';
      case QuizMode.landmarks:
        return 'Landmarks';
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
      case QuizMode.reverseFlags:
        return 'الأعلام المعكوسة';
      case QuizMode.maps:
        return 'الخرائط';
      case QuizMode.population:
        return 'السكان';
      case QuizMode.currencies:
        return 'العملات';
      case QuizMode.languages:
        return 'اللغات';
      case QuizMode.borders:
        return 'الجيران';
      case QuizMode.timezones:
        return 'المناطق الزمنية';
      case QuizMode.landmarks:
        return 'المعالم';
      case QuizMode.mixed:
        return 'مختلط';
    }
  }

  /// Get description of this quiz mode
  String get description {
    switch (this) {
      case QuizMode.capitals:
        return 'Name the capitals of countries';
      case QuizMode.flags:
        return 'Identify flags from around the world';
      case QuizMode.reverseFlags:
        return 'Select the correct flag for a country';
      case QuizMode.maps:
        return 'Find countries on the map';
      case QuizMode.population:
        return 'Compare country populations';
      case QuizMode.currencies:
        return 'Match currencies to countries';
      case QuizMode.languages:
        return 'Identify official languages';
      case QuizMode.borders:
        return 'Select neighboring countries';
      case QuizMode.timezones:
        return 'Calculate time differences';
      case QuizMode.landmarks:
        return 'Identify famous landmarks';
      case QuizMode.mixed:
        return 'Random mix of all topics';
    }
  }

  String get descriptionArabic {
    switch (this) {
      case QuizMode.capitals:
        return 'سمِّ عواصم الدول';
      case QuizMode.flags:
        return 'تعرّف على أعلام العالم';
      case QuizMode.reverseFlags:
        return 'اختر العلم الصحيح للدولة';
      case QuizMode.maps:
        return 'حدد الدول على الخريطة';
      case QuizMode.population:
        return 'قارن بين أعداد السكان';
      case QuizMode.currencies:
        return 'طابق العملات مع الدول';
      case QuizMode.languages:
        return 'حدد اللغات الرسمية';
      case QuizMode.borders:
        return 'اختر الدول المجاورة';
      case QuizMode.timezones:
        return 'احسب فروق التوقيت';
      case QuizMode.landmarks:
        return 'تعرّف على المعالم الشهيرة';
      case QuizMode.mixed:
        return 'خليط عشوائي من جميع المواضيع';
    }
  }

  /// Check if this mode is premium only
  bool get isPremiumOnly {
    switch (this) {
      case QuizMode.landmarks:
      case QuizMode.maps:
        return true;
      default:
        return false;
    }
  }

  /// Get icon name for this mode
  String get iconName {
    switch (this) {
      case QuizMode.capitals:
        return 'location_city';
      case QuizMode.flags:
        return 'flag';
      case QuizMode.reverseFlags:
        return 'flag_outlined';
      case QuizMode.maps:
        return 'map';
      case QuizMode.population:
        return 'people';
      case QuizMode.currencies:
        return 'attach_money';
      case QuizMode.languages:
        return 'translate';
      case QuizMode.borders:
        return 'share_location';
      case QuizMode.timezones:
        return 'schedule';
      case QuizMode.landmarks:
        return 'castle';
      case QuizMode.mixed:
        return 'shuffle';
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
