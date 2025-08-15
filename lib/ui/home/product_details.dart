import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/product_details_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductDetailsProvider>(context, listen: false).setProductId(widget.product['id'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product["name"] ?? '')),
      body: Consumer<ProductDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return const Center(child: Text('Failed to load product'));
          }

          final product = provider.product;
          if (product == null) {
            return const Center(child: Text('No product found'));
          }

          final purchasable = product['purchasable'] ?? false;
          final inStock = (product['stock_status'] ?? '') == 'instock';
          final virtualTryon = product['virtual_tryon'] ?? false;
          final price = product['price'] ?? '';
          final salePrice = product['sale_price'] ?? '';
          final imageUrl = product['image'] ?? '';
          final name = product['name'] ?? '';
          final shortDescription = product['short_description'] ?? '';
          final additionalDetails = product['additional_details'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover)
                else
                  Container(height: 250, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, size: 80)),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(name, style: Theme.of(context).textTheme.titleLarge),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (salePrice != null && salePrice.isNotEmpty)
                        Text(
                          '\$$salePrice',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
                        ),
                      if (salePrice != null && salePrice.isNotEmpty) const SizedBox(width: 8),
                      Text(
                        '\$$price',
                        style: TextStyle(
                          fontSize: 16,
                          color: salePrice != null && salePrice.isNotEmpty ? Colors.grey : Colors.black,
                          decoration: salePrice != null && salePrice.isNotEmpty
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(shortDescription, style: Theme.of(context).textTheme.bodyMedium),
                ),

                const SizedBox(height: 12),
                if (additionalDetails.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: additionalDetails.entries.map((e) {
                        final valueList = (e.value as List).join(', ');
                        return Text('${e.key}: $valueList', style: Theme.of(context).textTheme.bodyMedium);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (virtualTryon)
                        ElevatedButton.icon(
                          onPressed: () {
                            // handle virtual try-on
                          },
                          icon: const FaIcon(FontAwesomeIcons.eye, size: 16),
                          label: const Text('Virtual Try-On'),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: purchasable && inStock
                              ? () {
                                  // handle add to cart
                                }
                              : null,
                          icon: const FaIcon(FontAwesomeIcons.cartPlus, size: 16),
                          style: ElevatedButton.styleFrom(backgroundColor: purchasable && inStock ? Colors.blue : Colors.grey),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Optional: Reviews or Related Products can go here
              ],
            ),
          );
        },
      ),
    );
  }
}
