import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class WeatherRepository {
  final ApiService _apiService;
  final LocationService _locationService;
  
  WeatherRepository({
    ApiService? apiService,
    LocationService? locationService,
  })  : _apiService = apiService ?? ApiService(),
        _locationService = locationService ?? LocationService();
  
  Future<Weather> getWeatherByCity(String city) async {
    try {
      final data = await _apiService.getCurrentWeather(city);
      return Weather.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Weather> getWeatherByLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get location');
      }
      
      final data = await _apiService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      return Weather.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Forecast> getForecastByCity(String city) async {
    try {
      final data = await _apiService.getForecast(city);
      return Forecast.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Forecast> getForecastByLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get location');
      }
      
      final data = await _apiService.getForecastByCoordinates(
        position.latitude,
        position.longitude,
      );
      return Forecast.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
