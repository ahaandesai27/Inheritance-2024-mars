import 'package:app/api/apiurl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CuisineRecipesPage extends StatefulWidget {
  final String cuisine;

  const CuisineRecipesPage({super.key, required this.cuisine});

  @override
  State<CuisineRecipesPage> createState() => _CuisineRecipesPageState();
}

class _CuisineRecipesPageState extends State<CuisineRecipesPage> {
  List<dynamic> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final Uri url = Uri.parse(
          '$apiUrl/api/recipes?skip=0&limit=50&cuisine=${widget.cuisine}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic parsedBody = json.decode(response.body);

        setState(() {
          recipes = parsedBody is List ? parsedBody : [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load ${widget.cuisine} recipes')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.cuisine} Recipes',
              style: GoogleFonts.raleway(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color:
                                    recipe['veg'] ? Colors.green : Colors.red,
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.food_bank, size: 80);
                                      },
                                    ),
                                  )
                                : Icon(Icons.food_bank, size: 80),
                            title: Text(
                              recipe['TranslatedRecipeName'] ??
                                  'Unknown Recipe',
                              style: TextStyle(
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
                              // Navigate to recipe details page
                              // Navigator.push(context, MaterialPageRoute(
                              //   builder: (context) => RecipeDetailPage(recipe: recipe)
                              // ));
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Category tile remains the same as in previous version
Widget _buildCategoryTile(
    BuildContext context, String title, String cuisineImageUrl) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CuisineRecipesPage(cuisine: title)));
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                cuisineImageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.food_bank, size: 60);
                },
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
