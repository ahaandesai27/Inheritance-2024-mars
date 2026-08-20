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
  List<ProductPrice> _prices = <ProductPrice>[];
  List<StoreFailure> _failures = <StoreFailure>[];
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    // Already true on the initial load, so this only runs for "Try again"
    // (and avoids calling setState() from initState()).
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result =
        await PriceTrackingService.getPricesForIngredient(widget.ingredient);

    if (!mounted) return;
    setState(() {
      _prices = result.products;
      _failures = result.failures;
      _error = result.error;
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open this product page.',
            style: GoogleFonts.raleway(),
          ),
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Human readable name for a store id such as `bigbasket`.
  String _storeLabel(String origin) {
    switch (origin.toLowerCase()) {
      case 'bigbasket':
        return 'BigBasket';
      case 'blinkit':
        return 'Blinkit';
      case 'dmart':
        return 'DMart';
      case 'starquik':
        return 'StarQuik';
      case 'zepto':
        return 'Zepto';
      case 'amazon':
        return 'Amazon';
      case 'swiggy':
        return 'Swiggy';
      default:
        return origin.isEmpty ? 'Store' : origin.toUpperCase();
    }
  }

  /// Asset path for the stores we actually ship a logo for, or `null` when we
  /// do not have one (blinkit and dmart have no logo asset in `assets/`).
  String? _originAsset(String origin) {
    switch (origin.toLowerCase()) {
      case 'bigbasket':
        return 'assets/bigbasket.jpg';
      case 'starquik':
        return 'assets/starquik.png';
      case 'zepto':
        return 'assets/zepto.jpg';
      case 'amazon':
        return 'assets/amazon.jpg';
      case 'swiggy':
        return 'assets/swiggy.jpg';
      default:
        return null;
    }
  }

  /// Monogram badge used when no logo asset exists for a store.
  Widget _originFallback(String origin) {
    final label = _storeLabel(origin);
    final initial = label.isEmpty ? '?' : label.substring(0, 1).toUpperCase();
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colour.purpur,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial,
        style: GoogleFonts.raleway(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOriginLogo(String origin) {
    final asset = _originAsset(origin);
    if (asset == null) return _originFallback(origin);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _originFallback(origin),
      ),
    );
  }

  Widget _buildFailureBanner() {
    if (_failures.isEmpty) return const SizedBox.shrink();

    final names =
        _failures.map((failure) => _storeLabel(failure.store)).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _failures.length == 1
                  ? '$names is unavailable right now.'
                  : '$names are unavailable right now.',
              style: GoogleFonts.raleway(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFailureBanner(),
        const SizedBox(height: 24),
        Center(
          child: Text(
            _error ?? 'No price information available for this ingredient.',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _fetchPrices,
            child: Text(
              'Try again',
              style: GoogleFonts.raleway(
                color: Colour.purpur,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Small coloured pill used for the "Best Price" / "Out of stock" labels.
  Widget _buildTag(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.raleway(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceCard(ProductPrice price, bool isBestPrice) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildOriginLogo(price.origin),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _storeLabel(price.origin).toUpperCase(),
                          style: GoogleFonts.raleway(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isBestPrice)
                        _buildTag(
                          'Best Price',
                          Colors.green.shade100,
                          Colors.green.shade700,
                        ),
                      if (!price.inStock)
                        _buildTag(
                          'Out of stock',
                          Colors.red.shade50,
                          Colors.red.shade700,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (price.productName.isNotEmpty)
              Text(
                price.productName,
                style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
              ),
            if (price.brand != null) ...[
              const SizedBox(height: 2),
              Text(
                price.brand!,
                style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (price.productWeight.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(price.productWeight, style: GoogleFonts.raleway()),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${price.price!.toStringAsFixed(2)}',
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                if (price.hasDiscount) ...[
                  const SizedBox(width: 8),
                  Text(
                    '₹${price.originalPrice!.toStringAsFixed(2)}',
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
    );

    return GestureDetector(
      onTap: () {
        if (price.productLink.isNotEmpty) {
          _launchURL(price.productLink);
        }
      },
      child: price.inStock ? card : Opacity(opacity: 0.55, child: card),
    );
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
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  // One extra leading item for the "store unavailable" banner.
                  itemCount: _prices.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildFailureBanner();
                    final price = _prices[index - 1];
                    return _buildPriceCard(price, index == 1);
                  },
                ),
    );
  }
}
