import 'dart:convert';
import 'package:http/http.dart' as http;

class Getservices {
  final _baseUrl = 'http://localhost:4000/api/recipes';

  Future<List<dynamic>> search(String query, int skip, int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query&skip=$skip&limit=$limit'),
        headers: {
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return _extractRecipes(decodedData);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Search error: $e');
      rethrow;
    }
  }

  List<dynamic> _extractRecipes(dynamic decodedData) {
    if (decodedData is Map) {
      return decodedData['data'] ?? decodedData['recipes'] ?? [];
    } else if (decodedData is List) {
      return decodedData;
    }
    return [];
  }
}
