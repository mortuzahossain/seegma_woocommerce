import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [
    {
      "name": "Hoodie with Logo",
      "price": 45.00,
      "description": "This is a simple product.",
      "quantity": 2,
      "image": "https://via.placeholder.com/100",
    },
    {
      "name": "Broken Image Item",
      "price": 30.00,
      "description": "This will fail to load.",
      "quantity": 1,
      "image": "https://wrong-url.com/notfound.png",
    },
  ];

  Future<void> refreshCart() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    setState(() {});
  }

  void updateQuantity(int index, int change) {
    setState(() {
      final newQty = cartItems[index]["quantity"] + change;
      if (newQty > 0) {
        cartItems[index]["quantity"] = newQty;
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: RefreshIndicator(
        onRefresh: refreshCart,
        child: cartItems.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        const FaIcon(FontAwesomeIcons.cartShopping, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Looks like you haven’t added anything yet.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final total = item["price"] * item["quantity"];

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item["image"],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Center(child: FaIcon(FontAwesomeIcons.image, color: Colors.grey, size: 28)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("${item["price"].toStringAsFixed(2)}৳", style: const TextStyle(color: Colors.red)),
                                    const SizedBox(height: 4),
                                    Text(item["description"], style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text(
                                "${total.toStringAsFixed(2)}৳",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),

                          // const Divider(height: 20),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.remove), onPressed: () => updateQuantity(index, -1)),
                              Text(item["quantity"].toString(), style: const TextStyle(fontSize: 16)),
                              IconButton(icon: const Icon(Icons.add), onPressed: () => updateQuantity(index, 1)),
                              const Spacer(),
                              TextButton(onPressed: () => removeItem(index), child: const Text("Remove item")),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
