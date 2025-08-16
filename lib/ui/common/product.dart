import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/ui/home/product_details.dart';
import 'package:seegma_woocommerce/utils/themes.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isHorizontal;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.isHorizontal = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? 180 : null,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)));
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product["image"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                        ),
                      ),
                      if (product["on_sale"] == true)
                        Positioned(
                          top: 8,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                            ),
                            child: const Text(
                              "SALE",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product["name"] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        // Show sale price if on sale and sale_price exists
                        if (product["on_sale"] == true &&
                            product["sale_price"] != null &&
                            product["sale_price"].toString().isNotEmpty)
                          Text(
                            "${AppText.currency}${product["sale_price"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                          ),

                        if (product["on_sale"] == true &&
                            product["sale_price"] != null &&
                            product["sale_price"].toString().isNotEmpty)
                          const SizedBox(width: 5),

                        // Show regular price (strike-through if on sale and regular_price exists)
                        Text(
                          "${AppText.currency}${product["regular_price"] != null && product["regular_price"].toString().isNotEmpty ? product["regular_price"] : product["price"] ?? ''}",
                          style: TextStyle(
                            fontSize: 14,
                            color: product["on_sale"] == true ? Colors.grey : Colors.black,
                            decoration:
                                (product["on_sale"] == true &&
                                    product["regular_price"] != null &&
                                    product["regular_price"].toString().isNotEmpty)
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    // icon: Icon(isHorizontal ? Icons.arrow_forward_ios : Icons.add_shopping_cart),
                    icon: Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                    tooltip: 'View Details',
                    onPressed:
                        onTap ??
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)));
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
