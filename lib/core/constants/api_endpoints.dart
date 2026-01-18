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

  // Claude API (Anthropic)
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeMessages = '$claudeBaseUrl/messages';

  // Firebase Cloud Functions (placeholder - will be configured per project)
  static const String cloudFunctionsBaseUrl =
      'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net';

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
}
