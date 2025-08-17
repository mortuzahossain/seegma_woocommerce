import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/cart_provider.dart';
import 'package:seegma_woocommerce/ui/home/checkout.dart';
import 'package:seegma_woocommerce/ui/home/product_details.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
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
      if (isLoggedIn) {
        Future.microtask(() => Provider.of<CartProvider>(context, listen: false).fetchCart());
      }
    });
  }

  Future<void> refreshCart() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  void updateQuantity(int index, int change) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final item = cartProvider.items[index];
    final currentQty = int.parse(item['quantity']['value'].toString());
    final newQty = currentQty + change;
    if (newQty > 0) {
      cartProvider.updateQuantity(item['item_key'], newQty);
    }
  }

  void removeItem(int index) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final item = cartProvider.items[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Item"),
          content: const Text("Are you sure you want to remove this item from the cart?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove")),
          ],
        );
      },
    );

    if (confirm == true) {
      cartProvider.removeItem(item['item_key']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: isLoggedIn
          ? RefreshIndicator(
              onRefresh: refreshCart,
              child: Consumer<CartProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return animatedLoader();

                  if (provider.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            children: [
                              const FaIcon(FontAwesomeIcons.triangleExclamation, size: 80, color: Colors.red),
                              const SizedBox(height: 16),
                              const Text("Failed to load cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text("Something went wrong while fetching your cart.", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (provider.items.isEmpty) {
                    return ListView(
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
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      // final total = item["price"] * item["quantity"];
                      final variation = item['meta']?['variation'];
                      final variationText = (variation is Map<String, dynamic> && variation.isNotEmpty)
                          ? variation.entries.map((e) => "${e.key}: ${e.value}").join(", ")
                          : "";
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: item)));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: item["featured_image"],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.scaleDown,
                                        placeholder: (_, __) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Center(child: animatedLoader()),
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
                                            "${double.parse(item["price"]) / 100}৳",
                                            style: const TextStyle(color: Colors.green),
                                          ),
                                          const SizedBox(height: 4),

                                          Text(variationText, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${item["totals"]["total"]}৳",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.remove), onPressed: () => updateQuantity(index, -1)),
                                    Text(item["quantity"]['value'].toString(), style: const TextStyle(fontSize: 16)),
                                    IconButton(icon: const Icon(Icons.add), onPressed: () => updateQuantity(index, 1)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => removeItem(index),
                                      icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
                                      label: const Text("Remove item", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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

      bottomNavigationBar: (Provider.of<CartProvider>(context).cart?['items']?.isNotEmpty == true && isLoggedIn)
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    // Provider.of<CartProvider>(context, listen: false).cart;
                    // print(cart);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage()));
                  },
                  child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          : SizedBox.shrink(), // fallback when null
    );
  }
}
