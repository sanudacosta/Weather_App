class Forecast {
  final String cityName;
  final List<ForecastItem> items;
  
  Forecast({
    required this.cityName,
    required this.items,
  });
  
  factory Forecast.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    final items = list.map((item) => ForecastItem.fromJson(item)).toList();
    
    return Forecast(
      cityName: json['city']['name'] ?? '',
      items: items,
    );
  }
}

class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final String weatherCondition;
  final String weatherDescription;
  final String weatherIcon;
  final double windSpeed;
  final int cloudiness;
  final double pop; // Probability of precipitation
  
  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.weatherCondition,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.windSpeed,
    required this.cloudiness,
    required this.pop,
  });
  
  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: json['main']['pressure'] as int,
      weatherCondition: json['weather'][0]['main'] ?? '',
      weatherDescription: json['weather'][0]['description'] ?? '',
      weatherIcon: json['weather'][0]['icon'] ?? '',
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cloudiness: json['clouds']['all'] ?? 0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
