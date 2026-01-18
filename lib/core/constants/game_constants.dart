/// Game and gamification constants
abstract final class GameConstants {
  // XP System
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerQuizCompletion = 50;
  static const int xpPerPerfectQuiz = 100;
  static const int xpPerDailyChallenge = 75;
  static const int xpPerCountryLearned = 25;
  static const int xpPerAchievement = 50;

  // XP Multipliers
  static const double streakMultiplier3Days = 1.2;
  static const double streakMultiplier7Days = 1.5;
  static const double streakMultiplier30Days = 2.0;
  static const double hardDifficultyMultiplier = 1.5;
  static const double perfectScoreMultiplier = 2.0;

  // Level System
  static const int baseXpPerLevel = 100;
  static const double levelXpGrowthRate = 1.2;
  static const int maxLevel = 100;

  // Streak System
  static const int streakResetHours = 48; // Grace period
  static const int maxStreakFreezePerMonth = 2; // Premium: unlimited

  // Quiz Settings
  static const int defaultQuizQuestions = 10;
  static const int quickQuizQuestions = 5;
  static const int challengeQuizQuestions = 20;
  static const int timedQuizSecondsPerQuestion = 15;
  static const int totalTimeEasyMinutes = 10;
  static const int totalTimeMediumMinutes = 7;
  static const int totalTimeHardMinutes = 5;

  // Difficulty Settings
  static const int easyOptionsCount = 3;
  static const int mediumOptionsCount = 4;
  static const int hardOptionsCount = 5;

  // Daily Challenge
  static const int dailyChallengeRefreshHour = 0; // Midnight UTC
  static const int dailyChallengeXpBonus = 50;

  // Achievement Thresholds
  static const List<int> countriesLearnedMilestones = [
    10,
    25,
    50,
    100,
    150,
    195,
  ];
  static const List<int> quizzesCompletedMilestones = [
    10,
    50,
    100,
    500,
    1000,
  ];
  static const List<int> streakDayMilestones = [3, 7, 14, 30, 60, 100, 365];
  static const List<int> perfectQuizMilestones = [1, 5, 10, 25, 50, 100];

  // Leaderboard
  static const int leaderboardTopCount = 100;
  static const int leaderboardRefreshMinutes = 15;

  // Rate Limiting
  static const int maxAiMessagesPerDay = 50; // Free tier
  static const int maxAiMessagesPerDayPremium = 500;

  // Quiz Modes
  static const List<String> quizModes = [
    'capitals',
    'flags',
    'maps',
    'populations',
    'currencies',
    'languages',
    'regions',
    'mixed',
  ];

  // Regions
  static const List<String> regions = [
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
  ];

  // Total Countries
  static const int totalCountries = 195;

  // Subscription Features
  static const int freeQuizzesPerDay = 5;
  static const int freeAiMessagesPerDay = 10;
  static const bool freeAdsEnabled = true;
  static const bool freeOfflineAccess = false;
}
