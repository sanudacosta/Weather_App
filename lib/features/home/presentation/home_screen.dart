import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../favorites/viewmodels/favorites_viewmodel.dart';
import '../../forecast/presentation/forecast_screen.dart';
import '../../../shared/widgets/gradient_background.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadLastSearchedCity();
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
        ],
      ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white, size: 28),
                      onPressed: () {
                        // Show search dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to manage locations
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Manage locations',
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
        return _buildWeatherContent(viewModel.weather!);
    }
  }

  Widget _buildWeatherContent(weather) {
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
              color: Colors.white.withOpacity(0.25),
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
          _buildHourlyForecast(weather),
          
          const SizedBox(height: 24),
          
          // UV Index card
          _buildUVIndexCard(),
          
          const SizedBox(height: 24),
          
          // Daily forecast
          _buildDailyForecast(weather),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(weather) {
    // Simulated hourly data (in real app, this would come from API)
    final hours = ['1:30 pm', '2:30 pm', '3:30 pm', '4:30 pm', '5:30 pm', '6:10 pm'];
    final temps = [25, 24, 24, 23, 22, 0]; // 0 for sunset
    final rain = [0, 1, 1, 1, 2, 0];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Time labels and icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hours.length, (index) {
                return SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Text(
                        hours[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        index == hours.length - 1 
                            ? '🌅' 
                            : WeatherHelper.getWeatherIcon(weather.weatherCondition),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        index == hours.length - 1 ? 'Sunset' : '${temps[index]}°',
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
              size: Size(hours.length * 80.0, 60),
              painter: _TemperatureGraphPainter(temps.take(5).toList().cast<int>()),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Rain percentage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(hours.length, (index) {
                return SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rain[index]}%',
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
        color: Colors.white.withOpacity(0.25),
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

  Widget _buildDailyForecast(weather) {
    final days = ['Yesterday', 'Today', 'Friday'];
    final maxTemps = [25, 26, 27];
    final minTemps = [14, 16, 19];
    final rainChance = [0, 5, 24];
    
    return Column(
      children: List.generate(days.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  days[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (rainChance[index] > 0) ...[
                const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${rainChance[index]}%',
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
                WeatherHelper.getWeatherIcon(weather.weatherCondition),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              if (index == 2) 
                const Text('⛈️', style: TextStyle(fontSize: 28)),
              const Spacer(),
              Text(
                '${maxTemps[index]}° ${minTemps[index]}°',
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
