// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:app/api/apiurl.dart';
import 'package:http/http.dart' as http;

/// A single product returned by one of the store integrations on the backend.
///
/// Every store is normalised to the same shape by the backend, so any field a
/// particular store does not supply arrives as `null`.
class ProductPrice {
  final String productName;

  /// Prices are nullable on purpose: a store that does not expose a price must
  /// not be rendered as "free". Use [price] for the value to display/sort on.
  final double? discountedPrice;
  final double? originalPrice;

  final String productWeight;
  final String productImage;
  final String productLink;
  final String? brand;
  final bool inStock;
  final String origin;

  ProductPrice({
    required this.productName,
    required this.discountedPrice,
    required this.originalPrice,
    required this.productWeight,
    required this.productImage,
    required this.productLink,
    required this.brand,
    required this.inStock,
    required this.origin,
  });

  factory ProductPrice.fromJson(
    Map<String, dynamic> json, {
    String fallbackOrigin = '',
  }) {
    final dynamic rawPrice = json['productPrice'];
    final Map<dynamic, dynamic> priceMap =
        rawPrice is Map ? rawPrice : const <String, dynamic>{};

    final String? brand = json['brand']?.toString();
    final dynamic rawStock = json['inStock'];
    final String origin = json['origin']?.toString() ?? '';

    return ProductPrice(
      productName: json['productName']?.toString() ?? '',
      discountedPrice: _parsePrice(priceMap['discountedPrice']),
      originalPrice: _parsePrice(priceMap['originalPrice']),
      productWeight: json['productWeight']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? '',
      productLink: json['productLink']?.toString() ?? '',
      brand: (brand == null || brand.isEmpty) ? null : brand,
      // Only an explicit `false` means out of stock; a store that does not
      // report stock at all is treated as available.
      inStock: rawStock is bool ? rawStock : true,
      origin: origin.isEmpty ? fallbackOrigin : origin,
    );
  }

  /// The price actually charged, falling back to the original price when the
  /// store does not advertise a discount. `null` when no usable price exists.
  double? get price => discountedPrice ?? originalPrice;

  bool get hasPrice => price != null;

  /// True only when there is a genuine strike-through price to show.
  bool get hasDiscount =>
      discountedPrice != null &&
      originalPrice != null &&
      originalPrice! > discountedPrice!;

  /// Parses a price into a positive, finite double. Anything else (null,
  /// non-numeric, zero, negative, NaN, infinity) becomes `null` so it can be
  /// filtered out instead of masquerading as the cheapest option.
  static double? _parsePrice(dynamic value) {
    double? parsed;
    if (value is num) {
      parsed = value.toDouble();
    } else if (value is String) {
      parsed = double.tryParse(value.trim());
    }
    if (parsed == null || !parsed.isFinite || parsed <= 0) return null;
    return parsed;
  }
}

/// A store that the backend could not reach for this query. The `/search`
/// endpoint returns 200 with per-store `ok: false` entries, so these are
/// partial failures that should be surfaced next to the results that worked.
class StoreFailure {
  final String store;
  final String error;

  const StoreFailure({required this.store, required this.error});
}

/// Everything one price lookup produced: the products that came back, the
/// stores that failed, and an [error] set only when the whole request failed.
class IngredientPriceResult {
  final List<ProductPrice> products;
  final List<StoreFailure> failures;
  final String? error;

  const IngredientPriceResult({
    required this.products,
    required this.failures,
    this.error,
  });

  const IngredientPriceResult.failed(String message)
      : products = const <ProductPrice>[],
        failures = const <StoreFailure>[],
        error = message;

  bool get hasProducts => products.isNotEmpty;
  bool get hasFailures => failures.isNotEmpty;
}

class PriceTrackingService {
  static const String _searchPath = '/api/ingredients/stores/search';
  static const int _defaultLimit = 30;

  /// Fans out across every supported store in a single backend request.
  ///
  /// Calls `{apiUrl}/api/ingredients/stores/search?q=<ingredient>&limit=<limit>`
  /// and flattens the nested `results[].products[]` payload, dropping products
  /// without a usable price and sorting what remains cheapest-first.
  static Future<IngredientPriceResult> getPricesForIngredient(
    String ingredient, {
    int limit = _defaultLimit,
  }) async {
    final query = ingredient.trim();
    if (query.isEmpty) {
      return const IngredientPriceResult.failed('No ingredient to search for.');
    }

    final uri = Uri.parse('$apiUrl$_searchPath').replace(
      queryParameters: <String, String>{
        'q': query,
        'limit': '$limit',
      },
    );

    try {
      final response = await http.get(uri);

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        print('Error decoding price response: $e');
        decoded = null;
      }

      if (decoded is! Map<String, dynamic>) {
        return IngredientPriceResult.failed(
          'Could not read prices (HTTP ${response.statusCode}).',
        );
      }

      final products = <ProductPrice>[];
      final failures = <StoreFailure>[];

      final dynamic results = decoded['results'];
      if (results is List) {
        for (final dynamic entry in results) {
          if (entry is! Map<String, dynamic>) continue;

          final store = entry['store']?.toString() ?? '';

          if (entry['ok'] != true) {
            failures.add(StoreFailure(
              store: store,
              error: entry['error']?.toString() ?? 'Store unavailable',
            ));
            continue;
          }

          final dynamic rawProducts = entry['products'];
          if (rawProducts is! List) continue;

          for (final dynamic raw in rawProducts) {
            if (raw is! Map<String, dynamic>) continue;
            try {
              final product = ProductPrice.fromJson(raw, fallbackOrigin: store);
              if (product.hasPrice) products.add(product);
            } catch (e) {
              print('Error parsing product from $store: $e');
            }
          }
        }
      }

      // Cheapest first, so the "Best Price" badge on the first card is true.
      products.sort((a, b) => a.price!.compareTo(b.price!));

      if (response.statusCode != 200 && products.isEmpty && failures.isEmpty) {
        return IngredientPriceResult.failed(
          decoded['error']?.toString() ??
              'Price lookup failed (HTTP ${response.statusCode}).',
        );
      }

      return IngredientPriceResult(products: products, failures: failures);
    } catch (e) {
      print('Error fetching prices: $e');
      return const IngredientPriceResult.failed(
        'Could not reach the price service. Check your connection.',
      );
    }
  }
}
