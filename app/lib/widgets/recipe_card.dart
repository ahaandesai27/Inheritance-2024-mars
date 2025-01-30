import 'package:app/api/recipe.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onSave;
  final VoidCallback onTap;
  const RecipeCard(
      {super.key,
      required this.recipe,
      required this.onSave,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recipe.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
        title: Text(
          recipe.translatedRecipeName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${recipe.cuisine} • ${recipe.totalTimeInMins} mins\n${recipe.isVeg ? "Vegetarian" : "Non-vegetarian"} • ${recipe.calorieCount} cal',
          maxLines: 2,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: onSave,
        ),
        onTap: onTap,
      ),
    );
  }
}
