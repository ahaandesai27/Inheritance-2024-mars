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
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      rethrow;
    }
  }
}
