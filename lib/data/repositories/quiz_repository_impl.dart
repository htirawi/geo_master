import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/i_country_repository.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../datasources/local/quiz_local_datasource.dart';
import '../models/quiz_model.dart';

/// Quiz repository implementation
class QuizRepositoryImpl implements IQuizRepository {
  QuizRepositoryImpl({
    required IQuizLocalDataSource localDataSource,
    required ICountryRepository countryRepository,
  })  : _localDataSource = localDataSource,
        _countryRepository = countryRepository;

  final IQuizLocalDataSource _localDataSource;
  final ICountryRepository _countryRepository;
  final _uuid = const Uuid();
  final _random = Random();

  @override
  Future<Either<Failure, Quiz>> generateQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    String? region,
    int questionCount = 10,
  }) async {
    try {
      // Get countries for quiz generation
      final countriesResult = await _countryRepository.getAllCountries();
      return countriesResult.fold(
        (failure) => Left(failure),
        (allCountries) async {
          // Filter by region if specified
          var countries = allCountries;
          if (region != null) {
            countries = allCountries
                .where((c) => c.region.toLowerCase() == region.toLowerCase())
                .toList();
          }

          if (countries.length < 4) {
            return Left(QuizFailure.noQuestionsAvailable());
          }

          // Generate questions based on mode
          final questions = <QuizQuestion>[];
          final usedCountries = <String>{};

          for (var i = 0; i < questionCount && usedCountries.length < countries.length; i++) {
            // Select a country that hasn't been used
            Country targetCountry;
            do {
              targetCountry = countries[_random.nextInt(countries.length)];
            } while (usedCountries.contains(targetCountry.code));
            usedCountries.add(targetCountry.code);

            // Generate question based on mode
            final question = _generateQuestion(
              mode: mode == QuizMode.mixed
                  ? QuizMode.values[_random.nextInt(QuizMode.values.length - 1)]
                  : mode,
              targetCountry: targetCountry,
              allCountries: countries,
              difficulty: difficulty,
              questionIndex: i,
            );

            if (question != null) {
              questions.add(question);
            }
          }

          if (questions.isEmpty) {
            return Left(QuizFailure.noQuestionsAvailable());
          }

          final quiz = Quiz(
            id: _uuid.v4(),
            mode: mode,
            difficulty: difficulty,
            region: region,
            questions: questions,
            startedAt: DateTime.now(),
          );

          logger.debug(
            'Generated quiz with ${questions.length} questions',
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
      return Left(QuizFailure(message: 'Failed to generate quiz: $e'));
    }
  }

  QuizQuestion? _generateQuestion({
    required QuizMode mode,
    required Country targetCountry,
    required List<Country> allCountries,
    required QuizDifficulty difficulty,
    required int questionIndex,
  }) {
    final optionsCount = difficulty.optionsCount;

    // Get wrong options
    final wrongOptions = allCountries
        .where((c) => c.code != targetCountry.code)
        .toList()
      ..shuffle(_random);

    switch (mode) {
      case QuizMode.capitals:
        if (targetCountry.capital == null) return null;
        final options = [
          targetCountry.capital!,
          ...wrongOptions
              .where((c) => c.capital != null)
              .take(optionsCount - 1)
              .map((c) => c.capital!),
        ]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          question: 'What is the capital of ${targetCountry.name}?',
          questionArabic: 'ما هي عاصمة ${targetCountry.nameArabic}؟',
          correctAnswer: targetCountry.capital!,
          options: options,
          countryCode: targetCountry.code,
        );

      case QuizMode.flags:
        final options = [
          targetCountry.name,
          ...wrongOptions.take(optionsCount - 1).map((c) => c.name),
        ]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          question: 'Which country does this flag belong to?',
          questionArabic: 'لأي دولة ينتمي هذا العلم؟',
          correctAnswer: targetCountry.name,
          options: options,
          imageUrl: targetCountry.flagUrl,
          countryCode: targetCountry.code,
        );

      case QuizMode.maps:
        final options = [
          targetCountry.name,
          ...wrongOptions.take(optionsCount - 1).map((c) => c.name),
        ]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          question: 'Identify this country on the map',
          questionArabic: 'حدد هذه الدولة على الخريطة',
          correctAnswer: targetCountry.name,
          options: options,
          countryCode: targetCountry.code,
          metadata: {
            'latitude': targetCountry.coordinates.latitude,
            'longitude': targetCountry.coordinates.longitude,
          },
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

        // Format populations for display
        String formatPop(int pop) {
          if (pop >= 1000000000) {
            return '${(pop / 1000000000).toStringAsFixed(1)}B';
          } else if (pop >= 1000000) {
            return '${(pop / 1000000).toStringAsFixed(1)}M';
          } else if (pop >= 1000) {
            return '${(pop / 1000).toStringAsFixed(1)}K';
          }
          return pop.toString();
        }

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          question: 'What is the approximate population of ${targetCountry.name}?',
          questionArabic: 'ما هو عدد سكان ${targetCountry.nameArabic} تقريباً؟',
          correctAnswer: formatPop(targetCountry.population),
          options: popOptions.map((c) => formatPop(c.population)).toList(),
          countryCode: targetCountry.code,
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
          question: 'What currency is used in ${targetCountry.name}?',
          questionArabic: 'ما هي العملة المستخدمة في ${targetCountry.nameArabic}؟',
          correctAnswer: '${currency.name} (${currency.symbol})',
          options: options,
          countryCode: targetCountry.code,
        );

      case QuizMode.languages:
        if (targetCountry.languages.isEmpty) return null;
        final language = targetCountry.languages.first;
        final wrongLanguages = wrongOptions
            .where((c) => c.languages.isNotEmpty)
            .take(optionsCount - 1)
            .map((c) => c.languages.first)
            .toList();

        final options = [language, ...wrongLanguages]..shuffle(_random);

        return QuizQuestion(
          id: _uuid.v4(),
          mode: mode,
          question: 'What is an official language of ${targetCountry.name}?',
          questionArabic: 'ما هي اللغة الرسمية في ${targetCountry.nameArabic}؟',
          correctAnswer: language,
          options: options,
          countryCode: targetCountry.code,
        );

      case QuizMode.mixed:
        // This case is handled by selecting a random mode above
        return null;
    }
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
      return Left(QuizFailure(message: 'Failed to submit answer: $e'));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> completeQuiz(Quiz quiz) async {
    try {
      // Calculate XP based on performance
      const baseXp = 10;
      final correctAnswersXp = quiz.score * 10;
      final difficultyMultiplier = quiz.difficulty.xpMultiplier;
      final perfectBonus = quiz.isPerfectScore ? 50 : 0;
      final speedBonus = quiz.timeElapsed.inSeconds < (quiz.totalQuestions * 10) ? 25 : 0;

      final totalXp = ((baseXp + correctAnswersXp + perfectBonus + speedBonus) *
              difficultyMultiplier)
          .round();

      final result = QuizResult(
        id: _uuid.v4(),
        quizId: quiz.id,
        userId: '', // Will be filled by the caller
        mode: quiz.mode,
        difficulty: quiz.difficulty,
        score: quiz.score,
        totalQuestions: quiz.totalQuestions,
        accuracy: quiz.accuracy,
        timeTaken: quiz.timeElapsed,
        xpEarned: totalXp,
        completedAt: DateTime.now(),
        answers: quiz.answers,
      );

      // Save result locally
      await _localDataSource.saveQuizResult(QuizResultModel.fromEntity(result));

      // Clear quiz progress
      await _localDataSource.clearSavedQuizProgress('');

      logger.info(
        'Quiz completed: ${quiz.score}/${quiz.totalQuestions}, XP: $totalXp',
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
      return Left(QuizFailure(message: 'Failed to complete quiz: $e'));
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
      return Left(CacheFailure(message: 'Failed to get quiz history: $e'));
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
      return Left(CacheFailure(message: 'Failed to get quiz statistics: $e'));
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
      return Left(QuizFailure(message: 'Failed to get daily challenge: $e'));
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
      return Left(CacheFailure(message: 'Failed to check daily challenge: $e'));
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
      return Left(CacheFailure(message: 'Failed to save quiz progress: $e'));
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
      return Left(CacheFailure(message: 'Failed to get quiz progress: $e'));
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
      return Left(CacheFailure(message: 'Failed to clear quiz progress: $e'));
    }
  }
}
