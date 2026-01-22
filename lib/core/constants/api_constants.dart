// API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String weatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  
  // Add your API key here from: https://openweathermap.org/api
  // Get a free API key and replace the value below
  static const String apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  
  static const int requestTimeout = 30;
}

// App Constants
class AppConstants {
  static const String appName = 'Weather App';
  static const String defaultCity = 'Colombo';
}
