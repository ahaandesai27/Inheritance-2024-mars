import 'package:app/api/reccapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/apiurl.dart';
import '../utils/colors.dart';
import '../widgets/navbar.dart';
import 'package:app/pages/recipedetail.dart';

class RecipeRecommendationsPage extends StatefulWidget {
  final List<String> selectedIngredients;

  const RecipeRecommendationsPage({
    super.key,
    required this.selectedIngredients,
  });

  @override
  State<RecipeRecommendationsPage> createState() =>
      _RecipeRecommendationsPageState();
}

class _RecipeRecommendationsPageState extends State<RecipeRecommendationsPage> {
  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = true;
  final String apiBaseUrl = apiUrl;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      recipes =
          await getRecommendations(widget.selectedIngredients.join(" "), 10);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Recipe Recommendations",
          style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colour.purpur,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: recipe['veg'] ? Colors.green : Colors.red,
                        width: 2.0),
                  ),
                  child: ListTile(
                    leading: recipe['image-url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              recipe['image-url'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.food_bank, size: 80);
                              },
                            ),
                          )
                        : Icon(Icons.food_bank, size: 80),
                    title: Text(
                      recipe['TranslatedRecipeName'] ?? 'Unknown Recipe',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${recipe['TotalTimeInMins']} mins | ${recipe['veg'] ? 'Vegetarian' : 'Non-Vegetarian'}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black54),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsPage(recipeData: recipe)));
                      // Navigate to recipe details page
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) => RecipeDetailPage(recipe: recipe)
                      // ));
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: const Navbar(),
    );
  }
}
