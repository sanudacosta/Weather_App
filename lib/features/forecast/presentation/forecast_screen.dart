import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forecast_viewmodel.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/weather_card.dart';
import '../../../shared/widgets/loading_and_error.dart';
import '../../../core/utils/weather_helper.dart';
import '../../../core/utils/date_time_helper.dart';

class ForecastScreen extends StatelessWidget {
  final String cityName;
  final String weatherCondition;
  
  const ForecastScreen({
    super.key,
    required this.cityName,
    required this.weatherCondition,
  });
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForecastViewModel()..fetchForecast(cityName),
      child: GradientBackground(
        weatherCondition: weatherCondition,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '5-Day Forecast - $cityName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Consumer<ForecastViewModel>(
            builder: (context, viewModel, child) {
              switch (viewModel.state) {
                case ForecastState.initial:
                case ForecastState.loading:
                  return const LoadingWidget(message: 'Loading forecast...');
                  
                case ForecastState.error:
                  return ErrorWidget(
                    message: viewModel.errorMessage ?? 'An error occurred',
                    onRetry: () => viewModel.fetchForecast(cityName),
                  );
                  
                case ForecastState.loaded:
                  return _buildForecastList(viewModel);
              }
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildForecastList(ForecastViewModel viewModel) {
    final groupedForecasts = viewModel.groupForecastByDay();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedForecasts.length,
      itemBuilder: (context, index) {
        final dayForecasts = groupedForecasts[index];
        final firstForecast = dayForecasts.first;
        
        return WeatherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateTimeHelper.getDayOfWeek(firstForecast.dateTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateTimeHelper.formatDate(firstForecast.dateTime),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Hourly forecasts
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dayForecasts.length,
                  itemBuilder: (context, i) {
                    final forecast = dayForecasts[i];
                    return _buildHourlyForecastItem(forecast);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHourlyForecastItem(forecast) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            DateTimeHelper.formatTime(forecast.dateTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            WeatherHelper.getWeatherIcon(forecast.weatherCondition),
            style: const TextStyle(fontSize: 28),
          ),
          Text(
            '${forecast.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
