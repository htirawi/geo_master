/// API endpoint constants
abstract final class ApiEndpoints {
  // REST Countries API (free, no key required)
  static const String restCountriesBaseUrl = 'https://restcountries.com/v3.1';
  static const String restCountriesAll = '$restCountriesBaseUrl/all';
  static const String restCountriesByCode = '$restCountriesBaseUrl/alpha';
  static const String restCountriesByRegion = '$restCountriesBaseUrl/region';
  static const String restCountriesByName = '$restCountriesBaseUrl/name';

  // OpenWeatherMap API
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String weatherCurrent = '$weatherBaseUrl/weather';
  static const String weatherForecast = '$weatherBaseUrl/forecast';

  // Claude API (Anthropic)
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeMessages = '$claudeBaseUrl/messages';

  // Firebase Cloud Functions - configured via environment variable
  // Use: --dart-define=CLOUD_FUNCTIONS_URL=https://your-region-your-project.cloudfunctions.net
  static const String cloudFunctionsBaseUrl = String.fromEnvironment(
    'CLOUD_FUNCTIONS_URL',
    defaultValue: '',
  );

  // Wikipedia REST API (free, no key required)
  static const String wikipediaBaseUrl = 'https://en.wikipedia.org/api/rest_v1';
  static const String wikipediaSummary = '$wikipediaBaseUrl/page/summary';
  static const String wikipediaMedia = '$wikipediaBaseUrl/page/media-list';
  static const String wikipediaRelated = '$wikipediaBaseUrl/page/related';

  // Arabic Wikipedia
  static const String wikipediaArabicBaseUrl = 'https://ar.wikipedia.org/api/rest_v1';
  static const String wikipediaArabicSummary = '$wikipediaArabicBaseUrl/page/summary';

  // Unsplash API
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
  static const String unsplashSearch = '$unsplashBaseUrl/search/photos';
  static const String unsplashPhotos = '$unsplashBaseUrl/photos';
  static const String unsplashRandom = '$unsplashBaseUrl/photos/random';

  // YouTube Data API v3
  static const String youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String youtubeSearch = '$youtubeBaseUrl/search';
  static const String youtubeVideos = '$youtubeBaseUrl/videos';
  static const String youtubeChannels = '$youtubeBaseUrl/channels';

  // NewsAPI
  static const String newsBaseUrl = 'https://newsapi.org/v2';
  static const String newsEverything = '$newsBaseUrl/everything';
  static const String newsTopHeadlines = '$newsBaseUrl/top-headlines';
  static const String newsSources = '$newsBaseUrl/top-headlines/sources';

  // Exchange Rate API (free tier)
  static const String exchangeRateBaseUrl = 'https://api.exchangerate-api.com/v4';
  static const String exchangeRateLatest = '$exchangeRateBaseUrl/latest';

  // Open Exchange Rates API (alternative)
  static const String openExchangeBaseUrl = 'https://openexchangerates.org/api';
  static const String openExchangeLatest = '$openExchangeBaseUrl/latest.json';

  // WorldTime API (free, no key required)
  static const String worldTimeBaseUrl = 'https://worldtimeapi.org/api';
  static const String worldTimeTimezone = '$worldTimeBaseUrl/timezone';
  static const String worldTimeIp = '$worldTimeBaseUrl/ip';

  // TimeZoneDB API (alternative)
  static const String timezoneDbBaseUrl = 'https://api.timezonedb.com/v2.1';
  static const String timezoneDbGetZone = '$timezoneDbBaseUrl/get-time-zone';

  // Request Fields for REST Countries
  static const String restCountriesFields =
      'cca2,cca3,name,capital,region,subregion,population,area,'
      'languages,currencies,flags,coatOfArms,latlng,borders,timezones,'
      'continents,unMember,landlocked,car';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Rate Limiting
  static const int unsplashRateLimit = 50; // per hour for demo
  static const int youtubeQuotaDaily = 10000; // units per day
  static const int newsApiRequestsPerDay = 100; // free tier
}
