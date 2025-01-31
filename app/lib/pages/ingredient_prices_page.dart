// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/api/fetchproductprices.dart';
import 'package:app/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class IngredientPricesPage extends StatefulWidget {
  final String ingredient;

  const IngredientPricesPage({super.key, required this.ingredient});

  @override
  State<IngredientPricesPage> createState() => _IngredientPricesPageState();
}

class _IngredientPricesPageState extends State<IngredientPricesPage> {
  List<ProductPrice> _prices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    try {
      final prices =
          await PriceTrackingService.getPricesForIngredient(widget.ingredient);
      setState(() {
        _prices = prices.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to get image path based on the origin
  String _getOriginImage(String origin) {
    switch (origin.toLowerCase()) {
      case 'amazon':
        return 'assets/amazon.jpg';
      case 'zepto':
        return 'assets/zepto.jpg';
      case 'swiggy':
        return 'assets/swiggy.jpg';
      case 'big basket':
        return 'assets/bigbasket.jpg';
      default:
        return 'assets/default.jpg'; // Default image if no match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prices for ${widget.ingredient}',
            style:
                GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colour.purpur,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prices.isEmpty
              ? Center(
                  child: Text(
                    'No price information available from websites.',
                    style: GoogleFonts.raleway(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prices.length,
                  itemBuilder: (context, index) {
                    final price = _prices[index];

                    // Skip rendering this product if discountedPrice or originalPrice is infinity
                    if (price.discountedPrice == double.infinity ||
                        price.originalPrice == double.infinity) {
                      return const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        // Launch the URL when the entire card is tapped
                        if (price.productLink.isNotEmpty) {
                          _launchURL(price.productLink);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8), // Adjust the radius for rounding
                                    child: Image.asset(
                                      _getOriginImage(price.origin),
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      price.origin.toUpperCase(),
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (index == 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
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
                              const SizedBox(height: 12),
                              Text(price.productWeight,
                                  style: GoogleFonts.raleway()),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₹${price.discountedPrice.toStringAsFixed(2)}',
                                    style: GoogleFonts.raleway(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  if (price.originalPrice !=
                                      double.infinity) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${price.originalPrice.toStringAsFixed(2)}',
                                      style: GoogleFonts.raleway(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
