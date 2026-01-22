import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/weather_card.dart';
import '../../../data/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final isDark = await _storageService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      weatherCondition: 'clear',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WeatherCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Enable dark theme',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    value: _isDarkMode,
                    activeColor: Colors.white,
                    onChanged: (value) async {
                      setState(() {
                        _isDarkMode = value;
                      });
                      await _storageService.setThemeMode(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            WeatherCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info, color: Colors.white),
                    title: const Text(
                      'Version',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cloud, color: Colors.white),
                    title: const Text(
                      'Data Source',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'OpenWeatherMap API',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
