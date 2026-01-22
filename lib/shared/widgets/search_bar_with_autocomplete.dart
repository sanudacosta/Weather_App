import 'package:flutter/material.dart';
import '../../data/services/city_autocomplete_service.dart';

class SearchBarWithAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onLocationTap;
  
  const SearchBarWithAutocomplete({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onLocationTap,
  });
  
  @override
  State<SearchBarWithAutocomplete> createState() => _SearchBarWithAutocompleteState();
}

class _SearchBarWithAutocompleteState extends State<SearchBarWithAutocomplete> {
  final CityAutocompleteService _autocompleteService = CityAutocompleteService();
  List<CityModel> _suggestions = [];
  bool _showSuggestions = false;
  
  void _onSearchChanged(String query) async {
    if (query.length >= 2) {
      final suggestions = await _autocompleteService.searchCities(query);
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }
  
  void _selectCity(CityModel city) {
    widget.controller.text = city.name;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    widget.onSearch(city.name);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (value) {
                    setState(() {
                      _showSuggestions = false;
                    });
                    widget.onSearch(value);
                  },
                ),
              ),
              if (widget.onLocationTap != null)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    onPressed: widget.onLocationTap,
                  ),
                ),
            ],
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final city = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city, color: Colors.blue),
                  title: Text(
                    city.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    city.country + (city.state != null ? ', ${city.state}' : ''),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  onTap: () => _selectCity(city),
                );
              },
            ),
          ),
      ],
    );
  }
}
