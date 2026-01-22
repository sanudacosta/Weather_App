import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/weather_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }
  
  @override
  Widget build(BuildContext context) {
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
        ),
        body: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            
            if (viewModel.favoriteCities.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No favorite cities yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add cities to your favorites from the home screen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.favoriteCities.length,
              itemBuilder: (context, index) {
                final city = viewModel.favoriteCities[index];
                return WeatherCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 32,
                    ),
                    title: Text(
                      city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            context.read<HomeViewModel>().fetchWeatherByCity(city);
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () {
                            viewModel.removeFavorite(city);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
