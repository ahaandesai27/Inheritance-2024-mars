// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:app/api/apiurl.dart';
import 'package:http/http.dart' as http;

class ProductPrice {
  final String productName;
  final Map<String, dynamic> productPrice;
  final String productWeight;
  final String productImage;
  final String productLink;
  final String origin;

  ProductPrice({
    required this.productName,
    required this.productPrice,
    required this.productWeight,
    required this.productImage,
    required this.productLink,
    required this.origin,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      productName: json['productName']?.toString() ?? '',
      productPrice: {
        'discountedPrice': json['productPrice']?['discountedPrice'] ?? 0,
        'originalPrice': json['productPrice']?['originalPrice'] ?? 0,
      },
      productWeight: json['productWeight']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? '',
      productLink: json['productLink']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
    );
  }

  double get discountedPrice =>
      (productPrice['discountedPrice'] ?? 0).toDouble();

  double get originalPrice =>
      (productPrice['originalPrice'] ?? 0).toDouble();
}

class PriceTrackingService {
  static final _baseUrl = webscrapingUrl;

  static Future<List<ProductPrice>> getPricesForIngredient(String ingredient) async {
    final sources = ['bigbasket', 'zepto', 'starquik'];
    List<ProductPrice> allPrices = [];

    try {
      for (final source in sources) {
        final url = Uri.parse('$_baseUrl?q=$ingredient&source=$source');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            try {
              allPrices.add(ProductPrice.fromJson(data));
            } catch (e) {
              print('Error parsing product from $source: $e');
            }
          }
        } else {
          print('Failed to fetch from $source: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }

    return allPrices;
  }
}

