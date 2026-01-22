# Weather App - Copilot Instructions

## Project Overview
A Flutter weather application using OpenWeatherMap API with Provider state management and MVVM architecture.

## Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **State Management**: Provider
- **Folder Structure**: Feature-based

## Key Technologies
- Flutter 3.x
- Provider for state management
- HTTP for API calls
- SharedPreferences for local storage
- Geolocator for GPS location
- FL Chart for weather visualization

## API
- OpenWeatherMap API (https://openweathermap.org/api)
- Endpoints used:
  - Current weather: `/weather`
  - 5-day forecast: `/forecast`

## Features
1. Current weather by city search
2. 5-day weather forecast
3. Favorite cities management
4. Weather alerts display
5. Location-based weather

## Folder Structure
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   ├── home/
│   ├── search/
│   ├── forecast/
│   ├── favorites/
│   └── settings/
└── shared/
    └── widgets/
```

## Coding Guidelines
- Follow beginner-friendly coding style
- Use clear variable and function names
- Add comments for complex logic
- Keep widgets small and reusable
