import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.weatherEndpoint}'
      '?q=$city&appid=${ApiConstants.apiKey}&units=metric'
    );
    
    try {
      final response = await _client.get(url).timeout(
        Duration(seconds: ApiConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getCurrentWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.weatherEndpoint}'
      '?lat=$lat&lon=$lon&appid=${ApiConstants.apiKey}&units=metric'
    );
    
    try {
      final response = await _client.get(url).timeout(
        Duration(seconds: ApiConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getForecast(String city) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.forecastEndpoint}'
      '?q=$city&appid=${ApiConstants.apiKey}&units=metric'
    );
    
    try {
      final response = await _client.get(url).timeout(
        Duration(seconds: ApiConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getForecastByCoordinates(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.forecastEndpoint}'
      '?lat=$lat&lon=$lon&appid=${ApiConstants.apiKey}&units=metric'
    );
    
    try {
      final response = await _client.get(url).timeout(
        Duration(seconds: ApiConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
