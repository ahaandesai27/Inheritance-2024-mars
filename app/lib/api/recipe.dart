class Recipe {
  final String id;
  final String translatedRecipeName;
  final String translatedIngredients;
  final int totalTimeInMins;
  final String cuisine;
  final List<String> translatedInstructions;
  final String imageUrl;
  final int ingredientCount;
  final int calorieCount;
  final bool isVeg;
  final List<String> cleanedIngredients;

  Recipe({
    required this.id,
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
    List<String> parseInstructions(dynamic instructions) {
      if (instructions is List) {
        return instructions.map((step) => step.toString()).toList();
      } else if (instructions is String) {
        return instructions
            .split('\n')
            .where((step) => step.trim().isNotEmpty)
            .map((step) => step.trim())
            .toList();
      }
      return [];
    }

    return Recipe(
      id: json['_id'] ?? '',
      translatedRecipeName: json['TranslatedRecipeName'] ?? 'Unknown Recipe',
      translatedIngredients: json['TranslatedIngredients'] ?? '',
      totalTimeInMins: json['TotalTimeInMins'] ?? 0,
      cuisine: json['Cuisine'] ?? '',
      translatedInstructions: parseInstructions(json['TranslatedInstructions']),
      imageUrl: json['image-url'] ?? '',
      ingredientCount: json['Ingredient-count'] ?? 0,
      calorieCount: json['calorieCount'] ?? 0,
      isVeg: json['veg'] ?? false,
      cleanedIngredients:
          (json['Cleaned-Ingredients'] as String? ?? '').split(','),
    );
  }
}
