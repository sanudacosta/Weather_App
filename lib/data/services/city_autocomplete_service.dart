import 'dart:convert';
import 'package:http/http.dart' as http;

class CityAutocompleteService {
  final http.Client _client;
  
  CityAutocompleteService({http.Client? client}) 
      : _client = client ?? http.Client();
  
  // Using OpenWeatherMap's Geocoding API for city suggestions
  Future<List<CityModel>> searchCities(String query) async {
    if (query.isEmpty || query.length < 2) return [];
    
    final url = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct'
      '?q=$query&limit=5&appid=bd5e378503939ddaee76f12ad7a97608'
    );
    
    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class CityModel {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;
  
  CityModel({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });
  
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
  
  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}
