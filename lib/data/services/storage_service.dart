import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const String _lastSearchedCityKey = 'last_searched_city';
  static const String _themeKey = 'theme_mode';
  static const String _temperatureUnitKey = 'temperature_unit';
  
  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList(_favoriteCitiesKey);
    return citiesJson ?? [];
  }
  
  Future<void> addFavoriteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = await getFavoriteCities();
    
    if (!cities.contains(city)) {
      cities.add(city);
      await prefs.setStringList(_favoriteCitiesKey, cities);
    }
  }
  
  Future<void> removeFavoriteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = await getFavoriteCities();
    cities.remove(city);
    await prefs.setStringList(_favoriteCitiesKey, cities);
  }
  
  Future<String?> getLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSearchedCityKey);
  }
  
  Future<void> saveLastSearchedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSearchedCityKey, city);
  }
  
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
  
  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
  
  Future<bool> isCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_temperatureUnitKey) ?? true; // Default to Celsius
  }
  
  Future<void> setTemperatureUnit(bool isCelsius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_temperatureUnitKey, isCelsius);
  }
}
