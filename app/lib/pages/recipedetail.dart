// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app/api/apiurl.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ProductPrice {
  final String productName;
  final double discountedPrice;
  final double? originalPrice;
  final String productWeight;
  final String? productImage;
  final String origin;

  ProductPrice({
    required this.productName,
    required this.discountedPrice,
    this.originalPrice,
    required this.productWeight,
    this.productImage,
    required this.origin,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      productName: json['productName'] ?? '',
      discountedPrice: (json['discountedPrice'] ?? 0.0).toDouble(),
      originalPrice: json['productPrice']?['originalPrice']?.toDouble(),
      productWeight: json['productWeight'] ?? '',
      productImage: json['productImage'],
      origin: json['origin'] ?? '',
    );
  }
}

class PriceTrackingService {
  static const _baseUrl = '$apiUrl/api/getingredients';
  static Future<List<ProductPrice>> getPricesForIngredient(
      String ingredient) async {
    List<ProductPrice> allPrices = [];
    List<String> platforms = ['amazon', 'bigBasket', 'swiggy', 'zepto'];
    for (String platform in platforms) {
      try {
        final response = await http.get(Uri.parse(
            '$_baseUrl/$platform?q=${Uri.encodeComponent(ingredient)}'));
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          allPrices
              .addAll(data.map((item) => ProductPrice.fromJson(item)).toList());
        }
      } catch (e) {
        print('Error fetching prices from $platform: $e');
      }
    }

    return allPrices;
  }
}

class Recipe {
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

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeDetailsPage({super.key, required this.recipeData});
  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final Map<String, List<ProductPrice>> _ingredientPrices = {};
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAllPrices();
  }

  Future<void> _fetchAllPrices() async {
    final recipe = Recipe.fromJson(widget.recipeData);

    for (String ingredient in recipe.cleanedIngredients) {
      if (ingredient.trim().isEmpty) continue;

      setState(() {
        _loadingStates[ingredient] = true;
      });

      try {
        final prices =
            await PriceTrackingService.getPricesForIngredient(ingredient);
        setState(() {
          _ingredientPrices[ingredient] = prices;
          _loadingStates[ingredient] = false;
        });
      } catch (e) {
        print('Error fetching prices for $ingredient: $e');
        setState(() {
          _loadingStates[ingredient] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = Recipe.fromJson(widget.recipeData);

    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colour.purpur,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.food_bank, size: 100);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name and Veg/Non-veg indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.translatedRecipeName,
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.isVeg ? 'VEG' : 'NON-VEG',
                          style: TextStyle(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.timer, color: Colors.deepPurple),
                              Text('${recipe.totalTimeInMins} mins',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.deepPurple),
                              Text('${recipe.calorieCount} cal',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.restaurant_menu,
                                  color: Colors.deepPurple),
                              Text('${recipe.ingredientCount} items',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.cleanedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          recipe.cleanedIngredients[index].trim();
                      if (ingredient.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record,
                                size: 8, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(ingredient,
                                  style: GoogleFonts.raleway(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  Text(
                    'Instructions',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.translatedInstructions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                recipe.translatedInstructions[index],
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Shopping Section
                  Text(
                    'Where to Buy Ingredients',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.cleanedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          recipe.cleanedIngredients[index].trim();
                      if (ingredient.isEmpty) return const SizedBox.shrink();

                      final prices = _ingredientPrices[ingredient] ?? [];
                      final isLoading = _loadingStates[ingredient] ?? false;

                      // Sort prices by discounted price
                      prices.sort((a, b) =>
                          a.discountedPrice.compareTo(b.discountedPrice));
                      final bestPrice = prices.isNotEmpty ? prices.first : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: GoogleFonts.raleway(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (bestPrice != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Best Price',
                                        style: GoogleFonts.raleway(
                                          color: Colors.green.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (prices.isEmpty)
                                Center(
                                  child: Text(
                                    'No price information available',
                                    style: GoogleFonts.raleway(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              else ...[
                                // Best Price Section
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        bestPrice!.origin.toUpperCase(),
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bestPrice.productWeight,
                                          style: GoogleFonts.raleway(),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${bestPrice.discountedPrice.toStringAsFixed(2)}',
                                              style: GoogleFonts.raleway(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            if (bestPrice.originalPrice !=
                                                null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '₹${bestPrice.originalPrice!.toStringAsFixed(2)}',
                                                style: GoogleFonts.raleway(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Other Options
                                if (prices.length > 1) ...[
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Other Options',
                                    style: GoogleFonts.raleway(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...prices.skip(1).take(3).map((price) =>
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                price.origin.toUpperCase(),
                                                style: GoogleFonts.raleway(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              price.productWeight,
                                              style: GoogleFonts.raleway(),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '₹${price.discountedPrice.toStringAsFixed(2)}',
                                              style: GoogleFonts.raleway(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
