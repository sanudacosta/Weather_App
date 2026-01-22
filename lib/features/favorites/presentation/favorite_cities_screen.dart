import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/utils/weather_helper.dart';
import '../../../data/repositories/weather_repository.dart';

class FavoriteCitiesScreen extends StatefulWidget {
  const FavoriteCitiesScreen({super.key});

  @override
  State<FavoriteCitiesScreen> createState() => _FavoriteCitiesScreenState();
}

class _FavoriteCitiesScreenState extends State<FavoriteCitiesScreen> {
  final Map<String, dynamic> _cityWeatherData = {};
  final WeatherRepository _repository = WeatherRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoritesWeather();
  }

  Future<void> _loadFavoritesWeather() async {
    final favViewModel =
        Provider.of<FavoritesViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    for (final city in favViewModel.favoriteCities) {
      try {
        final weather = await _repository.getWeatherByCity(city);
        if (mounted) {
          setState(() {
            _cityWeatherData[city] = weather;
          });
        }
      } catch (e) {
        // Skip failed cities
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesViewModel>(
      builder: (context, favViewModel, child) {
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
                'Favorite Cities',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadFavoritesWeather,
                ),
              ],
            ),
            body: favViewModel.favoriteCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: const Icon(
                                  Icons.favorite_border,
                                  size: 100,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No favorite cities yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add cities to favorites from the home screen',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favViewModel.favoriteCities.length,
                        itemBuilder: (context, index) {
                          final city = favViewModel.favoriteCities[index];
                          final weather = _cityWeatherData[city];

                          return Dismissible(
                            key: Key(city),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            onDismissed: (direction) {
                              favViewModel.removeFavorite(city);
                              setState(() {
                                _cityWeatherData.remove(city);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$city removed from favorites'),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: _buildCityCard(context, city, weather),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }

  Widget _buildCityCard(BuildContext context, String city, dynamic weather) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Provider.of<HomeViewModel>(context, listen: false)
                .fetchWeatherByCity(city);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: weather == null
                ? Row(
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather.weatherDescription,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        WeatherHelper.getWeatherIcon(weather.weatherCondition),
                        style: const TextStyle(fontSize: 50),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
