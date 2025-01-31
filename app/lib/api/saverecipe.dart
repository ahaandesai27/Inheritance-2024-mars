import 'package:http/http.dart' as http;
import 'package:app/api/apiurl.dart';
import 'package:app/api/recipe.dart';
import 'dart:convert';

class SaveRecipeService {
  Future<bool> saveRecipe(String userId, String recipeId) async {
    final url = Uri.parse('$apiUrl/api/user/recipes/saved');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'recipeId': recipeId}),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to save recipe');
  }

  Future<List<Recipe>> getSavedRecipes(String userId) async {
    final url = Uri.parse('$apiUrl/api/user/recipes/saved/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load saved recipes');
  }

  Future<List<String>> getSavedRecipeIngredients(String userId) async {
    final List<Recipe> recipes = await getSavedRecipes(userId);
    return recipes
        .map((recipe) => recipe.cleanedIngredients.join(' '))
        .toList();
  }

  Future<bool> deleteSavedRecipe(String userId, String recipeId) async {
    final url = Uri.parse('$apiUrl/api/user/recipes/saved');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'recipeId': recipeId,
      }),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to delete saved recipe');
  }

  Future<bool> isRecipeSaved(String userId, String recipeId) async {
    final url = Uri.parse(
        '$apiUrl/api/user/recipes/isSaved?userId=$userId&recipeId=$recipeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isSaved'] ?? false;
    }
    throw Exception('Failed to check if recipe is saved');
  }
}

// //unit test isRecipeSaved
// void main() async {
//   final saveRecipeService = SaveRecipeService();
//   bool result = await saveRecipeService.isRecipeSaved(
//       "6767feee8e2f7487e2d699db", "6798e0e81370ed3f77bf28bf");
//   print(result);
// }

// unit test
// void main() async {
//   final saveRecipeService = SaveRecipeService();
//   List<String> ingredients = await saveRecipeService
//       .getSavedRecipeIngredients("6767feee8e2f7487e2d699db");
//   print(ingredients);
// }
