// API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String weatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  
  // Add your API key here from: https://openweathermap.org/api
  // Get a free API key and replace the value below
  static const String apiKey = '35e0b0fa6a082f91ade962ac8cb197b3';
  
  static const int requestTimeout = 30;
}

// App Constants
class AppConstants {
  static const String appName = 'Weather App';
  static const String defaultCity = 'Colombo';
}
