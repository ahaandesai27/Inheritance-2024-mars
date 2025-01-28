import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Recipe {
  final String translatedRecipeName;
  final String translatedIngredients;
  final int totalTimeInMins;
  final String cuisine;
  final String translatedInstructions;
  final String imageUrl;
  final int ingredientCount;
  final int calorieCount;
  final bool isVeg;
  final List<String> cleanedIngredients;

  Recipe({
    required this.translatedRecipeName,
    required this.translatedIngredients,
    required this.totalTimeInMins,
    required this.cuisine,
    required this.translatedInstructions,
    required this.imageUrl,
    required this.ingredientCount,
    required this.calorieCount,
    required this.isVeg,
    required this.cleanedIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      translatedRecipeName: json['TranslatedRecipeName'] ?? 'Unknown Recipe',
      translatedIngredients: json['TranslatedIngredients'] ?? '',
      totalTimeInMins: json['TotalTimeInMins'] ?? 0,
      cuisine: json['Cuisine'] ?? '',
      translatedInstructions: json['TranslatedInstructions'] ?? '',
      imageUrl: json['image-url'] ?? '',
      ingredientCount: json['Ingredient-count'] ?? 0,
      calorieCount: json['calorieCount'] ?? 0,
      isVeg: json['veg'] ?? false,
      cleanedIngredients:
          (json['Cleaned-Ingredients'] as String? ?? '').split(','),
    );
  }
}

class RecipeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const RecipeDetailsPage({super.key, required this.recipeData});

  List<String> _formatInstructions(String instructions) {
    var steps = instructions.split('\n');
    if (steps.length <= 1) {
      steps = instructions
          .split(RegExp(r'\d+\.\s*)'))
          .where((step) => step.trim().isNotEmpty)
          .toList();
    }
    if (steps.length <= 1) {
      steps = instructions
          .split('.')
          .where((step) => step.trim().isNotEmpty)
          .toList();
    }

    return steps.map((step) {
      step = step.replaceFirst(RegExp(r'^\d+\.\s*'), '');
      step = step.trim();
      if (step.isNotEmpty) {
        step = step[0].toUpperCase() + step.substring(1);
      }
      return step;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = Recipe.fromJson(recipeData);
    final formattedInstructions =
        _formatInstructions(recipe.translatedInstructions);

    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.food_bank, size: 100);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name and Veg/Non-veg indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.translatedRecipeName,
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.isVeg ? 'VEG' : 'NON-VEG',
                          style: TextStyle(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.timer, color: Colors.deepPurple),
                              Text('${recipe.totalTimeInMins} mins',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.deepPurple),
                              Text('${recipe.calorieCount} cal',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.restaurant_menu,
                                  color: Colors.deepPurple),
                              Text('${recipe.ingredientCount} items',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.cleanedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          recipe.cleanedIngredients[index].trim();
                      if (ingredient.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record,
                                size: 8, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(ingredient,
                                  style: GoogleFonts.raleway(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  Text(
                    'Instructions',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: formattedInstructions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formattedInstructions[index],
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Shopping Section
                  Text(
                    'Where to Buy Ingredients',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best prices from online stores',
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coming soon: Price comparisons from Amazon, Zepto, Swiggy, and BigBasket',
                            style: GoogleFonts.raleway(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
