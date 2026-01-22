import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../favorites/viewmodels/favorites_viewmodel.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_and_error.dart';
import '../../../core/utils/weather_helper.dart';
import '../../../data/services/city_autocomplete_service.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadLastSearchedCity();
      final favViewModel = Provider.of<FavoritesViewModel>(context, listen: false);
      favViewModel.loadFavorites();
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
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: _buildDrawer(context),
          body: GradientBackground(
            weatherCondition: viewModel.weather?.weatherCondition ?? 'clear',
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, viewModel),
                  Expanded(
                    child: _buildBody(viewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            viewModel.weather?.cityName ?? 'Loading...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Consumer<FavoritesViewModel>(
            builder: (context, favViewModel, child) {
              final isFavorite = viewModel.weather != null && 
                  favViewModel.favoriteCities.contains(viewModel.weather!.cityName);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: viewModel.weather == null ? null : () async {
                  if (isFavorite) {
                    await favViewModel.removeFavorite(viewModel.weather!.cityName);
                  } else {
                    await favViewModel.addFavorite(viewModel.weather!.cityName);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () => _showSearchDialog(context, viewModel),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, HomeViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchBottomSheet(viewModel: viewModel),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue.shade400.withOpacity(0.95),
      child: Consumer<FavoritesViewModel>(
        builder: (context, favViewModel, child) {
          return Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: favViewModel.favoriteCities.isEmpty
                    ? const Center(
                        child: Text(
                          'No favorite cities yet',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: favViewModel.favoriteCities.length,
                        itemBuilder: (context, index) {
                          final city = favViewModel.favoriteCities[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.white),
                            title: Text(
                              city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.cloud, color: Colors.white),
                            onTap: () {
                              Navigator.pop(context);
                              Provider.of<HomeViewModel>(context, listen: false)
                                  .fetchWeatherByCity(city);
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(HomeViewModel viewModel) {
    switch (viewModel.state) {
      case WeatherState.initial:
        return const Center(
          child: Text(
            'Search for a city to get weather data',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        );

      case WeatherState.loading:
        return const LoadingWidget();

      case WeatherState.error:
        return WeatherErrorWidget(
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
        return _buildWeatherContent(viewModel);
    }
  }

  Widget _buildWeatherContent(HomeViewModel viewModel) {
    final weather = viewModel.weather!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Main weather display
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Temperature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.weatherDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${weather.tempMax.round()}° / ${weather.tempMin.round()}° Feels like ${weather.feelsLike.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right side - Weather icon
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    WeatherHelper.getWeatherIcon(weather.weatherCondition),
                    style: const TextStyle(fontSize: 100),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Weather description card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${weather.weatherDescription}. Highs ${weather.tempMax.round()} to ${(weather.tempMax + 2).round()}°C and lows ${weather.tempMin.round()} to ${(weather.tempMin + 2).round()}°C.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Hourly forecast section
          _buildHourlyForecast(viewModel),
          
          const SizedBox(height: 24),
          
          // UV Index card
          _buildUVIndexCard(),
          
          const SizedBox(height: 24),
          
          // Daily forecast
          _buildDailyForecast(viewModel),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(HomeViewModel viewModel) {
    final forecast = viewModel.forecast;
    if (forecast == null || forecast.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get next 6 hourly forecasts (3-hour intervals)
    final hourlyItems = forecast.items.take(6).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Time labels and icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hourlyItems.length, (index) {
                final item = hourlyItems[index];
                final hour = item.dateTime.hour;
                final minute = item.dateTime.minute;
                final period = hour >= 12 ? 'pm' : 'am';
                final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                
                return SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Text(
                        '$displayHour:${minute.toString().padLeft(2, '0')} $period',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        WeatherHelper.getWeatherIcon(item.weatherCondition),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Temperature graph line
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size(hourlyItems.length * 80.0, 60),
              painter: _TemperatureGraphPainter(
                hourlyItems.map((item) => item.temperature.round()).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Rain percentage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hourlyItems.length, (index) {
                final item = hourlyItems[index];
                return SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${(item.pop * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUVIndexCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protect your Skin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'UV is extreme. Limit sun exposure if possible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '11',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(HomeViewModel viewModel) {
    final forecast = viewModel.forecast;
    if (forecast == null || forecast.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by day and get daily summaries
    final dailyForecasts = <String, List<dynamic>>{}; 
    for (var item in forecast.items) {
      final dateKey = '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = [];
      }
      dailyForecasts[dateKey]!.add(item);
    }

    final days = dailyForecasts.keys.take(5).toList();
    final now = DateTime.now();
    
    return Column(
      children: List.generate(days.length.clamp(0, 5), (index) {
        final dateKey = days[index];
        final items = dailyForecasts[dateKey]!;
        final firstItem = items[0];
        final date = firstItem.dateTime;
        
        // Calculate day label
        String dayLabel;
        if (date.year == now.year && date.month == now.month) {
          if (date.day == now.day) {
            dayLabel = 'Today';
          } else if (date.day == now.day - 1) {
            dayLabel = 'Yesterday';
          } else if (date.day == now.day + 1) {
            dayLabel = 'Tomorrow';
          } else {
            dayLabel = _getDayName(date.weekday);
          }
        } else {
          dayLabel = _getDayName(date.weekday);
        }
        
        // Calculate max/min temps from all items in the day
        final temps = items.map((item) => item.temperature).toList();
        final maxTemp = temps.reduce((a, b) => a > b ? a : b);
        final minTemp = temps.reduce((a, b) => a < b ? a : b);
        
        // Calculate average rain chance
        final avgRain = items.map((item) => item.pop).reduce((a, b) => a + b) / items.length;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  dayLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (avgRain > 0.1) ...[
                const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(avgRain * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ] else
                const SizedBox(width: 60),
              const Spacer(),
              Text(
                WeatherHelper.getWeatherIcon(firstItem.weatherCondition),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              const Spacer(),
              Text(
                '${maxTemp.round()}° ${minTemp.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}

// Custom painter for temperature graph
class _TemperatureGraphPainter extends CustomPainter {
  final List<int> temperatures;

  _TemperatureGraphPainter(this.temperatures);

  @override
  void paint(Canvas canvas, Size size) {
    if (temperatures.length < 2) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    // Calculate points
    final maxTemp = temperatures.reduce((a, b) => a > b ? a : b).toDouble();
    final minTemp = temperatures.reduce((a, b) => a < b ? a : b).toDouble();
    final tempRange = maxTemp - minTemp;

    for (var i = 0; i < temperatures.length; i++) {
      final x = (size.width / (temperatures.length - 1)) * i;
      final normalizedTemp = tempRange == 0 ? 0.5 : (temperatures[i] - minTemp) / tempRange;
      final y = size.height - (normalizedTemp * size.height * 0.7) - size.height * 0.15;
      points.add(Offset(x, y));
    }

    // Draw line
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Search Bottom Sheet Widget
class _SearchBottomSheet extends StatefulWidget {
  final HomeViewModel viewModel;

  const _SearchBottomSheet({required this.viewModel});

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final CityAutocompleteService _autocompleteService = CityAutocompleteService();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _autocompleteService.searchCities(query);
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade400,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Search City',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter city name...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _searchCities,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.viewModel.fetchWeatherByCity(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_suggestions.isNotEmpty)
              LimitedBox(
                maxHeight: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final city = _suggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.white),
                      title: Text(
                        city.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${city.state ?? ''} ${city.country}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      onTap: () {
                        widget.viewModel.fetchWeatherByCity(city.name);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
