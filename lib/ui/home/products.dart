import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  final String categorySlug;
  final String categoryName;

  const ProductsPage({super.key, required this.categorySlug, required this.categoryName});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Product 1",
      "image": "https://via.placeholder.com/200x200?text=Product+1",
      "price": 200,
      "salePrice": 150,
      "onSale": true,
    },
    {
      "name": "Product 2",
      "image": "https://via.placeholder.com/200x200?text=Product+2",
      "price": 100,
      "salePrice": null,
      "onSale": false,
    },
    {
      "name": "Product 3",
      "image": "https://via.placeholder.com/200x200?text=Product+3",
      "price": 300,
      "salePrice": 250,
      "onSale": true,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.74,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
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
                            product["image"],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        if (product["onSale"])
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
                        product["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          if (product["salePrice"] != null)
                            Flexible(
                              child: Text(
                                "\$${product["salePrice"]}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (product["salePrice"] != null) const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              "\$${product["price"]}",
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: product["onSale"] ? TextDecoration.lineThrough : TextDecoration.none,
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
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.white,
                      tooltip: 'Add to Cart',
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
