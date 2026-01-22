import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onLocationTap;
  
  const SearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onLocationTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: onSearch,
            ),
          ),
          if (onLocationTap != null)
            IconButton(
              icon: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              onPressed: onLocationTap,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
