import 'package:app/pages/reciperecommendationspage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

import '../api/apiurl.dart';
import '../utils/colors.dart';
import '../widgets/navbar.dart';
import '../widgets/sidebar.dart';
import 'categoryingredientspage.dart';

class IngredientSelector extends StatefulWidget {
  const IngredientSelector({super.key});

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedIngredients = [];
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  final String apiBaseUrl = apiUrl;
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Vegetables",
    "Fruits",
    "Dairy",
    "Meat",
    "Spices"
  ];

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(_searchController.text);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$apiBaseUrl/api/ingredients?q=$query&category=$_selectedCategory&limit=5'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _suggestions = data
              .map((item) => {
            'name': capitalizeWords(item['name'].toString()),
            'category': capitalizeWords(item['category'].toString()),
          })
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching ingredients: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildCategoryTile(String title) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<List<String>>(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryIngredientsPage(
              category: title,
              currentlySelected: _selectedIngredients, // Pass current selections
            ),
          ),
        );

        if (result != null) {
          setState(() {
            _selectedIngredients.clear(); // Clear existing selections
            _selectedIngredients.addAll(result); // Add new selections
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedCategory == title ? Colour.purpur : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _selectedCategory == title ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Ingredients",
          style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colour.purpur,
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ingredients...',
                    border: InputBorder.none,
                    icon: const Icon(Icons.search),
                    suffixIcon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Categories Section
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: _categories
                    .map((category) => _buildCategoryTile(category))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // Selected Ingredients Section
              const Text(
                'Selected Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_selectedIngredients.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedIngredients.map((ingredient) {
                      return Chip(
                        label: Text(capitalizeWords(ingredient)),
                        onDeleted: () => _toggleIngredient(ingredient),
                        backgroundColor: Colour.purpur,
                        labelStyle: const TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeRecommendationsPage(
                            selectedIngredients: _selectedIngredients,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colour.purpur,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Get Recommendations',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Suggestions List
              if (_suggestions.isNotEmpty) ...[
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._suggestions.map((suggestion) {
                  final ingredient = suggestion['name'];
                  final category = suggestion['category'];
                  final isSelected = _selectedIngredients.contains(ingredient);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: isSelected ? Colour.purpur : Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        ingredient,
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        category,
                        style: GoogleFonts.raleway(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleIngredient(ingredient),
                        activeColor: Colour.purpur,
                      ),
                      onTap: () => _toggleIngredient(ingredient),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const Navbar(),
    );
  }
}
