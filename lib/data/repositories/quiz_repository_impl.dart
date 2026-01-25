import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/arabic_country_names.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../datasources/local/quiz_local_datasource.dart';
import '../datasources/remote/firestore_user_datasource.dart';
import '../models/quiz_model.dart';

/// Fun facts about countries for educational content
const Map<String, Map<String, String>> _countryFunFacts = {
  'FR': {
    'en': 'Paris is called the City of Light because it was one of the first cities to use street lighting.',
    'ar': 'تُسمى باريس مدينة النور لأنها كانت من أوائل المدن التي استخدمت إنارة الشوارع.',
  },
  'JP': {
    'en': 'Japan has more than 6,800 islands, but only about 430 are inhabited.',
    'ar': 'اليابان لديها أكثر من 6800 جزيرة، لكن حوالي 430 منها فقط مأهولة بالسكان.',
  },
  'BR': {
    'en': 'Brazil produces about one-third of the world\'s coffee.',
    'ar': 'البرازيل تنتج حوالي ثلث القهوة في العالم.',
  },
  'EG': {
    'en': 'The Great Pyramid of Giza was the tallest man-made structure for over 3,800 years.',
    'ar': 'كان الهرم الأكبر في الجيزة أطول هيكل من صنع الإنسان لأكثر من 3800 عام.',
  },
  'AU': {
    'en': 'Australia is both a country and a continent, and has the longest fence in the world.',
    'ar': 'أستراليا هي دولة وقارة في آن واحد، ولديها أطول سياج في العالم.',
  },
  'IN': {
    'en': 'India has the world\'s largest postal network with over 150,000 post offices.',
    'ar': 'الهند لديها أكبر شبكة بريدية في العالم مع أكثر من 150,000 مكتب بريد.',
  },
  'CN': {
    'en': 'The Great Wall of China is not visible from space with the naked eye, contrary to popular belief.',
    'ar': 'سور الصين العظيم غير مرئي من الفضاء بالعين المجردة، على عكس الاعتقاد الشائع.',
  },
  'IT': {
    'en': 'Italy has more UNESCO World Heritage Sites than any other country.',
    'ar': 'إيطاليا لديها مواقع تراث عالمي لليونسكو أكثر من أي دولة أخرى.',
  },
  'SA': {
    'en': 'Saudi Arabia has no rivers, making it one of the few countries without permanent surface water.',
    'ar': 'المملكة العربية السعودية ليس لديها أنهار، مما يجعلها من الدول القليلة بدون مياه سطحية دائمة.',
  },
  'US': {
    'en': 'The United States has no official language at the federal level.',
    'ar': 'الولايات المتحدة ليس لديها لغة رسمية على المستوى الفيدرالي.',
  },
};

/// Quiz repository implementation
class QuizRepositoryImpl implements IQuizRepository {
  QuizRepositoryImpl({
    required IQuizLocalDataSource localDataSource,
    required ICountryRepository countryRepository,
    IFirestoreUserDataSource? firestoreDataSource,
  })  : _localDataSource = localDataSource,
        _countryRepository = countryRepository,
        _firestoreDataSource = firestoreDataSource;

  final IQuizLocalDataSource _localDataSource;
  final ICountryRepository _countryRepository;
  final IFirestoreUserDataSource? _firestoreDataSource;
  final _uuid = const Uuid();
  final _random = Random();

