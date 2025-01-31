// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:app/api/apiurl.dart';
import 'package:http/http.dart' as http;

class ProductPrice {
  final String productName;
  final double discountedPrice;
  final double originalPrice;
  final String productWeight;
  final String productImage;
  final String origin;
  final String productLink;

  ProductPrice({
    required this.productName,
    required this.discountedPrice,
    required this.originalPrice,
    required this.productWeight,
    required this.productImage,
    required this.origin,
    required this.productLink,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      productName: json['productName'] ?? '',
      discountedPrice:
          (json['productPrice']?['discountedPrice'] ?? double.infinity)
              .toDouble(),
      originalPrice: (json['productPrice']?['originalPrice'] ?? double.infinity)
          .toDouble(),
      productWeight: json['productWeight'] ?? '',
      productImage: json['productImage'] ?? '',
      productLink: json['productLink'] ?? '',
      origin: json['origin'] ?? '',
    );
  }
}

class PriceTrackingService {
  static const _baseUrl = '$apiUrl/api/getingredients';

  static Future<List<ProductPrice>> getPricesForIngredient(
      String ingredient) async {
    List<ProductPrice> allPrices = [];

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?q=${Uri.encodeComponent(ingredient)}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body); // Ensure it's a list
        allPrices.addAll(data
            .map((item) => ProductPrice.fromJson(item as Map<String, dynamic>))
            .toList());
      }
    } catch (e) {
      print('An error occurred: $e');
    }

    return allPrices;
  }
}

// // Unit testing 
// void main() async {
//   final ingredient = 'apple';
//   final response = await http.get(Uri.parse(
//       '${PriceTrackingService._baseUrl}?q=${Uri.encodeComponent(ingredient)}'));

//   if (response.statusCode == 200) {
//     print('Raw JSON Response: ${response.body}');
//     List<ProductPrice> prices = (json.decode(response.body) as List)
//         .map((item) => ProductPrice.fromJson(item))
//         .toList();
//     print('Parsed Product Prices: $prices');
//   } else {
//     print('Failed to fetch data: ${response.statusCode}');
//   }
// }
