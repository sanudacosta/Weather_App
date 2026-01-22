import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final String weatherCondition;
  
  const GradientBackground({
    super.key,
    required this.child,
    this.weatherCondition = 'clear',
  });
  
  List<Color> _getGradientColors(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return [
          const Color(0xFF4A90E2),
          const Color(0xFF50B7F5),
          const Color(0xFF87CEEB),
        ];
      case 'clouds':
      case 'cloudy':
        return [
          const Color(0xFF607D8B),
          const Color(0xFF78909C),
          const Color(0xFF90A4AE),
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF455A64),
          const Color(0xFF546E7A),
          const Color(0xFF607D8B),
        ];
      case 'thunderstorm':
      case 'stormy':
        return [
          const Color(0xFF263238),
          const Color(0xFF37474F),
          const Color(0xFF455A64),
        ];
      case 'snow':
      case 'snowy':
        return [
          const Color(0xFFB0BEC5),
          const Color(0xFFCFD8DC),
          const Color(0xFFECEFF1),
        ];
      default:
        return [
          const Color(0xFF4A90E2),
          const Color(0xFF50B7F5),
          const Color(0xFF87CEEB),
        ];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGradientColors(weatherCondition),
        ),
      ),
      child: child,
    );
  }
}
