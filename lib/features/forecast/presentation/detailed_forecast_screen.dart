import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/utils/weather_helper.dart';

class DetailedForecastScreen extends StatelessWidget {
  const DetailedForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final forecast = viewModel.forecast;
        final weather = viewModel.weather;

        return GradientBackground(
          weatherCondition: weather?.weatherCondition ?? 'clear',
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
                '5-Day Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: forecast == null || forecast.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Loading forecast data...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : _buildForecastList(forecast),
          ),
        );
      },
    );
  }

  Widget _buildForecastList(forecast) {
    // Group by day
    final dailyForecasts = <String, List<dynamic>>{};
    for (var item in forecast.items) {
      final dateKey =
          '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = [];
      }
      dailyForecasts[dateKey]!.add(item);
    }

    final days = dailyForecasts.keys.take(5).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dateKey = days[index];
        final items = dailyForecasts[dateKey]!;
        final firstItem = items[0];
        final date = firstItem.dateTime;

        // Calculate max/min temps
        final temps = items.map((item) => item.temperature).toList();
        final maxTemp = temps.reduce((a, b) => a > b ? a : b);
        final minTemp = temps.reduce((a, b) => a < b ? a : b);

        // Calculate average rain chance
        final avgRain = items.map((item) => item.pop).reduce((a, b) => a + b) /
            items.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Row(
                children: [
                  Text(
                    _getDayLabel(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather icon and temps
              Row(
                children: [
                  Text(
                    WeatherHelper.getWeatherIcon(firstItem.weatherCondition),
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.weatherDescription.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${maxTemp.round()}° / ${minTemp.round()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              // Hourly details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn(
                    Icons.water_drop,
                    '${(avgRain * 100).round()}%',
                    'Rain',
                  ),
                  _buildInfoColumn(
                    Icons.air,
                    '${firstItem.windSpeed.toStringAsFixed(1)} m/s',
                    'Wind',
                  ),
                  _buildInfoColumn(
                    Icons.opacity,
                    '${firstItem.humidity}%',
                    'Humidity',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month) {
      if (date.day == now.day) return 'Today';
      if (date.day == now.day + 1) return 'Tomorrow';
    }
    return _getDayName(date.weekday);
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
