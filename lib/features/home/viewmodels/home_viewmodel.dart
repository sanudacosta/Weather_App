import 'package:flutter/foundation.dart';
import '../../../data/models/weather.dart';
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
  String? _errorMessage;
  
  WeatherState get state => _state;
  Weather? get weather => _weather;
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
      await _storageService.saveLastSearchedCity(city);
      _state = WeatherState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = _parseError(e.toString());
      _weather = null;
    }
    
    notifyListeners();
  }
  
  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _weather = await _repository.getWeatherByLocation();
      await _storageService.saveLastSearchedCity(_weather!.cityName);
      _state = WeatherState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = _parseError(e.toString());
      _weather = null;
    }
    
    notifyListeners();
  }
  
  Future<void> loadLastSearchedCity() async {
    final lastCity = await _storageService.getLastSearchedCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      await fetchWeatherByCity(lastCity);
    }
  }
  
  String _parseError(String error) {
    if (error.contains('City not found')) {
      return 'City not found. Please check the name and try again.';
    } else if (error.contains('Network error')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('Location')) {
      return 'Unable to get your location. Please enable location services.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
