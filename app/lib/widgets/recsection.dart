import 'package:app/api/recipe.dart';
import 'package:flutter/material.dart';
import 'recipe_card.dart';

class RecommendationsSection extends StatelessWidget {
  final List<Recipe> recommendations;
  final bool isLoading;
  final Function(Recipe) onSaveRecipe;
  final Function(Recipe) onTapRecipe;
  final String title;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.isLoading,
    required this.onSaveRecipe,
    required this.onTapRecipe,
    this.title = 'Recommended for you',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recipe = recommendations[index];
            return RecipeCard(
              recipe: recipe,
              onSave: () => onSaveRecipe(recipe),
              onTap: () => onTapRecipe(recipe),
            );
          },
        ),
      ],
    );
  }
}
