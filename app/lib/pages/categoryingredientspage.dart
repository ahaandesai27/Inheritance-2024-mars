// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/api/apiurl.dart';
import 'package:app/utils/colors.dart';
import 'package:app/widgets/navbar.dart';

class CategoryIngredientsPage extends StatefulWidget {
  final String category;
  final List<String> currentlySelected;

  const CategoryIngredientsPage({
    super.key,
    required this.category,
    required this.currentlySelected,
  });

  @override
  State<CategoryIngredientsPage> createState() =>
      _CategoryIngredientsPageState();
}

class _CategoryIngredientsPageState extends State<CategoryIngredientsPage> {
  List<Map<String, dynamic>> _ingredients = [];
  Set<String> _selectedIngredients = {};
  bool _isLoading = true;
  final String apiBaseUrl = apiUrl;

  @override
  void initState() {
    super.initState();
    _selectedIngredients = widget.currentlySelected.toSet();
    _fetchIngredients();
  }

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  Future<void> _fetchIngredients() async {
    try {
      http.Response response;
      if (widget.category == "Misc") {
        response = await http.get(
          Uri.parse('$apiBaseUrl/api/ingredients/Miscellaneous'),
        );
      } else {
        response = await http.get(
          Uri.parse('$apiBaseUrl/api/ingredients/${widget.category}'),
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _ingredients = data
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _selectedIngredients.toList());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.category,
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colour.purpur,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _selectedIngredients.toList());
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  final isSelected =
                      _selectedIngredients.contains(ingredient['name']);

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
                        ingredient['name'],
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        ingredient['category'],
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleIngredient(ingredient['name']),
                        activeColor: Colour.purpur,
                      ),
                      onTap: () => _toggleIngredient(ingredient['name']),
                    ),
                  );
                },
              ),
        bottomNavigationBar: const Navbar(),
      ),
    );
  }
}
