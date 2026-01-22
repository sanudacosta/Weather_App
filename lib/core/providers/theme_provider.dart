import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _storageService.isDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _storageService.setThemeMode(isDark);
    notifyListeners();
  }
}