  @override
  Future<Either<Failure, Quiz>> generateQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    String? region,
    int questionCount = 10,
    QuizSessionType sessionType = QuizSessionType.standard,
    String? continent,
    int currentStreak = 0,
  }) async {
    try {
      // Get countries for quiz generation
      final countriesResult = await _countryRepository.getAllCountries();
      return countriesResult.fold(
        Left.new,
        (allCountries) async {
          // Filter by region or continent if specified
          var countries = allCountries;
          if (region != null && region.isNotEmpty) {
            countries = allCountries
                .where((c) => c.region.toLowerCase() == region.toLowerCase())
                .toList();
          } else if (continent != null && continent.isNotEmpty) {
            countries = allCountries
                .where((c) => c.continents
                    .any((cont) => cont.toLowerCase() == continent.toLowerCase()))
                .toList();
          }

          if (countries.length < 4) {
            return Left(QuizFailure.noQuestionsAvailable());
          }

          // Determine actual question count based on session type
          final actualQuestionCount = sessionType.questionCount;

          // Generate questions based on mode
          final questions = <QuizQuestion>[];
          final usedCountries = <String>{};

          // Shuffle countries for randomness
          final shuffledCountries = List<Country>.from(countries)..shuffle(_random);

          for (var i = 0; i < actualQuestionCount && usedCountries.length < shuffledCountries.length; i++) {
            // Select a country that hasn't been used
            Country? targetCountry;
            for (final country in shuffledCountries) {
              if (!usedCountries.contains(country.code)) {
                targetCountry = country;
                break;
              }
            }

            if (targetCountry == null) break;
            usedCountries.add(targetCountry.code);

            // Generate question based on mode
            final questionMode = mode == QuizMode.mixed
                ? _getRandomQuizMode()
                : mode;

            final question = _generateQuestion(
              mode: questionMode,
              targetCountry: targetCountry,
              allCountries: countries,
              difficulty: difficulty,
              questionIndex: i,
              sessionType: sessionType,
            );

            if (question != null) {
              questions.add(question);
            }
          }

          if (questions.isEmpty) {
            return Left(QuizFailure.noQuestionsAvailable());
          }

          // Calculate initial lives for marathon mode
          int? initialLives;
          if (sessionType == QuizSessionType.marathon) {
            initialLives = 3; // Three lives for marathon mode
          }

          final quiz = Quiz(
            id: _uuid.v4(),
            mode: mode,
            difficulty: difficulty,
            sessionType: sessionType,
            region: region,
            continent: continent,
            questions: questions,
            startedAt: DateTime.now(),
            livesRemaining: initialLives,
            streakAtStart: currentStreak,
          );

          logger.debug(
            'Generated ${sessionType.name} quiz with ${questions.length} questions',
            tag: 'QuizRepo',
          );

          return Right(quiz);
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        'Error generating quiz',
        tag: 'QuizRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(QuizFailure(message: 'Failed to generate quiz'));
    }
  }

  /// Get a random quiz mode (excluding mixed and premium modes)
  QuizMode _getRandomQuizMode() {
    final availableModes = [
      QuizMode.capitals,
      QuizMode.flags,
      QuizMode.reverseFlags,
      QuizMode.population,
      QuizMode.currencies,
      QuizMode.languages,
      QuizMode.borders,
    ];
    return availableModes[_random.nextInt(availableModes.length)];
  }

  QuizQuestion? _generateQuestion({
    required QuizMode mode,
    required Country targetCountry,
    required List<Country> allCountries,
    required QuizDifficulty difficulty,
    required int questionIndex,
    QuizSessionType sessionType = QuizSessionType.standard,
  }) {
    final optionsCount = difficulty.optionsCount;

    // Get wrong options
    final wrongOptions = allCountries
        .where((c) => c.code != targetCountry.code)
        .toList()
      ..shuffle(_random);

    // Get fun fact for this country
    final funFactData = _countryFunFacts[targetCountry.code];
    final funFact = funFactData?['en'];
    final funFactArabic = funFactData?['ar'];

    // Determine if we should include hints (not for study mode)
    final includeHint = sessionType != QuizSessionType.studyMode;

    switch (mode) {
      case QuizMode.capitals:
        if (targetCountry.capital == null) return null;
        // Build list of countries for options (target + wrong options with capitals)
        final optionCountries = [
          targetCountry,
          ...wrongOptions.where((c) => c.capital != null).take(optionsCount - 1),
        ];
        // Create paired options (English and Arabic at same indices)
        final pairedOptions = optionCountries.map((c) => (
          en: c.capital!,
          ar: c.capitalArabic ?? c.capital!,
        )).toList();
        // Shuffle while keeping pairs together
        pairedOptions.shuffle(_random);
        final options = pairedOptions.map((p) => p.en).toList();
        final optionsArabic = pairedOptions.map((p) => p.ar).toList();

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.multipleChoice,
          question: 'What is the capital of ${targetCountry.name}?',
          questionArabic: 'ما هي عاصمة ${targetCountry.nameArabic}؟',
          correctAnswer: targetCountry.capital!,
          correctAnswerArabic: targetCountry.capitalArabic ?? targetCountry.capital,
          options: options,
          optionsArabic: optionsArabic,
          countryCode: targetCountry.code,
          hint: includeHint ? 'This city is in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'هذه المدينة في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: '${targetCountry.capital} is the capital and largest city of ${targetCountry.name}.',
          explanationArabic: '${targetCountry.capitalArabic ?? targetCountry.capital} هي عاصمة وأكبر مدينة في ${targetCountry.nameArabic}.',
          funFact: funFact,
          funFactArabic: funFactArabic,
        );

      case QuizMode.flags:
        // Build list of countries for options
        final flagOptionCountries = [
          targetCountry,
          ...wrongOptions.take(optionsCount - 1),
        ];
        // Create paired options (English and Arabic at same indices)
        final flagPairedOptions = flagOptionCountries.map((c) => (
          en: c.name,
          ar: c.nameArabic,
        )).toList();
        flagPairedOptions.shuffle(_random);
        final flagOptions = flagPairedOptions.map((p) => p.en).toList();
        final flagOptionsArabic = flagPairedOptions.map((p) => p.ar).toList();

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.flagIdentification,
          question: 'Which country does this flag belong to?',
          questionArabic: 'لأي دولة ينتمي هذا العلم؟',
          correctAnswer: targetCountry.name,
          correctAnswerArabic: targetCountry.nameArabic,
          options: flagOptions,
          optionsArabic: flagOptionsArabic,
          imageUrl: targetCountry.flagUrl,
          countryCode: targetCountry.code,
          hint: includeHint ? 'This country is located in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'تقع هذه الدولة في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: 'This is the flag of ${targetCountry.name}.',
          explanationArabic: 'هذا هو علم ${targetCountry.nameArabic}.',
          funFact: funFact,
          funFactArabic: funFactArabic,
        );

      case QuizMode.reverseFlags:
        // Show country name, select the correct flag
        final flagOptions = [
          targetCountry.flagUrl,
          ...wrongOptions
              .take(optionsCount - 1)
              .map((c) => c.flagUrl),
        ]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.reverseFlag,
          question: 'Select the flag of ${targetCountry.name}',
          questionArabic: 'اختر علم ${targetCountry.nameArabic}',
          correctAnswer: targetCountry.flagUrl,
          options: flagOptions,
          countryCode: targetCountry.code,
          hint: includeHint ? 'The flag might contain colors from the national symbol' : null,
          hintArabic: includeHint ? 'قد يحتوي العلم على ألوان من الرمز الوطني' : null,
          explanation: 'The flag of ${targetCountry.name} features its national colors and symbols.',
          explanationArabic: 'يتميز علم ${targetCountry.nameArabic} بألوانه ورموزه الوطنية.',
          metadata: {
            'isImageOptions': true,
          },
        );

      case QuizMode.maps:
        // Build list of countries for options
        final mapOptionCountries = [
          targetCountry,
          ...wrongOptions.take(optionsCount - 1),
        ];
        // Create paired options (English and Arabic at same indices)
        final mapPairedOptions = mapOptionCountries.map((c) => (
          en: c.name,
          ar: c.nameArabic,
        )).toList();
        mapPairedOptions.shuffle(_random);
        final mapOptions = mapPairedOptions.map((p) => p.en).toList();
        final mapOptionsArabic = mapPairedOptions.map((p) => p.ar).toList();

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.mapLocation,
          question: 'Identify this country on the map',
          questionArabic: 'حدد هذه الدولة على الخريطة',
          correctAnswer: targetCountry.name,
          correctAnswerArabic: targetCountry.nameArabic,
          options: mapOptions,
          optionsArabic: mapOptionsArabic,
          countryCode: targetCountry.code,
          metadata: {
            'latitude': targetCountry.coordinates.latitude,
            'longitude': targetCountry.coordinates.longitude,
          },
          hint: includeHint ? 'This country is in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'تقع هذه الدولة في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: '${targetCountry.name} is located in ${targetCountry.region}.',
          explanationArabic: 'تقع ${targetCountry.nameArabic} في ${ArabicCountryNames.getRegion(targetCountry.region)}.',
        );

      case QuizMode.population:
        // Find countries with significant population differences
        final sortedByPop = List<Country>.from(allCountries)
          ..sort((a, b) => b.population.compareTo(a.population));
        final popOptions = <Country>[targetCountry];
        for (final c in sortedByPop) {
          if (c.code != targetCountry.code && popOptions.length < optionsCount) {
            popOptions.add(c);
          }
        }
        popOptions.shuffle(_random);
        // Population numbers are the same in both languages
        final popOptionsList = popOptions.map((c) => _formatPopulation(c.population)).toList();

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.population,
          question: 'What is the approximate population of ${targetCountry.name}?',
          questionArabic: 'ما هو عدد سكان ${targetCountry.nameArabic} تقريباً؟',
          correctAnswer: _formatPopulation(targetCountry.population),
          options: popOptionsList,
          countryCode: targetCountry.code,
          hint: includeHint ? 'This is one of the ${targetCountry.population > 100000000 ? "most populous" : "smaller"} countries in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'هذه واحدة من ${targetCountry.population > 100000000 ? "أكثر الدول سكاناً" : "الدول الأصغر"} في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: '${targetCountry.name} has a population of approximately ${_formatPopulation(targetCountry.population)}.',
          explanationArabic: 'يبلغ عدد سكان ${targetCountry.nameArabic} حوالي ${_formatPopulation(targetCountry.population)}.',
          metadata: {
            'exactPopulation': targetCountry.population,
          },
        );

      case QuizMode.currencies:
        if (targetCountry.currencies.isEmpty) return null;
        final currency = targetCountry.currencies.first;
        final wrongCurrencies = wrongOptions
            .where((c) => c.currencies.isNotEmpty)
            .take(optionsCount - 1)
            .map((c) => '${c.currencies.first.name} (${c.currencies.first.symbol})')
            .toList();

        final options = [
          '${currency.name} (${currency.symbol})',
          ...wrongCurrencies,
        ]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.multipleChoice,
          question: 'What currency is used in ${targetCountry.name}?',
          questionArabic: 'ما هي العملة المستخدمة في ${targetCountry.nameArabic}؟',
          correctAnswer: '${currency.name} (${currency.symbol})',
          options: options,
          countryCode: targetCountry.code,
          hint: includeHint ? 'The currency symbol is ${currency.symbol}' : null,
          hintArabic: includeHint ? 'رمز العملة هو ${currency.symbol}' : null,
          explanation: '${currency.name} is the official currency of ${targetCountry.name}.',
          explanationArabic: '${currency.name} هي العملة الرسمية في ${targetCountry.nameArabic}.',
        );

      case QuizMode.languages:
        if (targetCountry.languages.isEmpty) return null;
        final language = targetCountry.languages.first;
        final wrongLanguages = wrongOptions
            .where((c) => c.languages.isNotEmpty)
            .take(optionsCount - 1)
            .map((c) => c.languages.first)
            .toList();

        final langOptions = [language, ...wrongLanguages]..shuffle(_random);
        // Language names are typically international (English/Latin script)

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.multipleChoice,
          question: 'What is an official language of ${targetCountry.name}?',
          questionArabic: 'ما هي اللغة الرسمية في ${targetCountry.nameArabic}؟',
          correctAnswer: language,
          options: langOptions,
          countryCode: targetCountry.code,
          hint: includeHint ? 'This country is in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'تقع هذه الدولة في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: '$language is one of the official languages spoken in ${targetCountry.name}.',
          explanationArabic: '$language هي إحدى اللغات الرسمية المتحدثة في ${targetCountry.nameArabic}.',
        );

      case QuizMode.borders:
        // Multi-select question for neighboring countries
        if (targetCountry.borders.isEmpty) return null;

        // Get actual border countries with both English and Arabic names
        final borderCountryPairs = <({String en, String ar})>[];
        for (final borderCode in targetCountry.borders) {
          final borderCountry = allCountries.firstWhere(
            (c) => c.code == borderCode,
            orElse: () => allCountries.first,
          );
          if (borderCountry.code == borderCode) {
            borderCountryPairs.add((en: borderCountry.name, ar: borderCountry.nameArabic));
          }
        }

        if (borderCountryPairs.isEmpty) return null;

        // Get some wrong options (countries that don't border)
        final nonBorderingCountryPairs = wrongOptions
            .where((c) => !targetCountry.borders.contains(c.code))
            .take(4)
            .map((c) => (en: c.name, ar: c.nameArabic))
            .toList();

        // Combine and shuffle while keeping pairs together
        final allBorderPairs = [...borderCountryPairs, ...nonBorderingCountryPairs]
          ..shuffle(_random);
        final borderOptions = allBorderPairs.map((p) => p.en).toList();
        final borderOptionsArabic = allBorderPairs.map((p) => p.ar).toList();

        // Extract correct answers in both languages
        final correctBorderAnswers = borderCountryPairs.map((p) => p.en).toList();
        final correctBorderAnswersArabic = borderCountryPairs.map((p) => p.ar).toList();

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.multiSelect,
          question: 'Which countries border ${targetCountry.name}? (Select all)',
          questionArabic: 'ما هي الدول التي تحد ${targetCountry.nameArabic}؟ (اختر الكل)',
          correctAnswer: correctBorderAnswers.first,
          correctAnswerArabic: correctBorderAnswersArabic.first,
          correctAnswers: correctBorderAnswers,
          correctAnswersArabic: correctBorderAnswersArabic,
          options: borderOptions,
          optionsArabic: borderOptionsArabic,
          countryCode: targetCountry.code,
          hint: includeHint ? '${targetCountry.name} has ${borderCountryPairs.length} neighboring countries' : null,
          hintArabic: includeHint ? '${targetCountry.nameArabic} لديها ${borderCountryPairs.length} دول مجاورة' : null,
          explanation: '${targetCountry.name} shares borders with ${correctBorderAnswers.join(", ")}.',
          explanationArabic: '${targetCountry.nameArabic} تشترك في الحدود مع ${correctBorderAnswersArabic.join("، ")}.',
        );

      case QuizMode.timezones:
        if (targetCountry.timezones.isEmpty) return null;
        final timezone = targetCountry.timezones.first;

        // Get wrong timezone options
        final wrongTimezones = wrongOptions
            .where((c) => c.timezones.isNotEmpty && c.timezones.first != timezone)
            .take(optionsCount - 1)
            .map((c) => c.timezones.first)
            .toSet()
            .toList();

        if (wrongTimezones.length < optionsCount - 1) return null;

        final tzOptions = [timezone, ...wrongTimezones.take(optionsCount - 1)]
          ..shuffle(_random);
        // Timezone codes are universal (UTC+X format)

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          questionType: QuestionType.timeZone,
          question: 'What is the primary timezone of ${targetCountry.name}?',
          questionArabic: 'ما هي المنطقة الزمنية الرئيسية في ${targetCountry.nameArabic}؟',
          correctAnswer: timezone,
          options: tzOptions,
          countryCode: targetCountry.code,
          hint: includeHint ? 'This country is in ${targetCountry.region}' : null,
          hintArabic: includeHint ? 'تقع هذه الدولة في ${ArabicCountryNames.getRegion(targetCountry.region)}' : null,
          explanation: '${targetCountry.name} uses $timezone as its primary timezone.',
          explanationArabic: '${targetCountry.nameArabic} تستخدم $timezone كمنطقتها الزمنية الرئيسية.',
        );

      case QuizMode.landmarks:
        // Premium feature - would need landmark data
        return null;

      case QuizMode.mixed:
        // This case is handled by selecting a random mode above
        return null;
    }
  }

  /// Format population for display
  String _formatPopulation(int pop) {
    if (pop >= 1000000000) {
      return '${(pop / 1000000000).toStringAsFixed(1)}B';
    } else if (pop >= 1000000) {
      return '${(pop / 1000000).toStringAsFixed(1)}M';
    } else if (pop >= 1000) {
      return '${(pop / 1000).toStringAsFixed(1)}K';
    }
    return pop.toString();
  }

  @override
  Future<Either<Failure, QuizAnswer>> submitAnswer({
    required String quizId,
    required String questionId,
    required String answer,
    required Duration timeTaken,
  }) async {
    try {
      // Create the answer - correctness will be determined by caller
      final quizAnswer = QuizAnswer(
        questionId: questionId,
        selectedAnswer: answer,
        correctAnswer: answer, // Temporary - actual validation happens in UI
        timeTaken: timeTaken,
        answeredAt: DateTime.now(),
      );

      return Right(quizAnswer);
    } catch (e) {
      return const Left(QuizFailure(message: 'Failed to submit answer'));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> completeQuiz(
    Quiz quiz, {
    String? userId,
  }) async {
    try {
      // Calculate base XP
      const baseXp = 10;
      final correctAnswersXp = quiz.score * 10;
      final difficultyMultiplier = quiz.difficulty.xpMultiplier;
      final sessionMultiplier = quiz.sessionType.xpMultiplier;

      // Perfect score bonus
      final perfectBonus = quiz.isPerfectScore ? 50 : 0;

      // Speed bonus (if answered quickly)
      final avgTimePerQuestion = quiz.answers.isEmpty
          ? Duration.zero
          : Duration(
              milliseconds: quiz.answers
                      .map((a) => a.timeTaken.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  quiz.answers.length);

      final speedBonus = avgTimePerQuestion.inSeconds < 10 ? 25 : 0;
      final speedBonusMultiplier =
          avgTimePerQuestion.inSeconds < 5 ? 1.5 : (avgTimePerQuestion.inSeconds < 10 ? 1.25 : 1.0);

      // Streak bonus
      final streakBonus = quiz.streakBonus;

      // Hint penalty (5 XP per hint used)
      final hintPenalty = quiz.hintsUsed * 5;

      // Study mode earns no XP
      final totalXp = quiz.sessionType == QuizSessionType.studyMode
          ? 0
          : ((baseXp + correctAnswersXp + perfectBonus + speedBonus - hintPenalty) *
                  difficultyMultiplier *
                  sessionMultiplier *
                  streakBonus)
              .round()
              .clamp(0, 10000);

      // Calculate longest correct answer streak
      var currentPerfectStreak = 0;
      var maxPerfectStreak = 0;
      for (final answer in quiz.answers) {
        if (answer.isCorrect) {
          currentPerfectStreak++;
          if (currentPerfectStreak > maxPerfectStreak) {
            maxPerfectStreak = currentPerfectStreak;
          }
        } else {
          currentPerfectStreak = 0;
        }
      }

      // Analyze weak and strong areas based on quiz mode performance
      final modeCorrectCount = <QuizMode, int>{};
      final modeTotalCount = <QuizMode, int>{};

      for (var i = 0; i < quiz.questions.length && i < quiz.answers.length; i++) {
        final question = quiz.questions[i];
        final answer = quiz.answers[i];
        modeTotalCount[question.mode] = (modeTotalCount[question.mode] ?? 0) + 1;
        if (answer.isCorrect) {
          modeCorrectCount[question.mode] = (modeCorrectCount[question.mode] ?? 0) + 1;
        }
      }

      final weakAreas = <String>[];
      final strongAreas = <String>[];

      for (final mode in modeTotalCount.keys) {
        final total = modeTotalCount[mode] ?? 0;
        final correct = modeCorrectCount[mode] ?? 0;
        if (total > 0) {
          final accuracy = correct / total;
          if (accuracy < 0.5) {
            weakAreas.add(mode.displayName);
          } else if (accuracy >= 0.8) {
            strongAreas.add(mode.displayName);
          }
        }
      }

      // Check for potential new achievements
      final newAchievements = <String>[];
      if (quiz.isPerfectScore) {
        newAchievements.add('perfect_quiz');
      }
      if (quiz.sessionType == QuizSessionType.marathon && quiz.score >= 40) {
        newAchievements.add('marathon_master');
      }
      if (quiz.sessionType == QuizSessionType.dailyChallenge) {
        newAchievements.add('daily_challenger');
      }

      final result = QuizResult(
        id: _uuid.v4(),
        quizId: quiz.id,
        userId: userId ?? '',
        mode: quiz.mode,
        difficulty: quiz.difficulty,
        sessionType: quiz.sessionType,
        score: quiz.score,
        totalQuestions: quiz.totalQuestions,
        accuracy: quiz.accuracy,
        timeTaken: quiz.timeElapsed,
        xpEarned: totalXp,
        completedAt: DateTime.now(),
        answers: quiz.answers,
        continent: quiz.continent,
        hintsUsed: quiz.hintsUsed,
        streakBonus: streakBonus,
        speedBonus: speedBonusMultiplier,
        averageTimePerQuestion: avgTimePerQuestion,
        perfectStreak: maxPerfectStreak,
        weakAreas: weakAreas,
        strongAreas: strongAreas,
        newAchievements: newAchievements,
      );

      final resultModel = QuizResultModel.fromEntity(result);

      // Save result locally
      await _localDataSource.saveQuizResult(resultModel);

      // Sync to Firestore if user is authenticated
      final firestoreDs = _firestoreDataSource;
      if (userId != null && userId.isNotEmpty && firestoreDs != null) {
        try {
          await firestoreDs.saveQuizResult(userId, resultModel);
          logger.debug(
            'Quiz result synced to Firestore',
            tag: 'QuizRepo',
          );
        } catch (e) {
          // Log but don't fail - local save succeeded
          logger.warning(
            'Failed to sync quiz result to Firestore',
            tag: 'QuizRepo',
            error: e,
          );
        }
      }

      // Mark daily challenge as completed if applicable
      if (quiz.sessionType == QuizSessionType.dailyChallenge && userId != null) {
        try {
          await _localDataSource.saveDailyChallengeCompletion(userId, DateTime.now());
        } catch (e) {
          logger.warning(
            'Failed to mark daily challenge as completed',
            tag: 'QuizRepo',
            error: e,
          );
        }
      }

      // Clear quiz progress
      await _localDataSource.clearSavedQuizProgress(userId ?? '');

      logger.info(
        'Quiz completed: ${quiz.score}/${quiz.totalQuestions}, XP: $totalXp, Session: ${quiz.sessionType.name}',
        tag: 'QuizRepo',
      );

      return Right(result);
    } catch (e, stackTrace) {
      logger.error(
        'Error completing quiz',
        tag: 'QuizRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(QuizFailure(message: 'Failed to complete quiz'));
    }
  }

  @override
  Future<Either<Failure, List<QuizResult>>> getQuizHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final results = await _localDataSource.getQuizHistory(userId, limit: limit);
      return Right(results.map((r) => r.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get quiz history'));
    }
  }

  @override
  Future<Either<Failure, QuizStatistics>> getQuizStatistics(String userId) async {
    try {
      final results = await _localDataSource.getQuizHistory(userId, limit: 1000);

      if (results.isEmpty) {
        return Right(QuizStatistics.empty());
      }

      // Calculate statistics
      var totalQuestions = 0;
      var correctAnswers = 0;
      var totalTimeMs = 0;
      var perfectScores = 0;
      final quizzesByMode = <QuizMode, int>{};
      final quizzesByDifficulty = <QuizDifficulty, int>{};

      for (final result in results) {
        totalQuestions += result.totalQuestions;
        correctAnswers += result.score;
        totalTimeMs += result.timeTakenMs;

        if (result.score == result.totalQuestions) {
          perfectScores++;
        }

        quizzesByMode[result.mode] = (quizzesByMode[result.mode] ?? 0) + 1;
        quizzesByDifficulty[result.difficulty] =
            (quizzesByDifficulty[result.difficulty] ?? 0) + 1;
      }

      final averageAccuracy = totalQuestions > 0
          ? (correctAnswers / totalQuestions) * 100
          : 0.0;

      // Calculate streak (consecutive days with completed quizzes)
      final sortedResults = List<QuizResultModel>.from(results)
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      var currentStreak = 0;
      var bestStreak = 0;
      DateTime? lastDate;

      for (final result in sortedResults) {
        final date = DateTime(
          result.completedAt.year,
          result.completedAt.month,
          result.completedAt.day,
        );

        if (lastDate == null) {
          currentStreak = 1;
          lastDate = date;
        } else {
          final difference = lastDate.difference(date).inDays;
          if (difference == 1) {
            currentStreak++;
            lastDate = date;
          } else if (difference > 1) {
            if (currentStreak > bestStreak) {
              bestStreak = currentStreak;
            }
            currentStreak = 1;
            lastDate = date;
          }
        }
      }

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }

      return Right(QuizStatistics(
        totalQuizzes: results.length,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        averageAccuracy: averageAccuracy,
        totalTimePlayed: Duration(milliseconds: totalTimeMs),
        perfectScores: perfectScores,
        quizzesByMode: quizzesByMode,
        quizzesByDifficulty: quizzesByDifficulty,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get quiz statistics'));
    }
  }

  @override
  Future<Either<Failure, Quiz>> getDailyChallenge() async {
    try {
      // Generate a consistent daily challenge based on the date
      final today = DateTime.now();

      // Select mode for today based on day of week
      final modes = [
        QuizMode.capitals,
        QuizMode.flags,
        QuizMode.maps,
        QuizMode.population,
        QuizMode.currencies,
        QuizMode.languages,
        QuizMode.mixed,
      ];
      final todayMode = modes[today.weekday - 1];

      // Generate quiz with medium difficulty
      return generateQuiz(
        mode: todayMode,
        difficulty: QuizDifficulty.medium,
        questionCount: 10,
      );
    } catch (e) {
      return const Left(QuizFailure(message: 'Failed to get daily challenge'));
    }
  }

  @override
  Future<Either<Failure, bool>> isDailyChallengeCompleted(String userId) async {
    try {
      final isCompleted = await _localDataSource.isDailyChallengeCompleted(
        userId,
        DateTime.now(),
      );
      return Right(isCompleted);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to check daily challenge'));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuizProgress(Quiz quiz) async {
    try {
      await _localDataSource.saveQuizProgress(QuizModel.fromEntity(quiz));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to save quiz progress'));
    }
  }

  @override
  Future<Either<Failure, Quiz?>> getSavedQuizProgress(String userId) async {
    try {
      final quiz = await _localDataSource.getSavedQuizProgress(userId);
      return Right(quiz?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to get quiz progress'));
    }
  }

  @override
  Future<Either<Failure, void>> clearSavedQuizProgress(String userId) async {
    try {
      await _localDataSource.clearSavedQuizProgress(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear quiz progress'));
    }
  }

  @override
  Future<Either<Failure, void>> syncQuizHistoryToCloud(String userId) async {
    final firestoreDs = _firestoreDataSource;
    if (firestoreDs == null) {
      return const Right(null); // No Firestore configured
    }

    try {
      // Get all local quiz history
      final localResults = await _localDataSource.getQuizHistory(
        userId,
        limit: 1000, // Sync up to 1000 results
      );

      if (localResults.isEmpty) {
        return const Right(null);
      }

      // Sync to Firestore
      await firestoreDs.syncQuizHistory(userId, localResults);

      logger.info(
        'Synced ${localResults.length} quiz results to Firestore',
        tag: 'QuizRepo',
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to sync quiz history'));
    }
  }

  @override
  Future<Either<Failure, List<QuizResult>>> restoreQuizHistoryFromCloud(
    String userId, {
    int limit = 50,
  }) async {
    final firestoreDs = _firestoreDataSource;
    if (firestoreDs == null) {
      return const Right([]); // No Firestore configured
    }

    try {
      // Get quiz history from Firestore
      final cloudResults = await firestoreDs.getQuizHistory(
        userId,
        limit: limit,
      );

      if (cloudResults.isEmpty) {
        return const Right([]);
      }

      // Save to local storage for offline access
      for (final result in cloudResults) {
        try {
          await _localDataSource.saveQuizResult(result);
        } catch (e) {
          // Continue even if one fails
          logger.warning(
            'Failed to save restored quiz result locally',
            tag: 'QuizRepo',
            error: e,
          );
        }
      }

      logger.info(
        'Restored ${cloudResults.length} quiz results from Firestore',
        tag: 'QuizRepo',
      );

      return Right(cloudResults.map((r) => r.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
        ServerFailure(message: 'Failed to restore quiz history'),
      );
    }
  }
}
