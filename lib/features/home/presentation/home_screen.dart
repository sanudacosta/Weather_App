import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../forecast/presentation/forecast_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../favorites/viewmodels/favorites_viewmodel.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/weather_card.dart';
import '../../../shared/widgets/weather_info_tile.dart';
import '../../../shared/widgets/search_bar.dart' as custom;
import '../../../shared/widgets/loading_and_error.dart';
import '../../../core/utils/weather_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load last searched city on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadLastSearchedCity();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final weatherCondition = viewModel.weather?.weatherCondition ?? 'clear';
        
        return GradientBackground(
          weatherCondition: weatherCondition,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Weather App',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    viewModel.weather != null &&
                            context.watch<FavoritesViewModel>().isFavorite(viewModel.weather!.cityName)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (viewModel.weather != null) {
                      final favViewModel = context.read<FavoritesViewModel>();
                      final cityName = viewModel.weather!.cityName;
                      
                      if (favViewModel.isFavorite(cityName)) {
                        favViewModel.removeFavorite(cityName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$cityName removed from favorites')),
                        );
                      } else {
                        favViewModel.addFavorite(cityName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$cityName added to favorites')),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: context.read<FavoritesViewModel>(),
                            child: const FavoritesScreen(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                custom.SearchBar(
                  controller: _searchController,
                  onSearch: (city) {
                    viewModel.fetchWeatherByCity(city);
                  },
                  onLocationTap: () {
                    viewModel.fetchWeatherByLocation();
                  },
                ),
                Expanded(
                  child: _buildBody(viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBody(HomeViewModel viewModel) {
    switch (viewModel.state) {
      case WeatherState.initial:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                size: 64,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Search for a city or use your location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
        
      case WeatherState.loading:
        return const LoadingWidget(message: 'Loading weather data...');
        
      case WeatherState.error:
        return ErrorWidget(
          message: viewModel.errorMessage ?? 'An error occurred',
          onRetry: () {
            if (_searchController.text.isNotEmpty) {
              viewModel.fetchWeatherByCity(_searchController.text);
            } else {
              viewModel.fetchWeatherByLocation();
            }
          },
        );
        
      case WeatherState.loaded:
        return _buildWeatherContent(viewModel.weather!);
    }
  }
  
  Widget _buildWeatherContent(weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // City name
          Text(
            weather.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Weather icon and temperature
          WeatherCard(
            child: Column(
              children: [
                Text(
                  WeatherHelper.getWeatherIcon(weather.weatherCondition),
                  style: const TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 16),
                Text(
                  '${weather.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weather.weatherDescription.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Feels like ${weather.feelsLike.round()}°',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weather details grid
          WeatherCard(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                WeatherInfoTile(
                  icon: Icons.thermostat,
                  label: 'Min / Max',
                  value: '${weather.tempMin.round()}° / ${weather.tempMax.round()}°',
                ),
                WeatherInfoTile(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                WeatherInfoTile(
                  icon: Icons.air,
                  label: 'Wind Speed',
                  value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                ),
                WeatherInfoTile(
                  icon: Icons.compress,
                  label: 'Pressure',
                  value: '${weather.pressure} hPa',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Forecast button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForecastScreen(
                      cityName: weather.cityName,
                      weatherCondition: weather.weatherCondition,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('5-Day Forecast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Additional info
          WeatherCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Visibility',
                  '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildInfoColumn(
                  'Cloudiness',
                  '${weather.cloudiness}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
