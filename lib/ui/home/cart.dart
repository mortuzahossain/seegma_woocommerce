import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/ui/home/checkout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

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
    await Future.delayed(const Duration(seconds: 1));
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
      body: isLoggedIn
          ? RefreshIndicator(
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
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 70), // leave space for button
                      child: ListView.separated(
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
                                          placeholder: (_, __) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                          ),
                                          errorWidget: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: FaIcon(FontAwesomeIcons.image, color: Colors.grey, size: 28),
                                            ),
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
                                            Text(
                                              "${item["price"].toStringAsFixed(2)}৳",
                                              style: const TextStyle(color: Colors.red),
                                            ),
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
                                  const Divider(height: 20),
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
            )
          : Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.cartShopping, size: 48, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      Text(
                        "Oops! Your cart is empty.",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please login to add items to your cart and continue shopping.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        icon: const FaIcon(FontAwesomeIcons.rightToBracket),
                        label: const Text("Login / Register"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

      bottomNavigationBar: cartItems.isNotEmpty && isLoggedIn
          ? Container(
              padding: const EdgeInsets.all(12),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              // ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
                },
                child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }
}
