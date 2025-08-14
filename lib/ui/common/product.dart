import 'package:flutter/material.dart';

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
                      if (product["sale_price"] != null)
                        Flexible(
                          child: Text(
                            "\$${product["sale_price"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (product["sale_price"] != null) const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          "\$${product["price"] ?? ''}",
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: product["on_sale"] == true ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  tooltip: 'Add to Cart',
                  onPressed: onTap ?? () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
