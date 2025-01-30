import 'package:app/api/apiurl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeService {
  static Future<List<dynamic>> getSavedRecipes(String userId) async {
    try {
      final Uri url = Uri.parse('$apiUrl/api/user/recipes/saved/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load saved recipes');
      }
    } catch (e) {
      throw Exception('Error fetching saved recipes: $e');
    }
  }

  static Future<List<dynamic>> getRecommendationsFromIngredients(
      List<String> ingredients) async {
    try {
      final Uri url = Uri.parse('$apiUrl/recommend/');
      final response = await http.get(
        url.replace(queryParameters: {
          'ingredients': ingredients.join(','),
          'num_recommendations': '5', // Limiting to 5 recommendations
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
