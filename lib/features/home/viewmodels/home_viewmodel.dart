import 'package:flutter/foundation.dart';
import '../../../data/models/weather.dart';
import '../../../data/models/forecast.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/services/storage_service.dart';

enum WeatherState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final WeatherRepository _repository;
  final StorageService _storageService;

  HomeViewModel({
    WeatherRepository? repository,
    StorageService? storageService,
  })  : _repository = repository ?? WeatherRepository(),
        _storageService = storageService ?? StorageService();

  WeatherState _state = WeatherState.initial;
  Weather? _weather;
  Forecast? _forecast;
  String? _errorMessage;

  WeatherState get state => _state;
  Weather? get weather => _weather;
  Forecast? get forecast => _forecast;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) {
      _errorMessage = 'Please enter a city name';
      _state = WeatherState.error;
      notifyListeners();
      return;
    }

    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _repository.getWeatherByCity(city);
      _forecast = await _repository.getForecastByCity(city);
      await _storageService.saveLastSearchedCity(city);
      _state = WeatherState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = _parseError(e.toString());
      _weather = null;
      _forecast = null;
    }

    notifyListeners();
  }

  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _repository.getWeatherByLocation();
      _forecast = await _repository.getForecastByLocation();
      await _storageService.saveLastSearchedCity(_weather!.cityName);
      _state = WeatherState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = _parseError(e.toString());
      _weather = null;
      _forecast = null;
      rethrow;
    }

    notifyListeners();
  }

  Future<void> loadLastSearchedCity() async {
    _state = WeatherState.loading;
    notifyListeners();

    // Try to load weather by current location with 3 second timeout
    try {
      await fetchWeatherByLocation().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw Exception('Location timeout');
        },
      );
    } catch (e) {
      // Location failed or timed out, load last searched city or Colombo
      try {
        final lastCity = await _storageService.getLastSearchedCity();
        final cityToLoad =
            (lastCity != null && lastCity.isNotEmpty) ? lastCity : 'Colombo';
        await fetchWeatherByCity(cityToLoad);
      } catch (error) {
        // If everything fails, set error state
        _state = WeatherState.error;
        _errorMessage =
            'Failed to load weather data. Please check your internet connection.';
        notifyListeners();
      }
    }
  }

  String _parseError(String error) {
    if (error.contains('City not found')) {
      return 'City not found. Please check the name and try again.';
    } else if (error.contains('429') || error.contains('rate limit')) {
      return 'API rate limit exceeded. Please wait a few minutes or get a new API key from openweathermap.org';
    } else if (error.contains('Network error') ||
        error.contains('Failed to load')) {
      return 'Network error. Please check your internet connection and API key.';
    } else if (error.contains('401') || error.contains('Invalid API key')) {
      return 'Invalid API key. Please add a valid OpenWeatherMap API key.';
    } else if (error.contains('Location')) {
      return 'Unable to get your location. Please enable location services.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
