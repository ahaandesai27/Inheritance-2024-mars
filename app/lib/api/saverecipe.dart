import 'package:http/http.dart' as http;
import 'package:app/api/apiurl.dart';
import 'dart:convert';

class SaveRecipeService {
  Future<bool> saveRecipe(String? userId, String? recipeId) async {
    if (userId == null || recipeId == null) {
      throw Exception('User ID and recipe ID are required');
      return false;
    }
    final url = Uri.parse('$apiUrl/api/user/recipes/saved');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'recipeId': recipeId,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<String>> getSavedRecipes(String userId) async {
    final url = Uri.parse('$apiUrl/api/user/recipes/saved/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['recipeId'].toString()).toList();
    } else {
      throw Exception('Failed to load saved recipes');
    }
  }

  Future<bool> deleteSavedRecipe(String userId, String recipeId) async {
    final url = Uri.parse('$apiUrl/api/user/recipes/saved');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'recipeId': recipeId,
      }),
    );

    return response.statusCode == 200;
  }
}
