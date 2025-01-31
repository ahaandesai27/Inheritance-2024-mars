import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../api/apiurl.dart';
import '../utils/colors.dart';
import '../widgets/navbar.dart';

class RecipeRecommendationsPage extends StatefulWidget {
  final List<String> selectedIngredients;

  const RecipeRecommendationsPage({
    super.key,
    required this.selectedIngredients,
  });

  @override
  State<RecipeRecommendationsPage> createState() => _RecipeRecommendationsPageState();
}

class _RecipeRecommendationsPageState extends State<RecipeRecommendationsPage> {
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;
  final String apiBaseUrl = apiUrl;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apiBaseUrl/recommend/?ingredients=${widget.selectedIngredients.join(",")}&num_recommendations=10',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recommendations = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Recipe Recommendations",
          style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colour.purpur,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          final recipe = _recommendations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe['image_url'] != null)
                  Image.network(
                    recipe['image_url'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.restaurant, size: 50),
                          ),
                        ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['TranslatedRecipeName'],
                        style: GoogleFonts.raleway(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe['TotalTimeInMins']} mins',
                            style: GoogleFonts.raleway(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.restaurant, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            recipe['Cuisine'],
                            style: GoogleFonts.raleway(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingredients:',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe['TranslatedIngredients'],
                        style: GoogleFonts.raleway(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Instructions:',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe['TranslatedInstructions'],
                        style: GoogleFonts.raleway(),
                      ),
                      if (recipe['URL'] != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Add URL launcher functionality here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colour.purpur,
                          ),
                          child: Text(
                            'View Original Recipe',
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}