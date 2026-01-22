import 'package:flutter/foundation.dart';
import '../../../data/models/forecast.dart';
import '../../../data/repositories/weather_repository.dart';

enum ForecastState { initial, loading, loaded, error }

class ForecastViewModel extends ChangeNotifier {
  final WeatherRepository _repository;
  
  ForecastViewModel({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();
  
  ForecastState _state = ForecastState.initial;
  Forecast? _forecast;
  String? _errorMessage;
  
  ForecastState get state => _state;
  Forecast? get forecast => _forecast;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchForecast(String city) async {
    _state = ForecastState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _forecast = await _repository.getForecastByCity(city);
      _state = ForecastState.loaded;
    } catch (e) {
      _state = ForecastState.error;
      _errorMessage = 'Failed to load forecast data';
      _forecast = null;
    }
    
    notifyListeners();
  }
  
  List<List<ForecastItem>> groupForecastByDay() {
    if (_forecast == null) return [];
    
    final Map<String, List<ForecastItem>> grouped = {};
    
    for (final item in _forecast!.items) {
      final date = '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }
    
    return grouped.values.toList();
  }
}
