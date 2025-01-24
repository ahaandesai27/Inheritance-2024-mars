import 'package:http/http.dart';
import 'dart:convert';

class Getservices {
  final _baseUrl = 'http://localhost:4000/api/recipes';

  Future<List<dynamic>> search(String query, int skip, int limit) async {
    try {
      final response = await get(
        Uri.parse('$_baseUrl/search?q=$query&skip=$skip&limit=$limit'),
      );

      if (response.statusCode == 200) {
        print('=== API Response Debug ===');
        print('Raw response: ${response.body}');
        final decodedData = jsonDecode(response.body);
        print('Decoded data: $decodedData');
        print('Data type: ${decodedData.runtimeType}');
        print('========================');

        // Check if response is already a list or needs to be extracted
        if (decodedData is Map) {
          // If the API returns an object with a data/recipes field
          final recipes = decodedData['data'] ?? decodedData['recipes'] ?? [];
          return recipes;
        } else if (decodedData is List) {
          return decodedData;
        }
        return [];
      } else {
        print(
            'API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Search error: $e');
      rethrow;
    }
  }
}
