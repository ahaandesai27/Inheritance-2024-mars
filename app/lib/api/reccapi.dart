// ignore_for_file: avoid_print

import 'package:app/api/saverecipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:collection';

const recUrl = 'http://localhost:8000/recommend/';
SaveRecipeService saver = SaveRecipeService();

Future<List<Map<String, dynamic>>> getRecommendations(
    String ingredient, int numRecommendations) async {
  final url = Uri.parse(recUrl);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'ingredients': ingredient,
      'num_recommendations': numRecommendations,
    }),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }
  throw Exception('Failed to load recommendations');
}

Future<List<Map<String, dynamic>>?> getRecommendationsFromSaved(
    String userId) async {
  try {
    if (userId == '') {
      return [];
    }

    // Get saved recipe ingredients
    List<String> ingredients = await saver.getSavedRecipeIngredients(userId);
    Set<Map<String, dynamic>> result = HashSet<Map<String, dynamic>>();

    // Call getRecommendations for each ingredient and add results to HashSet
    for (var ingredient in ingredients) {
      List<Map<String, dynamic>> recommendations = await getRecommendations(
          ingredient, 5); // You can adjust the numRecommendations
      result.addAll(recommendations);
    }

    // Convert the HashSet to a List and return it
    return result.toList();
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
// void main() async {
//   try {
//     List<Map<String, dynamic>> recommendations = await getRecommendations("tomato chicken", 10);
//     print(recommendations[0]);
//   } catch (e) {
//     print('Error: $e');
//   }
// }