import 'package:app/api/localstorage.dart';
import 'package:app/pages/cuisinerecipe.dart';
import 'package:app/pages/recipedetail.dart';
import 'package:app/utils/colors.dart';
import 'package:app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/searchbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/api/reccapi.dart';

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
    if (id != '') {
      _fetchPersonalizedRecommendations(id);
    }
  }

  Future<void> _fetchPersonalizedRecommendations(String userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Get personalized recommendations from the saved recipes
      final recommendedRecipes = await getRecommendationsFromSaved(userId);

      if (recommendedRecipes == null || recommendedRecipes.isEmpty) {
        setState(() {
          recommendations = [];
          isLoading = false;
        });
        return;
      }

      setState(() {
        recommendations = recommendedRecipes;
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
        title: Text('Select a Recipe',
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colour.purpur,
        automaticallyImplyLeading: false,
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
                  _buildCategoryTile('Indian', 'assets/Indian.jpg'),
                  _buildCategoryTile('Cont\'l', 'assets/Continental.jpg'),
                  _buildCategoryTile('Chinese', 'assets/Chinese.jpeg'),
                  _buildCategoryTile('Asian', 'assets/Asian.jpg'),
                  _buildCategoryTile('French', 'assets/French.jpg'),
                  _buildCategoryTile('Mid East', 'assets/MiddleEastern.jpg'),
                  _buildCategoryTile('Punjabi', 'assets/Punjabi.jpg'),
                  _buildCategoryTile('Italian', 'assets/Italian.jpg'),
                  _buildCategoryTile('Fusion', 'assets/Fusion.jpg'),
                  _buildCategoryTile('Thai', 'assets/Thai.jpg'),
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
      bottomNavigationBar: const Navbar(),
    );
  }

  Widget _buildCategoryTile(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CuisineRecipesPage(
                cuisine: title == 'Mid East'
                    ? 'Middle Eastern'
                    : title == 'Cont\'l'
                        ? 'Continental'
                        : title),
          ),
        );
      },
      child: Container(
        height: 80, // Precise height to remove overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 35,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
