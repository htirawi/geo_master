/// Route path constants
abstract final class Routes {
  // Root routes
  static const String splash = '/';
  static const String languageSelection = '/language';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String emailAuth = '/auth/email';
  static const String personalization = '/personalization';

  // Main app routes (bottom navigation)
  static const String home = '/home';
  static const String explore = '/explore';
  static const String countryExplorer = explore; // alias
  static const String quiz = '/quiz';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // Country routes
  static const String countryDetail = '/country/:code';
  static const String countryMap = '/country/:code/map';

  // Quiz routes
  static const String quizModeSelection = '/quiz/select';
  static const String quizGame = '/quiz/game';
  static const String quizResults = '/quiz/results';

  // AI Tutor routes
  static const String aiTutor = '/ai-tutor';

  // Gamification routes
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';

  // Settings routes
  static const String settings = '/settings';
  static const String settingsAccount = '/settings/account';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsPrivacy = '/settings/privacy';

  // Legal routes
  static const String termsOfService = '/terms';
  static const String privacyPolicy = '/privacy';

  // Subscription routes
  static const String subscription = '/subscription';
  static const String paywall = '/paywall';

  // Helper method to build country detail route
  static String countryDetailPath(String code) => '/country/$code';

  // Helper method to build country map route
  static String countryMapPath(String code) => '/country/$code/map';
}

/// Route names for named navigation
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String languageSelection = 'languageSelection';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String emailAuth = 'emailAuth';
  static const String personalization = 'personalization';
  static const String home = 'home';
  static const String explore = 'explore';
  static const String quiz = 'quiz';
  static const String stats = 'stats';
  static const String profile = 'profile';
  static const String countryDetail = 'countryDetail';
  static const String countryMap = 'countryMap';
  static const String quizModeSelection = 'quizModeSelection';
  static const String quizGame = 'quizGame';
  static const String quizResults = 'quizResults';
  static const String aiTutor = 'aiTutor';
  static const String achievements = 'achievements';
  static const String leaderboard = 'leaderboard';
  static const String settings = 'settings';
  static const String subscription = 'subscription';
  static const String paywall = 'paywall';
}
