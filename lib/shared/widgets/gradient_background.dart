import 'package:flutter/material.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  final String weatherCondition;

  const GradientBackground({
    super.key,
    required this.child,
    this.weatherCondition = 'clear',
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(widget.weatherCondition),
              stops: [
                0.0,
                0.5 + (_controller.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
