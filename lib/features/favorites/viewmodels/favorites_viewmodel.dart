import 'package:flutter/foundation.dart';
import '../../../data/services/storage_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  final StorageService _storageService;
  
  FavoritesViewModel({StorageService? storageService})
      : _storageService = storageService ?? StorageService();
  
  List<String> _favoriteCities = [];
  bool _isLoading = false;
  
  List<String> get favoriteCities => _favoriteCities;
  bool get isLoading => _isLoading;
  
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    
    _favoriteCities = await _storageService.getFavoriteCities();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> addFavorite(String city) async {
    await _storageService.addFavoriteCity(city);
    await loadFavorites();
  }
  
  Future<void> removeFavorite(String city) async {
    await _storageService.removeFavoriteCity(city);
    await loadFavorites();
  }
  
  bool isFavorite(String city) {
    return _favoriteCities.contains(city);
  }
}
