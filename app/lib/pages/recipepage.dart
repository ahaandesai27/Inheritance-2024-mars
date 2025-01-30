import 'package:app/api/localstorage.dart';
import 'package:app/api/saverecipeapi.dart';
import 'package:app/pages/cuisinerecipe.dart';
import 'package:app/pages/recipedetail.dart';
import 'package:app/utils/colors.dart';
import 'package:app/widgets/navbar.dart';
import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/searchbar.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({
    super.key,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String? userId;
  List<dynamic> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? id = await fetchStoredUserId();
    if (mounted) {
      setState(() {
        userId = id;
      });
    }
    if (id != null) {
      _fetchPersonalizedRecommendations(id);
    }
  }

  Future<void> _fetchPersonalizedRecommendations(String userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. First get saved recipes
      final savedRecipes = await RecipeService.getSavedRecipes(userId);

      if (savedRecipes.isEmpty) {
        setState(() {
          recommendations = [];
          isLoading = false;
        });
        return;
      }

      // 2. Extract unique ingredients from saved recipes
      final Set<String> uniqueIngredients = {};
      for (var recipe in savedRecipes) {
        // Split and clean ingredients
        final ingredients = recipe['Cleaned_Ingredients']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        uniqueIngredients.addAll(ingredients);
      }

      // 3. Get recommendations based on ingredients
      final recommendedRecipes =
          await RecipeService.getRecommendationsFromIngredients(
        uniqueIngredients.toList(),
      );

      // 4. Filter out recipes that are already saved
      final savedRecipeIds = savedRecipes.map((r) => r['_id']).toSet();
      final filteredRecommendations = recommendedRecipes
          .where((recipe) => !savedRecipeIds.contains(recipe['_id']))
          .take(5)
          .toList();

      setState(() {
        recommendations = filteredRecommendations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildRecommendationsSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recommendations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Save some recipes to get personalized recommendations!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recipe = recommendations[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: recipe['veg'] ? Colors.green : Colors.red,
              width: 2.0,
            ),
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
                        return const Icon(Icons.food_bank, size: 80);
                      },
                    ),
                  )
                : const Icon(Icons.food_bank, size: 80),
            title: Text(
              recipe['TranslatedRecipeName'] ?? 'Unknown Recipe',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time: ${recipe['TotalTimeInMins']} mins | ${recipe['veg'] ? 'Vegetarian' : 'Non-Vegetarian'}',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Cuisine: ${recipe['Cuisine']}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            trailing:
                const Icon(Icons.arrow_forward_ios, color: Colors.black54),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(recipeData: recipe),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
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
              const Searchbar(),
              const SizedBox(height: 20),

              // Categories Section
              const Text(
                'Cuisines',
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
                children: [
                  _buildCategoryTile('Indian'),
                  _buildCategoryTile('Continental'),
                  _buildCategoryTile('Chinese'),
                  _buildCategoryTile('Asian'),
                  _buildCategoryTile('French'),
                  _buildCategoryTile('Middle Eastern'),
                  _buildCategoryTile('Japanese'),
                  _buildCategoryTile('Italian'),
                  _buildCategoryTile('Fusion'),
                  _buildCategoryTile('Thai'),
                ],
              ),

              const SizedBox(height: 20),

              // Recommendations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        if (userId != null) {
                          _fetchPersonalizedRecommendations(userId!);
                        }
                      }),
                ],
              ),
              const SizedBox(height: 10),
              _buildRecommendationsSection(),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const Navbar(),
    );
  }

  Widget _buildCategoryTile(String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CuisineRecipesPage(cuisine: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
