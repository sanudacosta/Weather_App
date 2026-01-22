# Weather App

A modern, clean weather application built with Flutter that provides current weather conditions and 5-day forecasts for cities worldwide.

## Features

- 🌤️ **Current Weather**: Get real-time weather data for any city
- 📍 **Location-based**: Automatic weather detection using GPS
- 📅 **5-Day Forecast**: View detailed hourly forecasts
- ⭐ **Favorites**: Save and quickly access your favorite cities
- 🎨 **Modern UI**: Clean, gradient-based interface that adapts to weather conditions
- 💾 **Persistent Storage**: Remembers your last searched city and favorites

## Screenshots

The app features a beautiful gradient background that changes based on weather conditions:
- Clear/Sunny: Blue gradient
- Cloudy: Grey gradient
- Rainy: Dark blue gradient
- Stormy: Dark grey gradient
- Snowy: Light grey gradient

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- OpenWeatherMap API Key

### Installation

1. Clone this repository
```bash
git clone https://github.com/sanudacosta/Weather_App.git
cd weather_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Add your API key
   - Open `lib/core/constants/api_constants.dart`
   - Replace `YOUR_API_KEY_HERE` with your OpenWeatherMap API key

4. Run the app
```bash
flutter run
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern with:
- **Provider** for state management
- **Feature-based** folder structure
- Clean separation of concerns

## Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **HTTP** - API calls
- **SharedPreferences** - Local storage
- **Geolocator** - Location services
- **OpenWeatherMap API** - Weather data

## Project Structure

```
lib/
├── core/
│   ├── constants/    # API keys and app constants
│   ├── theme/        # App theme configuration
│   └── utils/        # Helper functions
├── data/
│   ├── models/       # Data models
│   ├── services/     # API and storage services
│   └── repositories/ # Data repositories
├── features/
│   ├── home/         # Home screen with current weather
│   ├── forecast/     # 5-day forecast screen
│   ├── favorites/    # Favorites management
│   └── settings/     # App settings
└── shared/
    └── widgets/      # Reusable UI components
```

## API Usage

This app uses the [OpenWeatherMap API](https://openweathermap.org/api) for weather data.

Get your free API key at: https://openweathermap.org/api

## License

This project is open source and available under the MIT License.

## Author

**Sanuda Costa**
- Email: sanudacosta@gmail.com
- GitHub: [@sanudacosta](https://github.com/sanudacosta)

